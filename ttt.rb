require 'pry'

class Square
  X = 'X'
  O = 'O'
  EMPTY = ' '
  SYMBOLS = [X, O].freeze

  attr_reader :mark

  def initialize(mark = nil)
    @mark = mark # Square::X, O, or nil
  end

  def empty?
    !mark
  end

  def x!
    @mark = Square::X if mark.nil?

    # TODO otherwise, raise SquareAlreadyMarked
  end

  def o!
    @mark = Square::O if mark.nil?

    # TODO otherwise, raise SquareAlreadyMarked
  end

  def symbol
    mark || Square::EMPTY
  end

  def to_s
    symbol
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

  def mark
    return if !taken?
    squares.first.mark
  end
end

class Board
  attr_reader :grid, :lines, :lv, :cv, :rv, :th, :ch, :bh, :dd, :ud

  # note: no need for write access for grid
  # only read and write once for square marks
  # attr_accessor :grid

  def initialize
    # matrix of squares
    @grid = Array.new(3) { |i| Array.new(3) { |j| Square.new }}

    # container of named squares
    # left_vertical, center_vertical, right_vertical, etc
    @lv = Line.new Array.new(3) { |i| grid[i][0] }
    @cv = Line.new Array.new(3) { |i| grid[i][1] }
    @rv = Line.new Array.new(3) { |i| grid[i][2] }

    @th = Line.new Array.new(3) { |i| grid[0][i] }
    @ch = Line.new Array.new(3) { |i| grid[1][i] }
    @bh = Line.new Array.new(3) { |i| grid[2][i] }

    @dd = Line.new [grid[0][0], grid[1][1], grid[2][2]]
    @ud = Line.new [grid[2][0], grid[1][1], grid[0][2]]

    @lines = [lv, cv, rv, th, ch, bh, dd, ud]
  end

  def display
    puts "     |     |"
    puts "     |     |"
    puts "  #{grid[0][0]}  |  #{grid[0][1]}  |  #{grid[0][2]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "     |     |"
    puts "  #{grid[1][0]}  |  #{grid[1][1]}  |  #{grid[1][2]}"
    puts "     |     |"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "     |     |"
    puts "  #{grid[2][0]}  |  #{grid[2][1]}  |  #{grid[2][2]}"
    puts "     |     |"
    puts "     |     |"
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
  def xy(x, y)
    grid[x][y]
  end

  def [](idx)
    x, y = to_coord idx
    grid.dig(x, y)
  end

  def []=(idx, val)
    x, y = to_coord idx
    grid[x][y] = val
  end

  # return [] of empty squares
  # grid indexed by int 1..9, left..right, top..bottom
  def choices
    empty_ones = grid.map { |row| row.map { |square| square.empty? }}
    number = empty_ones.flatten.each_with_index.map do |bool, idx|
      idx.next if bool
    end

    number.reject(&:nil?)
  end

  def someone_won?
    line_formed.empty? ? false : true
  end

  private

  # return an int index of an x, y coordinate
  def to_index(x, y)
    # FIXME assuming 3x3 matrix
    @lookup = {
      [0, 0] => 1,
      [0, 1] => 2,
      [0, 2] => 3,
      [1, 0] => 4,
      [1, 1] => 5,
      [1, 2] => 6,
      [2, 0] => 7,
      [2, 1] => 8,
      [2, 2] => 9
    }
    @lookup[[x, y]]
  end

  # return a pair of x,y coordinates for a given idx
  def to_coord(idx)
    # TODO optimize
    @lookup = {
      [0, 0] => 1,
      [0, 1] => 2,
      [0, 2] => 3,
      [1, 0] => 4,
      [1, 1] => 5,
      [1, 2] => 6,
      [2, 0] => 7,
      [2, 1] => 8,
      [2, 2] => 9
    }
    @lookup.invert[idx]
  end
end

class Player
  attr_reader :symbol, :name

  def initialize(name = '', symbol)
    @name = name
    @symbol = symbol
    ensure_name
  end

  def move(board)
  end

  protected
  attr_writer :name
end

class Human < Player
  def move(board)
    # display choices
    choices = board.choices
    choice = nil
    loop do
      print 'Please pick a square : '
      print choices
      puts
      choice = gets.chomp.to_i
      break choice if choices.include? choice
    end

    board[choice].x!
  end

  private

  def ensure_name
    if @name.empty?
      get_name
    end
  end

  def get_name
    name = loop do
      print "What's your name? "
      input = gets.chomp.strip
      break input.capitalize unless input.empty?
    end

    @name = name
  end
end

class Computer < Player
  def move board
    choice = board.choices.sample
    board[choice].o!
  end

  private
  def ensure_name
    if @name.empty?
      @name = %w[Alpha Bravo Charlie Delta Echo].sample + ' AI'
    end
  end
end

class TTTGame
  def initialize
    @human = Human.new Square::X
    @computer = Computer.new Square::O
    ensure_different_symbols
  end

  def play
    board = Board.new

    loop do
      display_welcome
      board.display

      human.move board
      break if board.someone_won? || board.line_formed?

      computer.move board
      break if board.someone_won? || board.line_formed?
    end

    board.display
    winner = who_won?(board)
    display_result(winner)
    display_goodbye
  end

  private

  attr_reader :human, :computer

  def display_result(winner)
    case winner
    when human
      puts "#{human.name} won."
    when computer
      puts "#{computer.name} won."
    else
      puts "It's a draw."
    end
  end

  # NOTE tradeoff of Player class as collaborator for Board
  # Board can return the player who won
  def who_won?(board)
    sym = board.line_formed.first.mark
    if human.symbol == sym
      human
    elsif computer.symbol == sym
      computer
    else
      :TIE
    end
  end
#  def prompt(msg = '')
#    puts "TTT> #{msg}"
#  end

  def display_welcome
    puts "Welcome to a game of Tic Tac Toe."
    puts
  end

  def display_goodbye
    puts "Thank you for playing Tic Tac Toe. Goodbye."
    puts
  end

  def ensure_different_symbols
    # useful only if option to
    # TODO set different sym
    # TODO raise error if same sym set
  end
end

if __FILE__ == $PROGRAM_NAME
  # b = Board.new
  # p b[1].x!
  # p b[1].mark
  # p b[1]
  # p b[9].o!
  # p b[9].mark
  # p b.choices
  # b.display
  # print 'board full? '
  # p b.full?
  # p b.line_formed?
  # p b.line_formed

  TTTGame.new.play
end
