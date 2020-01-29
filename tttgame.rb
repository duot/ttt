require 'pry'
require_relative 'board.rb'
require_relative 'player.rb'
require_relative 'utility.rb'
require_relative 'display.rb'
require_relative 'prompt.rb'

class TTTGame
  include Display
  include Prompt

  def initialize(
    board: Board.new(3, 3),

    # Array of Player instances, ordered by first to move
    players: [Human.new, MaximizingComputer.new],
    winning_score: 5,

    # TODO add option to surrender
    # TODO add early draw
    draw_limit: Float::INFINITY
  )

    @board = board
    # players is an arr, 0 indexed
    @players = players
    @current_player = 0
    @winning_score = winning_score.abs
    @draw_limit = draw_limit
    @draws = 0
    clear
    display_welcome
    reset_score
  end

  def play
    loop do
      play_game
      display_result(who_won?)
      break unless play_again?
      display_play_again
      reset
    end
    display_goodbye
  end

  private

  attr_reader :board, :score, :winning_score, :players, :draw_limit
  attr_accessor :current_player, :draws

  def play_game
    reset_score
    play_round while !any_score?(winning_score) && draws < draw_limit
  end

  def play_round
    display_score_and_board
    loop do
      current_player_moves
      break if board.full? || board.line_formed?
      clear_screen_and_display_score_and_board
    end
    track_score_and_draws who_won_round?
    reset
  end

  def display_score
    puts "SCORE: "
    (0...players.count).each do |idx|
      pl = players[idx]
      puts "\t#{pl.marker} | #{pl.name.ljust 32}#{score[idx]} "
    end
    puts
  end

  def any_score?(sc)
    @score.value? sc
  end

  def keep_score(who)
    @score[who] += 1 if who
  end

  def track_score_and_draws(who)
    if who
      keep_score who
      @draws = 0
    else
      @draws += 1
    end
  end

  def reset_score
    @score = Hash.new(0)
  end

  def who_won?
    score.key winning_score
  end

  def current_player_moves
    display_player current_player
    player_move current_player
    @current_player = next_player
  end

  def display_player(current)
    p1 = players[current]
    puts "It is #{p1.marker}, #{p1.name}'s turn."
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

  def display_info
    #puts "Mark #{board.win_length} in a row to score a point."
    #puts "Score #{winning_score} points to win."
    puts "DRAW:\t#{draws} of #{draw_limit}"
  end

  def display_score_and_board
    display_info
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
    msg = 'Do you want to play again? (y/n) '
    choice = ask_options msg, ['y', 'n']
    choice == 'y'
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
    elsif draws >= draw_limit
      puts "Maximimum successive draws reached."
    else
      puts "It's a draw."
    end
    puts
  end

  def who_won_round?
    return if board.winning_marker.nil?
    m = board.winning_marker

    # select player, q, with marker m
    q = players.select { |p| p.marker == m }
    players.index(*q)
  end

  def describe_setup
    puts "It takes #{board.win_length} markers in a row to win each round,
and it takes #{winning_score} points to win the game. Successive draws are
limited to #{draw_limit}."
  end

  def display_welcome
    puts "Welcome #{players.map(&:name).joinor 'and'} to a game of Tic Tac Toe."
    puts
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
  TTTGame.new.play
end
