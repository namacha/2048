import random


class GameOver(Exception):
    pass


class Board:

    def __init__(self, seed=None, row=4, col=4):
        if seed is not None:
            random.seed(seed)
        self.row = row
        self.col = col
        self.init_grid()

    def init_grid(self):
        grid = [[None for _ in range(self.col)] for _ in range(self.row)]
        self.grid = grid
        self.spawn_minimum()

    def generate_minimum(self):
        """generate minimum number cell"""
        return 2

    def empty_cells(self):
        result = set()
        for i in range(self.row):
            for j in range(self.col):
                if self.grid[i][j] is None:
                    result.add((i, j))
        return result

    def spawn_minimum(self):
        """spawn minimum number cell randomly if there is empty cell, otherwise raises GameOver"""
        _min = self.generate_minimum()
        empty_cells = self.empty_cells()
        if not empty_cells:
            raise GameOver
        i, j = random.choice(list(empty_cells))
        self.grid[i][j] = _min

    def compress(self, arr):
        if not None in arr:
            return arr
        for i in range(1, len(arr)):
            if arr[i] is None:
                continue
            j = i - 1
            while arr[j] is None:
                j -= 1
                if j == -1:
                    break
            if arr[j+1] is None:
                arr[j+1] = arr[i]
                arr[i] = None
        return arr

    def merge(self, arr):
        i = 0
        while i < len(arr)-1:
            if arr[i] == arr[i+1] and arr[i] is not None:
                arr[i] *= 2
                arr[i+1] = None
                i += 2
            else:
                i += 1
        return arr

    def collapse(self, arr):
        return self.compress(self.merge(self.compress(arr)))
