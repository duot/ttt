require_relative 'tttgame.rb'
require_relative 'display.rb'
require_relative 'prompt.rb'

class Game
  include Display
  include Prompt

  def initialize
    welcome
    prompt_classic ? classic : custom
  end

  private

  def welcome
    clear
    puts "Welcome to Tic Tac Toe game setup."
  end

  def prompt_classic
    choice = loop do
      print "What game would you like to play, (1)classic or (2)custom? "
      choice = gets.chomp.downcase[0..1]
      break choice if ['1', '2'].include? choice
      clear
      puts "Please enter '1' or '2'."
    end
    choice == '1'
  end

  def classic
    TTTGame.new.play
  end

  def custom
    # for each pair of ky_symbol, and values
    # init a new custome TTTGame
    TTTGame.new(setup).play
  end

  def setup
    bs = board_setup
    { board: Board.new(bs[:board_size], bs[:win_length]),
      players: create_players(player_count(bs[:win_length])),
      winning_score: win_score,
      rounds_limit: max_rounds }
  end

  def humans
    msg = "Please enter the number of human players: "
    condition = proc { |c| c >= 0 && c <= 3 }
    ask_int msg, condition
  end

  def computers
    msg = "Please enter the number of computer players: "
    cond = proc { |c| c >= 0 && c <= 3 }
    ask_int msg, cond
  end

  def player_count(win_len)
    loop do
      puts "Player count is limited to #{win_len}"
      h = humans
      c = computers
      e = h + c
      break { humans: h, computers: c } if e >= 2 && e <= win_len
    end
  end

  def create_humans(n)
    puts "Let's add #{n} human players. "
    Array.new(n) do |i|
      puts "Human player #{i.next}"
      Human.new
    end
  end

  def create_computers(n)
    Array.new(n) { MaximizingComputer.new }
  end

  def create_players(humans:, computers:)
    create_humans(humans) + create_computers(computers)
  end

  # highest score after rounds# wins
  # otherwise draw
  def max_rounds
    msg = "Please enter the maximum number of rounds: "
    cond = proc { |choice| choice.positive? }
    ask_int msg, cond
  end

  def win_score
    msg = "Please enter the top score to win the game: "
    cond = proc { | choice| choice.positive? }
    ask_int msg, cond
  end

  def board_setup
    msg = "Please select board size.
It must be odd and between 3 up to 15: "
    cond = proc { |choice| choice.odd? && choice >= 3 && choice <= 15 }
    board_size = ask_int(msg, cond)

    length = board_size == 3 ? 3 : win_length(board_size)

    { win_length: length,
      board_size: board_size }
  end

  def win_length(max)
    msg = "Please select the length of the winning line.
It must be between 3 and #{max}: "
    cond = proc { |choice| choice.between? 3, max }
    ask_int msg, cond
  end
end

if __FILE__ == $PROGRAM_NAME
  Game.new
end
