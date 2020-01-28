require 'timeout'
require_relative 'errors.rb'
require_relative 'square.rb'

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
  def initialize
    name = ask_name
    marker = ask_marker(name)
    super marker, name
  end

  def choose(board)
    # display choices
    choices = board.unmarked_squares
    choice = nil
    loop do
      print 'Please pick square '
      print choices.joinor
      print ': '
      choice = gets.chomp.to_i
      break choice if choices.include? choice
    end
  end

  def human?; true; end

  private

  def ask_name
    loop do
      print "What's your name? "
      input = gets.chomp.strip
      break input.capitalize unless input.empty?
    end
  end

  def ask_marker(name)
    loop do
      print "#{name}, what marker would you like to use? "
      input = gets.chomp
      next if input.empty?
      break input.strip[0] unless Player.markers.include?(input)
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

class MaximizingComputer < Analyzing1Computer
  TIMEOUT = 5
  def initialize; super; end

  def choose(board)
    Timeout.timeout(TIMEOUT) { return potentially_slow_choose(board) }
  rescue Timeout::Error
    super
  end

  def potentially_slow_choose(board)
    moves = board.unmarked_squares
    all = moves.map do |move|
      [move, minimax(3, board, move, marker, Player.markers.index(marker))]
    end
    all.max { |a, b| a[1] <=> b[1] }[0]
  end

  # player_index cycling simulates multiplayer: 2 or more
  def minimax(depth, board, move, max_marker, player_idx)
    value = score(board, move, Player.markers[player_idx])

    # copy board
    board = board.copy
    board[move] = Player.markers[player_idx]

    # TODO: prioritize win at shallow depth
    return value + depth if (depth == 0) || board.full? || board.line_formed?

    next_player_idx = next_player(player_idx)

    # is maximizing
    # or next 2 players are minimizing
    if max_marker == Player.markers[player_idx] ||
       (max_marker != Player.markers[player_idx] &&
       max_marker != Player.markers[next_player_idx])

      max_val = -Float::INFINITY
      board.unmarked_squares.each do |nxtmove|
        value = minimax(depth - 1, board, nxtmove, max_marker, next_player_idx)
        max_val = [max_val, value].max
      end
      max_val

    # is minimizing, next player is maximizing
    else
      min_val = Float::INFINITY
      board.unmarked_squares.each do |nxtmove|
        value = minimax(depth - 1, board, nxtmove, max_marker, next_player_idx)
        min_val = [min_val, value].min
      end
      min_val
    end
  end

  private

  # cycle next player
  # NOTE: assumptions are made, order relates to player turn
  def next_player(idx)
    nxt = idx.next
    Player.markers[nxt].nil? ? 0 : nxt
  end
end

if __FILE__ == $PROGRAM_NAME
  load 'board.rb'
  b = Board.new 3, 3
  m = MaximizingComputer.new
  a = Analyzing1Computer.new
  # b[2] = m.marker
  puts m.choose b
  b[5] = m.marker
  # b[9] = m.marker
  b[4] = m.marker

  b[1] = a.marker
  b[3] = a.marker
  b[8] = a.marker

  puts b
  puts m.marker
  puts m.choose b
  puts m.score b, 2, m.marker
  puts m.score b, 6, m.marker
end
