import unittest

from core import Board, GameOver


class TestBoard(unittest.TestCase):

    def setUp(self):
        self.seed = 0
        self.initial_grid = [
            [None, None, None, None],
            [None, None, None, None],
            [None, None,    2, None],
            [None, None, None, None],
        ]

        self.grid_1 = [
            [None, 8, 16, 64],
            [None, None, 4, 32],
            [None, None, 2, 4],
            [None, None, 4, None],
        ]

    def test_init_board(self):
        b = Board(self.seed)
        grid = b.grid
        self.assertEqual(grid, self.initial_grid)

    def test_empty_cells_0(self):
        b = Board(self.seed)
        empty_cells = b.empty_cells()
        expected = {(i, j) for i in range(4) for j in range(4)}
        expected.remove((2, 2))
        self.assertEqual(empty_cells, expected)

    def test_empty_cells_1(self):
        b = Board()
        b.grid = self.grid_1
        empty_cells = b.empty_cells()
        expected = {(0, 0), (1, 0), (1, 1), (2, 0), (2, 1), (3, 0), (3, 1), (3, 3)}
        self.assertEqual(empty_cells, expected)

    def test_spawn_minimum_0(self):
        b = Board(self.seed)

        b.spawn_minimum()
        expected = self.initial_grid[:]
        expected[1][0] = 2
        self.assertEqual(b.grid, expected)

        b.spawn_minimum()
        expected[3][0] = 2
        self.assertEqual(b.grid, expected)

    def test_spawn_minimum_1(self):
        b = Board(self.seed)
        b.grid = [[... for _ in range(b.col)] for _ in range(b.row)]
        self.assertRaises(GameOver, b.spawn_minimum)

    def test_collapse_0(self):
        b = Board()

        arr = [None, 2, None, 4]
        self.assertEqual(b.collapse(arr), [2, 4, None, None])

        arr = [8, 8, 8, 8]
        self.assertEqual(b.collapse(arr), [16, 16, None, None])

        arr = [2, 2, 4, 4]
        self.assertEqual(b.collapse(arr), [4, 8, None, None])

        arr = [2, 4, 8, 4]
        self.assertEqual(b.collapse(arr), [2, 4, 8, 4])

if __name__ == '__main__':
    unittest.main()
