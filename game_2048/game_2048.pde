import java.util.ArrayList;
import java.util.Arrays;

int grid_size = 4;
PFont font, font2;
int spawnbox = 0;
//boolean animation_completed = false;


Board board;

void setup(){
  board = new Board(grid_size);
  font = createFont("Arial", 22);
  font2 = createFont("Arial", 50);
  textAlign(CENTER);
  textFont(font);
  background(240);
  size(400, 400);
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
  fill(255);
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

int log2(int x){
  if(x == 0)
    return 0;
  return int(log(x) / log(2));
}

void fill_box(){
  colorMode(HSB, 17);
  noStroke();
  int len = width / grid_size;
  int margin = int(len * 0.02);
  for(int i=0; i<grid_size; i++){
    for(int j=0; j<grid_size; j++){
      if(board.grid[i][j] == 0)
        fill(100);
      else
        fill(16, 3+log2(board.grid[i][j]), 16);
      if(board.last_spawned[0] == i && board.last_spawned[1] == j){
        rect(j*len+margin, i*len+margin, spawnbox, spawnbox, 12);
        if(spawnbox >= len-2*margin)
          spawnbox = len-2*margin;
        else
          spawnbox += 10;
      }
      else
        rect(j*len+margin, i*len+margin, len-2*margin, len-2*margin, 12);
    }
  }
  colorMode(RGB, 255);
}

void draw(){
    background(245);
    fill_box();
    place_number();
    if(board.game_over)
      game_over();
}

void game_over(){
  //println("GameOver");
  //nprintln(board.score);
  fill(70, 200, 150, 220);
  rect(0, height/3, width, height/3);
  fill(255);
  textFont(font2);
  text("Game Over!", width/2, height/2);
  textSize(25);
  text(String.format("%d", board.score), width/2, int(height*2/5));
  text("Press r to restart", width/2, int(height*3/5));
  textFont(font);
}

void keyPressed(){
  if(key == 'r' && board.game_over){
    setup();
    return;
  }
    
  spawnbox = 0;
  
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
  int score = 0;
  int size;
  int[][] grid;
  int last_spawned[] = {-1, -1};
  final int[] _map = {2, 2, 2, 2, 2, 2, 2, 2, 2, 4};  // map of minimum
  boolean game_over = false;
  
  boolean transposed = false;
  boolean reversed = false;
  
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
      if(stalemate){
        game_over = true;
        calc_score();
      }
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
    
    if(reversed){
      j = 3 - j;
    }
    if(transposed){
      int tmp;
      tmp = j;
      j = i;
      i = tmp;
    }

    last_spawned[0] = i;
    last_spawned[1] = j;
    
    //println(i, j);
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
      if(!Arrays.equals(grid[i], new_grid[i])){
        grid = new_grid;
        spawn_minimum();
      }
    }
    if(is_stalemate()){
      game_over = true;
      calc_score();
    }
  }
      
  void right(){
    // same as left(), but move to the right
    reverse();
    reversed = true;
    left();
    reverse();
    reversed = false;
  }
  
  void up(){
    // same as above
    transpose();
    transposed = true;
    left();
    transpose();
    transposed = false;
  }
  
  void down(){
    // same as above    
    transpose();
    reverse();
    transposed = true;
    reversed = true;
    left();
    reverse();
    transpose();
    transposed = false;
    reversed = false;
  }
  
  boolean is_squashable(int[] arr){
    // returns true when the array can be squashed
    for(int i=0; i<arr.length-1; i++){
      if(arr[i] == arr[i+1] || arr[i] == 0 || arr[i+1] == 0)
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
  
  void calc_score(){
    int total = 0;
    for(int i=0; i<size; i++){
      for(int j=0; j<size; j++)
        total += grid[i][j];
    }
    score = total;
  }
}
