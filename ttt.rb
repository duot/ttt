require 'pry'

class Square
  X = 'X'
  O = 'O'
  EMPTY = ' '
  SYMBOLS = [X, O].freeze

  attr_reader :marker

  def initialize(marker = nil)
    @marker = marker # Square::X, O, or nil
  end

  def empty?
    !marker
  end

  def x!
    @marker = Square::X if marker.nil?

    # TODO otherwise, raise SquareAlreadyMarked
  end

  def o!
    @marker = Square::O if marker.nil?

    # TODO otherwise, raise SquareAlreadyMarked
  end

  def symbol
    marker || Square::EMPTY
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

  # filled with any marker?
  def full?
    squares.all? { |s| !!s.marker }
  end

  # full and taken by one player
  def taken?
    head, *rest = squares
    return false if head.empty?

    rest.all? { |s| s.marker == head.marker }
  end

  # return empty squares
  def empty
    squares.select { |s| s.empty? }
  end

  def marker
    return if !taken?
    squares.first.marker
  end
end

class Board
  attr_reader :squares, :lines, :lv, :cv, :rv, :th, :ch, :bh, :dd, :ud

  # note: no need for write access for squares hash
  # only read and write once for square marker

  def initialize
    @squares = {}
    reset

    # container of named squares
    # left_vertical, center_vertical, right_vertical, etc
    @lv = Line.new [squares[1], squares[4], squares[7]]
    @cv = Line.new [squares[2], squares[5], squares[8]]
    @rv = Line.new [squares[3], squares[6], squares[9]]

    @th = Line.new [squares[1], squares[2], squares[3]]
    @ch = Line.new [squares[4], squares[5], squares[6]]
    @bh = Line.new [squares[7], squares[8], squares[9]]

    @dd = Line.new [squares[1], squares[5], squares[9]]
    @ud = Line.new [squares[7], squares[5], squares[3]]

    @lines = [lv, cv, rv, th, ch, bh, dd, ud]
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  def display
    puts "+-----+-----+-----+"
    puts "1     2     3     |"
    puts "|     |     |     |"
    puts "|  #{squares[1]}  |  #{squares[2]}  |  #{squares[3]}  |"
    puts "|     |     |     |"
    puts "|     |     |     |"
    puts "+-----+-----+-----+"
    puts "4     5     6     |"
    puts "|     |     |     |"
    puts "|  #{squares[4]}  |  #{squares[5]}  |  #{squares[6]}  |"
    puts "|     |     |     |"
    puts "|     |     |     |"
    puts "+-----+-----+-----"
    puts "7     8     9     |"
    puts "|     |     |     |"
    puts "|  #{squares[7]}  |  #{squares[8]}  |  #{squares[9]}  |"
    puts "|     |     |     |"
    puts "|     |     |     |"
    puts "+-----+-----+-----+"
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

  def [](key)
    squares[key]
  end

  def []=(key, val)
    @squares[key] = val
  end

  # return [] of empty squares
  # grid indexed by int 1..9, left..right, top..bottom
  def unmarked_square_keys
    squares.select { |_, val| val.empty? }.keys
  end

  def someone_won?
    line_formed.empty? ? false : true
  end

  private
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
    choices = board.unmarked_square_keys
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
    choice = board.unmarked_square_keys.sample
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
    sym = board.line_formed.first.marker
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
  # p b[1].marker
  # p b[1]
  # p b[9].o!
  # p b[9].marker
  # p b.choices
  # b.display
  # print 'board full? '
  # p b.full?
  # p b.line_formed?
  # p b.line_formed

  TTTGame.new.play
end
