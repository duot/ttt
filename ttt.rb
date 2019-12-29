require 'pry'
require_relative 'board.rb'
require_relative 'player.rb'

class TTTGame
  def initialize(board: Board.new, winning_score: 5, who_first: 'choose')
    clear
    display_welcome
    @human = Human.new
    @computer = Computer.new
    @board = board
    @first_player = choose_first_player(who_first)
    @current_player = first_player
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

  attr_reader :human, :computer, :board, :score, :winning_score, :first_player
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

  def choose_first_player(who_first)
    case who_first
    when 'choose' then choose_player
    when 'human' then human
    when 'computer' then computer
    end
  end

  def choose_player
    choice = loop do
      print "Who should go first? (computer/human) (c/h): "
      choice = gets.chomp[0].downcase
      break choice if ['c', 'h'].include? choice
    end
    { 'c' => computer, 'h' => human }[choice]
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
    @current_player = first_player
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

  TTTGame.new(board: Board.new(5, 5), winning_score: 1).play
end
