import readline
import code

from core import Board

b = Board(seed=0)


variables = globals().copy()
variables.update(locals())
shell = code.InteractiveConsole(variables)
shell.interact()
