# TTT

To play, run `ruby ttt.rb`. Press <kbd>Ctrl</kbd>/<kbd>Command</kbd> + <kbd>c</kbd> to quit.

This is a terminal based Tic-Tac-Toe game with different playable modes:

	* Human vs Computer
	* Human vs Human
	* Computer vs Computer
	* Custom

The custom modes allows:

	* Board sizes 3, 5, 7, 9, 11, 13, and 15
	* Players of up 15 (with any combination of Humans and Computers)
	* Human Players can choose to play any valid symbols

The computer players are implemented with minimax algorithm for game modes with 2 players. For games with more than 2 players, maximax is used.

## Implementation Details

### Game class

The `Game` class is the starting point. It generates presets game modes or prompt the user for custom values. These values are used to initialize `TTTGame` .

### TTTGame class
Game engine. 

​	Other game logic are delegated to `Board`, ie, full?, line_formed?, etc

- takes a new `Board`

- takes Array of `Players` ordered by first to move

- protects the board from being modified more than once per turn

- protects board from `Players` using other symbols

- TODO suggest early draw, when no win is possible


  #### score

  Hash of player index to score value

#### TTTGame.new{players:}

Array of `Player` objects ordered 0..last.

#### Game rules and dynamics

See https://www.gamedev.net/forums/topic/646788-tic-tac-toe-on-5x5-board/

- Game dynamics changes if playing 3-x-row with larger sized boards. I.e. first player likely wins.
- Playing edge to edge results in more draws than wins. Eg for 5-x-row with 5x5 board, all the winning moves are fewer and easy to block.
- Game dynamics and fairness to be explored.

* Temporary solution: Set winning "line" length at `Board#initialize`

### Board class

Game state. It's an n x n matrix of `Squares` numbered 1..n*n. Supports (odd) n x n size from 3 to 15. Supports multiple players.

Uses `Square` class to represent a square. Uses `Line` class to abstract a 'line' . Uses `Grid` class to display the TTT board.

- passed between players, and game engine
  - `TTTGame` protects the board from illegal moves by any `Player` class
- `Players` can inspect the board, changes are discarded by `TTTGame`. Although, `Player` can modify a it's own `Board.copy` e.g. using minimax

| name            | purpose                                                   |
| --------------- | --------------------------------------------------------- |
| `Line`s         | collections of square numbers in a line                   |
| `Square#symbol` | a marker or an empty space; used for displaying the board |
| `Player#marker` | a Player marker. e.g. 'X' or 'O'                          |

### Line class

A group of squares, used to abstract a collection of squares.

### Square class

Holds the  Player's marker on the board.

- a String
- one symbol per player

### Grid class

Displays the board. It scales with the size of the board.

NOTE: Currently unable to detect the user's terminal size to set maximum board size.

### Player class

Player inspects the board using Board#unmarked_squares.

- `TTTGame` modifies board, `Player` is passed a deep copy
- 'owns' the symbol
- Can choose any character symbol
- ensures unique symbols for each
- `Player#choose` returns the move

### Human class

Child of Player class. Displays and prompts users for name, choice of symbol, and moves.

### Computer class

Inherits Player. Set's it's own name and symbol. Able to defend from imminent loss. Able to make a winning move. All other moves are random.

### Analyzing1Computer class

Inherits Computer. Looks ahead only one move using [maximax strategy](https://cs.stanford.edu/people/eroberts/courses/soco/projects/1998-99/game-theory/Minimax.html). Using the following table to evaluate moves.

#### Points

| point                 | function              | notes                                                        |
| --------------------- | --------------------- | ------------------------------------------------------------ |
|                       | `Board#win_length`    | Maximum x-in-a-row. Length of the `side` of the `Board`      |
|                       | `@defend_score`       | `win_length ** 3`. Arbitrary choice, but it must be *lower* than capture score |
|                       | `@capture_score`      | `defend_score * 2`. Highest value to ensure win. We *prioritize immediate win* over defense. |
| 1                     | line claimed          | all squares in that line were previously empty               |
| 3 x (lines blocked)   | blocks                | max of 4(planes) * win_length, where "planes" are the line directions. Denys opponents ability to make x-in-a-row. |
| 2 x (per lines built) | builds                | reinforcing lines that are claimed and not blocked           |
| `defend_score`        | deny win              |                                                              |
| `capture_score`       | win                   |                                                              |
| 0                     | lines already blocked | no use to take that move                                     |

### Max2 class

Implements minimax algorithm on 2 player matches. For more players, it reverts back to Analyzing1Computer#choose method

#### Minimax

Minimax is tricky in many ways.

​	 In more than 2 players, it's more difficult to calculate winning moves.

​	The depth plays a huge part in determining the best move. Too deep and the game hangs, and too shallow and the move is weak. #increase_magnitude allows the minimax to prefer winning move at shallower depth.

​	TODO: add depth arg

​	Heuristic: Currently considers only winning, loosing, neutral moves with scores 1,  -1, and 0.

### Utility

Implemented Array#joinor

Implemented String#parenthesize
