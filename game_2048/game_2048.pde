import java.util.ArrayList;

int grid_size = 4;
PFont font;


Board board = new Board(grid_size);


void setup(){
  font = createFont("Arial", 22);
  textAlign(CENTER);
  textFont(font);
  size(400, 400);
  board.grid[2][2] = 4096;
}

void draw_grid(){
  background(255);
  stroke(174, 67, 97);
  int len = width / grid_size;
  for(int i=1; i<(width/len); i++){
    line(len*i, 0, len*i, height);
    line(0, len*i, width, len*i);
  }
}

void place_number(){
  fill(0);
  int len = width / grid_size;
  int margin = ceil(len / 2);
  for(int i=0; i<grid_size; i++){
    for(int j=0; j<grid_size; j++){
      int n = board.grid[i][j];
      if(n==0)
        continue;
      text(String.format("%d", n), len*j+margin, len*i+margin+int(margin/5));
    }
  }
}

void fill_box(){
  colorMode(HSB, 100);
  noStroke();
  int len = width / grid_size;
  int margin = int(len * 0.02);
  for(int i=0; i<grid_size; i++){
    for(int j=0; j<grid_size; j++){
      if(board.grid[i][j] == 0)
        fill(100);
      else
        fill(70, board.grid[i][j], 100);
      rect(j*len+margin, i*len+margin, len-2*margin, len-2*margin, 12);
    }
  }
  colorMode(RGB, 255);
}

void draw(){
  //draw_grid();
  fill_box();
  place_number();
}

void game_over(){
}

void keyPressed(){
  if(board.game_over){
    game_over();
  }
    
  if(keyCode == UP)
    board.up();
  if(keyCode == DOWN)
    board.down();
  if(keyCode == RIGHT)
    board.right();
  if(keyCode == LEFT)
    board.left();
}

void show(Board b) { 
  for(int i=0; i<b.size; i++){
    for(int j=0; j<b.size; j++){
      print(b.grid[i][j]);
      print(" ");
    }
    println("");
  }
  println("");
}


class Board {
  int size;
  int[][] grid;
  final int[] _map = {2, 2, 2, 2, 2, 2, 2, 2, 2, 4};  // map of minimum
  boolean game_over = false;
  
  Board(int size){
    this.size = size;
    init_board();
    spawn_minimum();
  }
  
  void init_board(){
    grid = new int[size][size];
    // initialize board
    for(int i=0; i<size; i++){
      for(int j=0; j<size; j++){
        grid[i][j] = 0;
      }
    } 
  }
  
  int generate_minimum(){
    // returns 2 with 90% probability. otherwise 4.
    int _index = int(random(0, 10));
    return _map[_index];
  }
  
  ArrayList empty_cells(){
    // returns a list of coordinate of empty cells.
    ArrayList arr = new ArrayList();
    for(int i=0; i<size; i++){
      for(int j=0; j<size; j++){
        if(grid[i][j] == 0){
          Integer[] p = {i, j};
          arr.add(p);
        }
      }
    }
    return arr;
  }
  
  void spawn_minimum(){
    // spawn minimum number to any empty cells.
    int _min = generate_minimum();
    ArrayList<Integer[]> arr = empty_cells();
    int num_of_empty = arr.size();
    if(num_of_empty == 0){
      boolean stalemate;
      stalemate = is_stalemate();
      println("GameOver!");
      if(stalemate)
        game_over = true;
      //TODO: raise exception
      return;
    }
    int index = int(random(0, num_of_empty));
    Integer[] p;
    p = arr.get(index);
    int i, j;
    i = p[0];
    j = p[1];
    grid[i][j] = _min;
  }
  
  int[] compress(int[] arr){
    // "compress" array to the left.
    // [2, 0, 2, 4] -> [2, 2, 4, 0]
    if(!contains(arr, 0))
      return arr;
    int j;
    for(int i=1; i<arr.length; i++){
      if(arr[i] == 0){
        continue;
      }
      j = i - 1;
      while(arr[j] == 0){
        j -= 1;
        if(j == -1)
          break;
      }
      if(arr[j+1] == 0){
          arr[j+1] = arr[i];
          arr[i] = 0;
      }
    }
    return arr;
  }
  
  boolean contains(int[] arr, int value){
    // returns true if arr contains value.
    for(int i=0; i<arr.length; i++){
      if(arr[i] == value){
        return true;
      }
    }
    return false;
  }
  
  int[] merge(int[] arr){
    // merge to the left.
    // [2, 2, 4, 4] -> [4, 0, 8, 0]
    int i = 0;
    while(i < arr.length - 1){
      if(arr[i] == arr[i+1] && arr[i] != 0){
        arr[i] *= 2;
        arr[i+1] = 0;
        i += 2;
      }else{
        i += 1;
      }
    }
    return arr;
  }
  
  int[] squash(int[] arr){
    // "squash" array to the left.
    // [2, 2, 4, 4] -> [4, 8, 0, 0]
    return compress(merge(compress(arr.clone())));
  }
  
  void reverse_arr(int[] arr){
    int len = arr.length;
    int tmp;
    for(int i=0; i<len/2; i++){
      tmp = arr[i];
      arr[i] = arr[len - 1 - i];
      arr[len - 1 - i] = tmp;
    }
  }
  
  void reverse(){
    // make class variable "grid" reversed
    for(int i=0; i<grid.length; i++)
      reverse_arr(grid[i]);
  }
  
  void transpose(){
    // make class variable "grid" transposed
    int[][] _original = new int[size][size];
    for(int i = 0; i<size; i++){
      for(int j = 0; j<size; j++){
        _original[i][j] = grid[i][j];
      }
    }
    for(int i = 0; i<size; i++){
      for(int j = 0; j<size; j++){
        grid[i][j] = _original[j][i];
      }
    }
  }
  
  boolean is_same_array(int[] arr1, int[] arr2){
    // returns true if arr1 equals to arr2
    if(arr1.length != arr2.length)
      return false;
    int len = arr1.length;
    for(int i = 0; i<len; i++){
      if(arr1[i] != arr2[i])
        return false;
    }
    return true;
  }

  void left(){
    // make all arrays of class variable "grid" squashed
    int[][] new_grid = new int[size][size];
    for(int i=0; i<size; i++)
      new_grid[i] = squash(grid[i]);
    for(int i=0; i<size; i++){
      if(new_grid[i] != grid[i]){
        grid = new_grid;
        spawn_minimum();
      }
    }
  }
      
  void right(){
    // same as left(), but move to the right
    reverse();
    left();
    reverse();
  }
  
  void up(){
    // same as above
    transpose();
    left();
    transpose();
  }
  
  void down(){
    // same as above    
    transpose();
    reverse();
    left();
    reverse();
    transpose();
  }
  
  boolean is_squashable(int[] arr){
    // returns true when the array can be squashed
    for(int i=0; i<arr.length-1; i++){
      if(arr[i] == arr[i+1])
        return true;
    }
    return false;
  }
  
  boolean is_stalemate(){
    // returns true when the game end in stalemate
    for(int i=0; i<size; i++){
      if(is_squashable(grid[i]))
        return false;
    }
    transpose();
    for(int i=0; i<size; i++){
      if(is_squashable(grid[i])){
        transpose();
        return false;
      }
    }
    transpose();
    return true;
  }
}
