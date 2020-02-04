require_relative 'tttgame.rb'
require_relative 'display.rb'
require_relative 'prompt.rb'
require_relative 'max2.rb'

class Game
  include Display
  include Prompt

  def initialize
    welcome
    play prompt_options.to_i
  end

  private

  VALID_SIZES = (3..15).select(&:odd?)

  def welcome
    clear
    puts "Welcome to Tic Tac Toe game setup."
    friendly_note
  end

  def friendly_note
    puts <<_

    Please note that the game display is currently unable to scale with the screen size. Please press Ctrl + c or Cmd + c to terminate.

_
  end

  def prompt_options
    options = %w(1 2 3 4 5 6 7 8)
    msg = "What game would you like to play?
    1  human vs computer
    2  human vs human
    3  computer vs computer
    4  custom
    5  3x3, 3 bots
    6  5x5, 5 bots, 4 in a row
    7  7x7, 7 bots, 5 in a row
    8  all 15 bots
    9  me-against-the-swarm

Please enter #{options.joinor}: "

    ask_options(msg, options)
  end

  def play(op)
    codes = {
      1 => :classic,
      2 => :humanvhuman,
      3 => :cvc,
      4 => :custom,
      5 => :three,
      6 => :five,
      7 => :seven,
      8 => :bots,
      9 => :swarm
    }
    method(codes[op]).call
  end

  def setter(*args)
    size, row, humans, computers, score, draw, *other = args
    op = {
      board: Board.new(size, row),
      players: create_players(humans: humans, computers: computers)
    }
    op[:draw_limit] = draw if draw
    op[:winning_score] = score if score
    other.any? ? op.merge(*other) : op
  end

  def seven; init setter(7, 5, 0, 7, nil, 1); end

  def five; init setter(5, 4, 0, 5, nil, 3); end

  def three; init setter(3, 3, 0, 3, nil, 5, { display_delay: 1 }); end

  def humanvhuman; init setter(3, 3, 2, 0, nil, nil); end

  def cvc; init setter(3, 3, 0, 2, nil, 3, { display_delay: 0.5 }); end

  def init(op)
    TTTGame.new(op).play
  end

  def swarm
    op = {
      board: Board.new(15, 4),
      players: create_players(humans: 1, computers: 14),
      draw_limit: 1
    }
    TTTGame.new(op).play
  end

  def bots
    op = {
      board: Board.new(15, 4),
      players: create_computers(15),
      draw_limit: 1
    }
    TTTGame.new(op).play
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
      draw_limit: max_draw }
  end

  def humans(win_len)
    msg = "Please enter the number of human players (0 up to #{win_len}): "
    condition = proc { |c| c >= 0 && c <= win_len }
    ask_int msg, condition
  end

  def computers(win_len)
    msg = "Please enter the number of computer players (0 up to #{win_len}): "
    cond = proc { |c| c >= 0 && c <= win_len }
    ask_int msg, cond
  end

  def player_count(win_len)
    loop do
      puts "The total number of players is limited to #{win_len}."
      h = humans(win_len)
      available = win_len - h
      c = available.zero? ? 0 : computers(available)
      total = h + c
      break { humans: h, computers: c } if total >= 2 && total <= win_len
    end
  end

  def create_humans(n)
    puts "Let's add #{n} human players. " if n.positive?
    Array.new(n) do |i|
      puts "Human player #{i.next}"
      Human.new
    end
  end

  def create_computers(n)
    Array.new(n) { Max2.new }
  end

  def create_players(humans:, computers:)
    create_humans(humans) + create_computers(computers)
  end

  def max_draw
    msg = "Please enter the maximum number of successive draw: "
    cond = proc { |choice| choice.positive? }
    ask_int msg, cond
  end

  def win_score
    msg = "Please enter the top score to win the game: "
    cond = proc { |choice| choice.positive? }
    ask_int msg, cond
  end

  def board_setup
    msg = "Please select board size #{VALID_SIZES.joinor}: "
    board_size = ask_options(msg, VALID_SIZES.map(&:to_s)).to_i

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
