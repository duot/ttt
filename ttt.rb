require 'pry'
require_relative 'board.rb'
require_relative 'player.rb'
require_relative 'utility.rb'

class TTTGame
  def initialize(
    board: Board.new(3, 3),

    # Array of Player instances, ordered by first to move
    players: [Human.new, MaximizingComputer.new],
    winning_score: 5,

    # TODO add option to surrender
    # TODO add early draw
    # potentially infinite: will add rounds until player reach winning_score
    rounds_limit: nil
  )

    @board = board
    # players is an arr, 0 indexed
    @players = players
    @current_player = 0
    @winning_score = winning_score.abs
    clear
    display_welcome
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

  attr_reader :board, :score, :winning_score, :players
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
      break if any_score?(winning_score)
      reset
    end
  end

  # return true if any player has @score sc
  def display_score
    puts "SCORE:   "
    (0...players.count).each do |idx|
      puts "\t#{players[idx].name}:\t#{score[idx]} "
    end
    puts
  end

  def any_score?(sc)
    @score.value? sc
  end

  def keep_score(who)
    @score[who] += 1 if who
  end

  def reset_score
    @score = Hash.new(0)
  end

  def current_player_moves
    display_player current_player
    player_move current_player
    @current_player = next_player
  end

  def display_player(current)
    puts "It is #{players[current].name}'s turn."
  end

  # NOTE assumption made about the order of player turns
  def next_player
    np = current_player + 1
    players[np] ? np : 0
  end

  def human_turn?; players[current_player].human?; end

  def reset
    board.reset
    clear
    @current_player = 0
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

  def player_move(player_idx)
    p = players[player_idx]
    choice = p.choose(board.copy)
    board[choice] = p.marker
  end

  def display_result(winner)
    clear_screen_and_display_score_and_board
    if winner
      puts "#{players[winner].name} won."
    else
      puts "It's a draw."
    end
    puts
  end

  def who_won?
    return if board.winning_marker.nil?
    m = board.winning_marker

    # select player, q, with marker m
    q = players.select { |p| p.marker == m }
    players.index *q
  end

  def describe_setup
    puts "describe setup TODO"
  end

  def display_welcome
    puts "Welcome #{players.map(&:name).joinor 'and'}."
    describe_setup
    puts
  end

  def display_goodbye
    puts "Thank you for playing Tic Tac Toe. Goodbye."
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

  b = Board.new(3, 3)
  TTTGame.new(
    board: b,
    players: [Human.new, Human.new, MaximizingComputer.new],
    winning_score: 2,
  ).play
end
