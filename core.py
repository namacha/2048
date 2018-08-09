import random


class GameOver(Exception):
    pass


class Board:

    def __init__(self, seed=None, row=4, col=4):
        if seed is not None:
            random.seed(seed)
        self.row = row
        self.col = col
        self.gameover = False
        self.init_grid()

    def init_grid(self):
        grid = [[0 for _ in range(self.col)] for _ in range(self.row)]
        self.grid = grid
        self.spawn_minimum()

    def generate_minimum(self):
        """generate minimum number cell"""
        return 2

    def empty_cells(self):
        result = set()
        for i in range(self.row):
            for j in range(self.col):
                if self.grid[i][j] == 0:
                    result.add((i, j))
        return result

    def spawn_minimum(self):
        """spawn minimum number cell randomly if there is empty cell, otherwise raises GameOver"""
        _min = self.generate_minimum()
        empty_cells = self.empty_cells()
        if self.check_stalemate():
            self.gameover = True
            return
        i, j = random.choice(list(empty_cells))
        self.grid[i][j] = _min

    def compress(self, arr):
        if not arr:
            return []
        if arr[0] == 0:
            return self.compress(arr[1:]) + [0]
        else:
            return [arr[0]] + self.compress(arr[1:])

    def merge(self, arr):
        if not arr:
            return []
        if len(arr) == 1:
            return arr
        if arr[0] == arr[1]:
            return [arr[0] * 2, 0] + self.merge(arr[2:])
        return [arr[0]] + self.merge(arr[1:])

    def squash(self, arr):
        return self.compress(self.merge(self.compress(arr)))

    def transpose(self):
        transposed_map = map(list, zip(*self.grid))
        self.grid = list(transposed_map)

    def reverse(self):
        _reversed = lambda ls: list(reversed(ls))
        self.grid = list(map(_reversed, self.grid))

    def check_stalemate(self):
        # returns True if the situation is stalemate
        def _any_squashable(arr):
            return any(list(map(lambda ls: self.is_squashable(ls), arr)))

        horizontal = _any_squashable(self.grid)
        if horizontal:
            return False 

        self.transpose()
        vertical = _any_squashable(self.grid)
        self.transpose()
        return not vertical

    def is_squashable(self, arr):
        if 0 in arr:
            return True
        for i in range(len(arr)-1):
            if arr[i] == arr[i+1]:
                return True
 
    def calc_score(self):
        return sum(map(sum, self.grid))

    def left(self):
        grid = list(map(self.squash, self.grid))
        self.grid = grid
        self.spawn_minimum()

    def right(self):
        self.reverse()
        self.left()
        self.reverse()

    def up(self):
        self.transpose()
        self.left()
        self.transpose()

    def down(self):
        self.transpose()
        self.reverse()
        self.left()
        self.reverse()
        self.transpose()
