# TTT

To play, run `ruby ttt.rb`

## TTTGame class
Game engine. 

​	Other game logic are delegated to Board, ie, full?, line_formed?, etc

- takes a new Board

- takes Array of Players ordered by first to move

- protects the board from being modified more than once per turn

- protects board from Players using other symbols

- tracks which symbol belongs to which player

- FIXME last winning move for computer is displayed too rapidly/or skipped

- TODO suggest early draw, when no win is possible

  

  ### score

  Hash of player index to score value

### TTTGame.players

array of Player objects index 0..last

### Game rules and dynamics

See https://www.gamedev.net/forums/topic/646788-tic-tac-toe-on-5x5-board/

- Game dynamics changes if playing 3-x-row with larger sized boards. I.e. first player likely wins.
- Playing edge to edge results in more draws than wins. Eg for 5-x-row with 5x5 board, all the winning moves are fewer and easy to block.
- Game dynamics and fairness to be explored.

* Temporary solution: Set winning "line" length at Board#initialize

## Board class

Game state. It's an n x n matrix of Squares numbered 1..n*n. Supports (odd) n x n size from 3 to 15. Supports multiple players.

Uses Square class to represent a square. Uses Line class to abstract a 'line' . Uses Grid class to display the TTT board.

- passed between players, and game engine
  - TTTGame protects the board from illegal moves by any Player class
- Players can inspect the board, changes are discarded by TTTGame. Although, Player can modify a copy e.g. using minimax

| name          | purpose                                                   |
| ------------- | --------------------------------------------------------- |
| Lines         | collections of cell numbers in a line                     |
| group         | square numbers of a line                                  |
| Square#symbol | a marker or an empty space; used for displaying the board |
| marker        | a Player marker. e.g. 'X' or 'O'                          |

## Line class

A group of squares, used to abstract a collection of squares.

## Square class

Holds the  Player's marker on the board.

- a String
- one symbol per player

## Grid class

Displays the board. It scales with the size of the board.

NOTE: Currently unable to detect the user's terminal size to set maximum board size.

## Player class

Player inspects the board using Board#unmarked_squares.

- TTTGame modifies board, Player is passed a deep copy
- 'owns' the symbol
- Can choose any character symbol
- ensures unique symbols for each
- Player#choose returns the move

## Human class

Child of Player class. Displays and prompts users for name, choice of symbol, and moves.

## Computer class

Inherits Player. Set's it's own name and symbol. Able to defend from imminent loss. Able to make a winning move. All other moves are random.

## Analyzing1Computer class

Inherits Computer. instance that looks ahead only one move. using points evaluate the best move.

#### Points

| point             | function              | notes                         |
| ----------------- | --------------------- | ----------------------------- |
| 1                 | line claimed          |                               |
| 1+                | 1 per lines blocked   | max of 4(planes) * win_length |
| board edge square | deny win              |                               |
| Infinity          | win                   |                               |
| 0                 | lines already blocked | no use to take that move      |
| -Infinity         | loose                 |                               |
|                   |                       |                               |
|                   |                       |                               |
|                   |                       |                               |

## MaximizingComputer class

Inherits Analyzing1Computer. Uses Minimax. 

Current minimax implementation needs tests and tweaks. It's may be expensive. Using Timeout to break early, then it defaults to Analyzing1Computer#choose

Proper scoring heuristic to be implemented.

## Utility

Implemented Array#joinor

Implemented String#parenthesize