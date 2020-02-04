require 'timeout'
require_relative 'errors.rb'
require_relative 'square.rb'
require_relative 'prompt.rb'

class Player
  @@markers = []
  @@count = 0
  attr_reader :marker, :name

  def self.markers; @@markers; end
  def self.count; @@count; end

  def initialize(marker, name)
    @name = name
    self.marker = marker
    @@count += 1
  end

  def choose(board); end

  def choose_marker; end

  def human?; false; end

  private

  def marker=(marker)
    raise SymbolNilError if marker.nil? || marker.empty?
    raise SymbolReusedError if @@markers.include? marker
    raise ArgumentError, 'marker invalid' unless Square.valid_marker? marker
    @marker = marker
    @@markers << marker
  end
end

class Human < Player
  include Prompt

  def initialize(name = '', marker = '')
    name = name.empty? ? ask_name : name
    marker = marker.empty? ? ask_marker(name) : marker
    super marker, name
  end

  def choose(board)
    choices = board.unmarked_squares
    msg = "Please pick square #{choices.joinor}: "
    options = choices.map(&:to_s)
    ask_options(msg, options).to_i
  end

  def human?; true; end

  private

  def ask_name
    msg = "What's your name? "
    ask_word(msg).capitalize
  end

  def ask_marker(name)
    loop do
      msg = "#{name}, what marker would you like to use? "
      input = ask_word(msg)[0]
      break input unless Player.markers.include?(input)
      puts "#{input} is invalid."
    end
  end
end

class Computer < Player
  def initialize
    super choose_marker, choose_name
  end

  def choose(board)
    intelligent_move board
  end

  protected

  def choose_name
    icao_alphabet.sample + icao_alphabet.sample + "(AI)"
  end

  def icao_alphabet
    %w(Alfa Bravo Charlie Delta Echo Foxtrot Golf Hotel India Juliett
       Kilo Lima Mike November Oscar Papa Quebec Romeo Sierra Tango
       Uniform Victor Whiskey X-ray Yankee Zulu)
  end

  def choose_marker
    taken = Player.markers.map(&:capitalize)
    loop do
      choice = ('A'..'Z').to_a.sample
      break choice if !taken.include? choice
    end
  end

  # return choices(Integers 1..9) based on inspecting the board state
  def intelligent_move(board)
    offensive(board) || defensive(board) || random(board)
  end

  def random(board)
    center = board.center_square
    return center if board[center].nil?
    board.unmarked_squares.sample
  end

  # defends against immediate threat
  # 2 opponent markers present
  # in: board
  # out: square number
  def defensive(board)
    board.at_risk marker
  end

  def offensive(board)
    board.at_chance marker
  end
end

class Analyzing1Computer < Computer
  attr_reader :capture_score, :defend_score

  def initialize; super; end

  def choose(board)
    move_scores(board).max { |a, b| a[1] <=> b[1] }[0]
  end

  protected

  def move_scores(board)
    board.unmarked_squares.map do |move|
      [move, score(board.copy, move, marker)]
    end
  end

  def score(board, move, marker)
    # ensure capture score is set once
    # NOTE: assuming board size is consistent,
    # and not a new board of different size
    @defend_score ||= board.win_length**3
    @capture_score ||= defend_score * 2

    total board.lines_involved(move), marker
  end

  private

  def total(involved, marker)
    [involved.any? { |x| x.win_chance? marker } ? capture_score : 0,
     involved.count { |x| x.at_risk? marker }.positive? ? defend_score : 0,
     involved.count { |x| x.blockable? marker } * 3,
     involved.count { |x| x.buildable? marker } * 2,
     involved.count(&:empty?)].sum
  end
end

if __FILE__ == $PROGRAM_NAME
end
