# TTT

To play, run `ruby ttt.rb`

## TTTGame
Game engine.
- creates the board
- creates players
- protects the board from being modified more than once per turn
- TODO protects board from players using other symbols
- tracks which symbol belongs to which player

- FIXME last winning move for computer is displayed too rapidly/or skipped
- TODO suggest early draw, when no win is possible

### Game rules and dynamics
#### Notes:

See https://www.gamedev.net/forums/topic/646788-tic-tac-toe-on-5x5-board/

- Game dynamics changes if playing 3-x-row with larger sized boards. I.e. first player likely wins.
- Playing edge to edge results in more draws than wins. Eg for 5-x-row with 5x5 board
- Game dynamics and fairness to be explored.

* Temporary solution: Set winning "line" length at Board#initialize

## Board

game state. uses Square class internally

- passed between players, and game engine
  - it's important that TTTGame protects the board from illegal moves
- TODO in theory, it should be possible to have more than 2 players,
each with their own symbol.
- Board can now scale up to 9x9

## Player

Player inspects the board, but should NOT modify.

- TTTGame modifies board
- 'owns' the symbol
- TODO can choose any character symbol

## Symbol

A 'symbol' is the mark the square in the board.

- a String
- one symbol per player
