require 'pry'

# TODO namespace

class IllegalBoardStateError < RuntimeError
end

class Square
  X = 'X'
  O = 'O'
  EMPTY = ' '
  # SYMBOLS = [X, O].freeze

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

  private

  attr_writer :marker
end

class Board
  attr_reader :squares, :lines, :lv, :cv, :rv, :th, :ch, :bh, :dd, :ud

  # note: no need for write access for squares hash
  # only read and write once for square marker

  def initialize(squares = {})
    @squares = squares
    reset if squares.empty?
  end

  # accessor of named squares
  # left_vertical, center_vertical, right_vertical, etc
  def lines
    [lv, cv, rv, th, ch, bh, dd, ud]
  end

  def lv; liner 1, 4, 7; end
  def cv; liner 2, 5, 8; end
  def rv; liner 3, 6, 9; end

  def th; liner 1, 2, 3; end
  def ch; liner 4, 5, 6; end
  def bh; liner 7, 8, 9; end

  def dd; liner 1, 5, 9; end
  def ud; liner 7, 5, 3; end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  def to_s; grid; end

  def full?
    squares.all? { |_, square| !square.empty? }
  end

  def line_formed?
    line_formed.any?
  end

  def line_formed
    lines.select do |line|
      square1 = line.first
      next if square1.empty?
      line.all? { |square| square.marker == square1.marker }
    end
  end

  def winning_marker
    return if !line_formed?
    line = line_formed.first
    line.first.marker
  end

  def [](key)
    squares[key]
  end

  # return [] of empty squares
  # grid indexed by int 1..9, left..right, top..bottom
  def unmarked_square_keys
    squares.select { |_, val| val.empty? }.keys
  end

  private

  def liner(*args)
    squares.values_at(*args)
  end

  def grid
    <<GRID
 +---------+---------+---------+
 1         2         3         |
 |         |         |         |
 |    #{squares[1]}    |    #{squares[2]}    |    #{squares[3]}    |
 |         |         |         |
 |         |         |         |
 +---------+---------+---------+
 4         5         6         |
 |         |         |         |
 |    #{squares[4]}    |    #{squares[5]}    |    #{squares[6]}    |
 |         |         |         |
 |         |         |         |
 +---------+---------+---------+
 7         8         9         |
 |         |         |         |
 |    #{squares[7]}    |    #{squares[8]}    |    #{squares[9]}    |
 |         |         |         |
 |         |         |         |
 +---------+---------+---------+
GRID
  end
end

class Player
  attr_reader :symbol, :name

  def initialize(symbol, name = '')
    @name = name
    @symbol = symbol
    ensure_name
  end

  def choose(board); end

  protected

  attr_writer :name
end

class Human < Player
  def choose(board)
    # display choices
    choices = board.unmarked_square_keys
    choice = nil
    loop do
      print 'Please pick a square: '
      print choices
      print ' '
      choice = gets.chomp.to_i
      break choice if choices.include? choice
    end
  end

  private

  def ensure_name
    ask_name if @name.empty?
  end

  def ask_name
    name = loop do
      print "What's your name? "
      input = gets.chomp.strip
      break input.capitalize unless input.empty?
    end

    @name = name
  end
end

class Computer < Player
  def choose(board)
    board.unmarked_square_keys.sample
  end

  private

  def ensure_name
    return unless name.empty?
    @name = %w(Alpha Bravo Charlie Delta Echo).sample.prepend 'AI_'
  end
end

class TTTGame
  HUMAN_MARKER = 'X'
  COMPUTER_MARKER = 'O'
  def initialize
    clear
    @human = Human.new HUMAN_MARKER
    @computer = Computer.new COMPUTER_MARKER
    @board = Board.new
    @current_player = human
  end

  def play
    clear
    display_welcome

    loop do
      display_board

      loop do
        current_player_moves
        break if board.full? || board.line_formed?
        clear_screen_and_display_board # if human_turn?
      end

      display_result(who_won?)

      break unless play_again?
      reset
    end
    display_goodbye
  end

  private

  attr_reader :human, :computer, :board
  attr_accessor :current_player

  def current_player_moves
    squares_state_snapshot = board.squares.map(&:inspect)
    if human_turn?
      human_move
      @current_player = computer
    else
      computer_move
      @current_player = human
    end

    # delta is the mount of squares changed
    delta = difference(squares_state_snapshot, board.squares.map(&:inspect))
    msg = "Only one square has to be changed per turn"
    raise IllegalBoardStateError, msg unless delta == 1

    # TODO rescue
  end

  def difference(old, new)
    (old - new).count
  end

  def human_turn?
    current_player == human
  end

  def reset
    board.reset
    clear
    display_play_again
    @current_player = human
  end

  def display_board
    puts board
    puts
  end

  def clear_screen_and_display_board
    clear
    puts
    display_board
  end

  def display_play_again
    puts "Let's play again!"
    puts
  end

  def play_again?
    choice = nil
    loop do
      print 'Do you want to play again? (y/n) '
      choice = gets.chomp.downcase[0]
      break if ['y', 'n'].include? choice
    end

    choice == 'y'
  end

  def clear
    system('clear') || system('cls')
  end

  def human_move
    # TODO raise error if human used other marker
    choice = human.choose board
    # TODO board[choice] = human.symbol
    board[choice].x!
  end

  def computer_move
    # TODO raise error if computer used other marker
    choice = computer.choose board
    board[choice].o!
  end

  def display_result(winner)
    clear_screen_and_display_board
    case winner
    when human
      puts "#{human.name} won."
    when computer
      puts "#{computer.name} won."
    else
      puts "It's a draw."
    end
    puts
  end

  def who_won?
    return :TIE if board.winning_marker.nil?
    sym = board.winning_marker
    if human.symbol == sym
      human
    elsif computer.symbol == sym
      computer
    end
  end

  def display_welcome
    puts "Welcome to a game of Tic Tac Toe."
    puts
  end

  def display_goodbye
    puts "Thank you for playing Tic Tac Toe. Goodbye."
    puts
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
