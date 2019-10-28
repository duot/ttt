require 'pry'

class Square
  X = 'X'
  O = 'O'
  attr_accessor :x, :y, :mark

  def empty?
    !mark
  end

  def initialize(x, y, mark = nil)
    @x = x
    @y = y
    @mark = mark # Square::X, O, or nil
  end

  def to_s
    [x, y, mark].to_s
  end
end

class Line
  attr_accessor :squares

  def initialize squares
    @squares = squares
  end

  # filled with any mark?
  def full?
    squares.all? { |s| !!s.mark }
  end

  # full and taken by one player
  def taken?
    head, *rest = squares
    return false if head.empty?

    rest.all? { |s| s.mark == head.mark }
  end

  # return empty squares
  def empty
    squares.select { |s| s.empty? }
  end
end

class Board
  attr_accessor :lv, :cv, :rv, :th, :ch, :bh, :dd, :ud
  attr_accessor :grid, :lines

  def initialize
    # matrix of squares
    # TODO: scaleable size
    @grid = Array.new(3) { |i| Array.new(3) { |j| Square.new i, j }}

    # container of named squares
    # left_vertical, center_vertical, right_vertical, etc
    @lv = Line.new Array.new(3) { |i| grid[i][0] }
    @cv = Line.new Array.new(3) { |i| grid[i][1] }
    @rv = Line.new Array.new(3) { |i| grid[i][2] }

    @th = Line.new Array.new(3) { |i| grid[0][i] }
    @ch = Line.new Array.new(3) { |i| grid[1][i] }
    @bh = Line.new Array.new(3) { |i| grid[2][i] }

    @dd = Line.new [grid[0][0], grid[1][1], grid[2][2]]
    @ud = Line.new [grid[2][2], grid[1][1], grid[0][0]]

    @lines = [lv, cv, rv, th, ch, bh, dd, ud]
  end

  def display
    # TODO
    pp grid
  end

  def full?
    lv.full? && cv.full? && rv.full?
  end

  def line_formed?
    lines.any?(&:taken?)
  end

  def line_formed
    lines.select(&:taken?)
  end

  # return square
  def self.xy(x, y)
  end
end

class Player
  def initialize(name, preferred_mark)
  end
end

class Human < Player
end

class Computer < Player
end

class TTTGame
  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def play
    board = Board.new

    loop do
      display_welcome
      board.display

      player_a_moves
      break if someone_won? || board.line_formed?

      player_b_moves
      break if someone_won? || board.line_formed?
    end

    winner = who_won?
    display_result
    display_goodbye
  end
end

if __FILE__ == $PROGRAM_NAME
  b = Board.new
  b.display
  p b.full?
  p b.line_formed?
  p b.line_formed


#  TTTGame.new.play
end
