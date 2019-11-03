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

  def marker=(symbol)
    # TODO if @marker is set raise error
    @marker = symbol
  end
end

class Board
  WINNING_lINES = [
    [1, 4, 7], [2, 5, 8], [3, 6, 9],
    [1, 2, 3], [4, 5, 6], [7, 8, 9],
    [1, 5, 9], [7, 5, 3]
  ]

  attr_reader :squares, :lines, :lv, :cv, :rv, :th, :ch, :bh, :dd, :ud

  # note: no need for write access for squares hash
  # only read and write once for square marker

  def initialize
    @squares = {}
    reset
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

  def to_s
    [
      "+---------+---------+---------+",
      "1         2         3         |",
      "|         |         |         |",
      "|    #{squares[1]}    |    #{squares[2]}    |    #{squares[3]}    |",
      "|         |         |         |",
      "|         |         |         |",
      "+---------+---------+---------+",
      "4         5         6         |",
      "|         |         |         |",
      "|    #{squares[4]}    |    #{squares[5]}    |    #{squares[6]}    |",
      "|         |         |         |",
      "|         |         |         |",
      "+---------+---------+---------+",
      "7         8         9         |",
      "|         |         |         |",
      "|    #{squares[7]}    |    #{squares[8]}    |    #{squares[9]}    |",
      "|         |         |         |",
      "|         |         |         |",
      "+---------+---------+---------+"
    ].join "\n"
  end

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

  def [](key)
    squares[key]
  end

  # return [] of empty squares
  # grid indexed by int 1..9, left..right, top..bottom
  def unmarked_square_keys
    squares.select { |_, val| val.empty? }.keys
  end

  private

  def liner *args
    squares.values_at *args
  end
end

class Player
  attr_reader :symbol, :name

  def initialize(name = '', symbol)
    @name = name
    @symbol = symbol
    ensure_name
  end

  def choose(board)
  end

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
      print ?\s
      choice = gets.chomp.to_i
      break choice if choices.include? choice
    end
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
  def choose board
    choice = board.unmarked_square_keys.sample
  end

  private
  def ensure_name
    if @name.empty?
      @name = %w[Alpha Bravo Charlie Delta Echo].sample.prepend 'AI_'
    end
  end
end

class TTTGame
  attr_reader :board

  def initialize
    clear
    @human = Human.new Square::X
    @computer = Computer.new Square::O
    ensure_different_symbols
    @board = Board.new
  end

  def play
    display_welcome
    do_clear = false
    loop do
      board.reset
      loop do
        clear if do_clear
        do_clear = true
        puts board

        human_move
        break if board.full? || board.line_formed?

        computer_move
        break if board.full? || board.line_formed?
      end
      clear if do_clear
      puts board
      winner = who_won?
      display_result(winner)

      break unless play_again?
      clear
      do_clear = false
      puts "Let's play again!"
    end
   display_goodbye
  end

  private

  attr_reader :human, :computer

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
    choice = human.choose board
    # FIXME board[choice] = human.symbol
    board[choice].x!
  end

  def computer_move
    choice = computer.choose board
    # FIXME board[choice] = computer.symbol
    board[choice].o!
  end

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
  def who_won?
    return :TIE if board.line_formed.empty?
    sym = board.line_formed.first.first.marker
    if human.symbol == sym
      human
    elsif computer.symbol == sym
      computer
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
