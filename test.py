import unittest

from core import Board, GameOver


class TestBoard(unittest.TestCase):

    def setUp(self):
        self.seed = 0
        self.initial_grid = [
            [0, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 2, 0],
            [0, 0, 0, 0],
        ]

        self.grid_1 = [
            [0, 8, 16, 64],
            [0, 0, 4, 32],
            [0, 0, 2, 4],
            [0, 0, 4, 0],
        ]

        self.grid_2 = [
            [0, 0, 8, 0],
            [0, 2, 2, 2],
            [8, 0, 8, 4],
            [0, 0, 4, 4],
        ]

        self.grid_stalemate = [
            [2, 4, 2, 4],
            [4, 2, 4, 2],
            [2, 4, 2, 4],
            [4, 2, 4, 2],
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
        b.grid = self.grid_stalemate
        b.spawn_minimum()
        self.assertTrue(b.gameover)

    def test_squash_0(self):
        b = Board()

        arr = [0, 2, 0, 4]
        self.assertEqual(b.squash(arr), [2, 4, 0, 0])

        arr = [8, 8, 8, 8]
        self.assertEqual(b.squash(arr), [16, 16, 0, 0])

        arr = [2, 2, 4, 4]
        self.assertEqual(b.squash(arr), [4, 8, 0, 0])

        arr = [2, 4, 8, 4]
        self.assertEqual(b.squash(arr), [2, 4, 8, 4])

    def test_transpose(self):
        b = Board()
        b.grid = self.grid_1
        expected = [
            [0, 0, 0, 0],
            [8, 0, 0, 0],
            [16, 4, 2, 4],
            [64, 32, 4, 0],
        ]
        self.assertEqual(b.grid, self.grid_1)
        b.transpose()
        self.assertEqual(b.grid, expected)

    def test_reversed(self):
        b = Board()
        b.grid = self.grid_1
        expected = [
            [64, 16, 8, 0],
            [32, 4, 0, 0],
            [4, 2, 0, 0],
            [0, 4, 0, 0],
        ]
        self.assertEqual(b.grid, self.grid_1)
        b.reverse()
        self.assertEqual(b.grid, expected)

    def test_calc_score(self):
        b = Board()
        b.grid = self.grid_1
        self.assertEqual(b.calc_score(), 134)

    def test_check_stalemate(self):
        b = Board()
        self.assertFalse(b.check_stalemate())
        b.grid = [
            [2, 2, 2, 2],
            [2, 2, 2, 0],
            [2, 2, 2, 2],
            [2, 2, 2, 2],
        ]
        self.assertFalse(b.check_stalemate())
        b.grid[1][3] = 2
        self.assertFalse(b.check_stalemate())
        b.grid = [
            [2, 4, 2, 4],
            [2, 4, 2, 4],
            [2, 4, 2, 4],
            [2, 4, 2, 4],
        ]
        self.assertFalse(b.check_stalemate())
        b.grid = [
            [2, 4, 2, 4],
            [4, 2, 4, 2],
            [2, 4, 2, 4],
            [4, 2, 4, 2],
        ]
        self.assertTrue(b.check_stalemate())


    def test_left(self):
        b = Board(self.seed)
        b.left()
        expected = [
            [0, 0, 0, 0],
            [2, 0, 0, 0],  # spawn
            [2, 0, 0, 0],
            [0, 0, 0, 0],
        ]

        self.assertEqual(b.grid, expected)

        b = Board(self.seed)
        b.grid = self.grid_2
        b.left()
        expected = [
            [8, 0, 0, 0],
            [4, 2, 0, 0],
            [16, 4, 0, 2],  # spawn
            [8, 0, 0, 0],
        ]
        self.assertEqual(b.grid, expected)


if __name__ == '__main__':
    unittest.main()
