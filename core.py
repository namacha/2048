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
        return 2

    def empty_cells(self):
        result = set()
        for i in range(self.row):
            for j in range(self.col):
                if self.grid[i][j] is None:
                    result.add((i, j))
        return result

    def spawn_minimum(self):
        _min = self.generate_minimum()
        empty_cells = self.empty_cells()
        if not empty_cells:
            raise GameOver
        i, j = random.choice(list(empty_cells))
        self.grid[i][j] = _min
