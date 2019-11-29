require 'pry'

# TODO namespace

class IllegalBoardStateError < RuntimeError; end
class SymbolReusedError < RuntimeError; end
class SquareAlreadyMarkedError < RuntimeError; end
class SymbolNilError < RuntimeError; end

class Square
  EMPTY = ' '

  attr_reader :marker, :number

  def initialize(number, marker = nil)
    @marker = marker
    @number = number
  end

  def empty?; !marker; end

  def marker=(marker)
    raise SquareAlreadyMarkedError if !empty?
    @marker = marker
  end

  def symbol
    marker || Square::EMPTY
  end

  def to_s; symbol; end
end

class Board
  attr_reader :squares, :lines, :lv, :cv, :rv, :th, :ch, :bh, :dd, :ud

  # note: no need for write access for squares hash
  # only read and write once for square marker

  def initialize(squares = {})
    @squares = squares
    reset if squares.empty?
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new(key) }
    nil
  end

  def to_s; grid; end

  def full?
    squares.all? { |_, square| !square.empty? }
  end

  def line_formed?
    line_formed.any?
  end

  def winning_marker
    return if !line_formed?
    line = line_formed.first
    line.first.marker
  end

  def [](key)
    squares[key]
  end

  def []=(key, symbol)
    squares[key].marker = symbol
  end

  # return [] of empty squares
  # grid indexed by int 1..9, left..right, top..bottom
  def unmarked_square_keys
    squares.select { |_, val| val.empty? }.keys
  end

  # at risk if 2 (other)markers present, 1 empty square
  # out: playable empty square number
  def at_risk(marker)
    rs = lines_with_two_marks.select do |line|
      !line.any? marker
    end

    return if rs.empty?
    rs.first.select(&:empty?).first.number
  end

  private

  # a line with two same markers and an empty square
  # out: lines
  def lines_with_two_marks
    lines.select do |line|
      markers = line.map(&:marker)
      markers.count(&:nil?) == 1 && markers.uniq.count == 2
    end
  end

  # accessor of named squares
  # left_vertical, center_vertical, right_vertical, etc
  def lines
    [lv, cv, rv, th, ch, bh, dd, ud]
  end

  def lv; liner 1, 4, 7; end  # left      vertical
  def cv; liner 2, 5, 8; end  # center    vertical
  def rv; liner 3, 6, 9; end  # right     vertical
  def th; liner 1, 2, 3; end  # top       horizontal
  def ch; liner 4, 5, 6; end  # mid       horizontal
  def bh; liner 7, 8, 9; end  # bottom    horizontal
  def dd; liner 1, 5, 9; end  # downward  diagonal
  def ud; liner 7, 5, 3; end  # upward    diagonal

  def line_formed
    lines.select do |line|
      square1 = line.first
      next if square1.empty?
      line.all? { |square| square.marker == square1.marker }
    end
  end

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
  @@symbols = []
  attr_reader :symbol, :name

  def self.symbols; @@symbols; end

  def initialize(symbol, name)
    @name = name
    self.symbol = symbol
  end

  def choose(board); end

  def choose_symbol; end

  private

  def symbol=(symbol)
    raise SymbolNilError if symbol.nil? || symbol.empty?
    raise SymbolReusedError if @@symbols.include? symbol
    @symbol = symbol[0]
    @@symbols << symbol
  end
end

class Human < Player
  def initialize
    name = ask_name
    symbol = ask_symbol
    super symbol, name
  end

  def choose(board)
    # display choices
    choices = board.unmarked_square_keys
    choice = nil
    loop do
      print 'Please pick square '
      print joinor(choices)
      print ': '
      choice = gets.chomp.to_i
      break choice if choices.include? choice
    end
  end

  private

  def ask_name
    loop do
      print "What's your name? "
      input = gets.chomp.strip
      break input.capitalize unless input.empty?
    end
  end

  def ask_symbol
    loop do
      print "What marker would you like to use? "
      input = gets.chomp.strip[0]
      break input unless input.empty? || Player.symbols.include?(input)
      puts "#{input} is invalid."
    end
  end

  # returns a string of a collection, joined by separators and space
  # and a conjuction
  def joinor(coll)
    head, *body, tail = coll
    return head if body.empty?
    return [head, conjunc, body].join ' ' if tail.nil?
    "#{[head, body].join(', ')} or #{tail}"
  end
end

class Computer < Player
  def initialize
    super choose_symbol, choose_name
  end

  def choose(board)
    intelligent_move board
  end

  private

  def choose_name
    %w(Alpha Bravo Charlie Delta Echo).sample.prepend 'AI_'
  end

  def choose_symbol
    taken = Player.symbols.map(&:capitalize)
    loop do
      choice = ['O', 'X'].sample # NOTE limited player count
      break choice if !taken.include? choice
    end
  end

  # return choices(Integers 1..9) based on inspecting the board state
  def intelligent_move(board)
    offensive(board) || defensive(board) || random(board)
  end

  def random(board)
    board.unmarked_square_keys.sample
  end

  # defends against immediate threat
  # 2 opponent markers present
  # in: board
  # out: square number
  def defensive(board)
    board.at_risk symbol
  end

  def offensive(board); end
end

class TTTGame
  def initialize(board = Board.new, winning_score = 5)
    clear
    display_welcome
    @human = Human.new
    @computer = Computer.new
    @board = board
    @current_player = human
    @winning_score = winning_score.abs
    reset_score
  end

  def play
    loop do
      play_round
      display_result(who_won?)
      break unless play_again?
      display_play_again
      reset
    end
    display_goodbye
  end

  private

  attr_reader :human, :computer, :board, :score, :winning_score
  attr_accessor :current_player

  def play_round
    reset_score
    loop do
      display_score_and_board
      loop do
        current_player_moves
        break if board.full? || board.line_formed?
        clear_screen_and_display_score_and_board # if human_turn?
      end
      keep_score who_won?
      break if score?(winning_score)
      reset
    end
  end

  # return true if any player has @score sc
  def display_score
    print "SCORE:   "
    @score.each do |player, sc|
      print "#{player.name}: #{sc}   "
    end
    puts
  end

  def score?(sc)
    @score.value? sc
  end

  def keep_score(who)
    case who
    when human then @score[human] += 1
    when computer then @score[computer] += 1
    end
  end

  def reset_score
    @score = { human => 0, computer => 0 }
  end

  def current_player_moves
    squares_state_snapshot = board.squares.map(&:inspect)
    if human_turn?
      human_move
      @current_player = computer
    else
      computer_move
      @current_player = human
    end

    # delta is the amount of squares changed
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
    @current_player = human
  end

  def display_board
    puts board
    puts
  end

  def display_score_and_board
    display_score
    display_board
  end

  def clear_screen_and_display_score_and_board
    clear
    puts
    display_score_and_board
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
    board[choice] = human.symbol
  end

  def computer_move
    # TODO raise error if computer used other marker
    choice = computer.choose board
    board[choice] = computer.symbol
  end

  def display_result(winner)
    clear_screen_and_display_score_and_board
    case winner
    when human
      puts "#{human.name}, you won."
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
    puts "Thank you for playing Tic Tac Toe. Goodbye #{human.name}."
    puts
  end
end

#########   #########   #########

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
  # p b.full? nil, 3
  # p b.line_formed?
  # p b.line_formed

  TTTGame.new(Board.new, 3).play
end
