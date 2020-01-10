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
    marker = ask_marker
    super marker, name
  end

  def choose(board)
    # display choices
    choices = board.unmarked_squares
    choice = nil
    loop do
      print 'Please pick square '
      print joinor(choices)
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

  def ask_marker
    loop do
      print "What marker would you like to use? "
      input = gets.chomp
      next if input.empty?
      break input.strip[0] unless Player.markers.include?(input)
      puts "#{input} is invalid."
    end
  end

  # returns a string of a collection, joined by separators and space
  # and a conjuction
  def joinor(coll)
    case coll.count
    when 1 then coll[0].to_s
    when 2 then "#{coll[0]} or #{coll[1]}"
    else
      *body, tail = coll
      "#{body.join(', ')} or #{tail}"
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
    icao_alphabet.sample + icao_alphabet.sample
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
  def initialize; super; end

  def choose(board)
    move_scores(board).max { |a, b| a[1] <=> b[1] }[0]
  end

  def move_scores(board)
    board.unmarked_squares.map { |move| [move, score(move, board.copy)] }
  end

  def score(move, board)
    involved = board.lines_involved move

    total = 0

    # return inf if immediate win is available
    return Float::INFINITY if board.at_chance move

    risk = involved.count { |x| x.at_risk? marker }
    risk *= board.side ** 2
    total += risk

    blockable = involved.count { |x| x.blockable? marker }
    total += blockable * 3

    buildable = involved.count { |x| x.buildable? marker }
    total += buildable * 2

    layable = involved.count(&:empty?)
    total += layable

    # 0, if all lines already blocked
    # 1, if laying a new line/ all lines are empty
    # 2*, build up
    # 3*, block enemy line
    # 9000, deny win
    # Infinity, wins
  end
end

class MaximizingComputer < Computer
  def initialize; super; end

  def choose(board)
    moves = board.unmarked_squares
    all = moves.map { |move| [move, minimax(3, board, move, marker, Player.markers.index(marker)) ] }
    puts all.inspect
    all.max { |a, b| a[1] <=> b[1] }[0]
  end

  # player_index cycling simulates multiplayer: 2 or more
  def minimax(depth, board, move, max_marker, player_idx)
    value = score(board, move, Player.markers[player_idx], max_marker)

    # copy board
    board = board.copy
    board[move] = Player.markers[player_idx]

    return value if (depth == 0) || board.full? || board.line_formed?

    next_player_idx = next_player(player_idx)
    next_player_marker = Player.markers[next_player_idx]

    # is maximizing
    if max_marker == Player.markers[player_idx]

      best_val = -Float::INFINITY
      values = board.unmarked_squares.map do |move|
        value = minimax(depth - 1, board, move, max_marker, next_player_idx)
      end
      # best_val = [best_val, value].max
      best_val = values.max
      best_val

    elsif max_marker != Player.markers[player_idx] && max_marker != Player.markers[next_player_idx]
      best_val == -Float::INFINITY
      values = board.unmarked_squares.map do |move|
        minimax(depth - 1, board, move, max_marker, next_player_idx)
      end
      best_val = values.max

    # is minimizing
    else
      best_val = Float::INFINITY
      values = board.unmarked_squares.map do |move|
        value = minimax(depth - 1, board, move, max_marker, next_player_idx)
        #best_val = [best_val, value].min
      end
      best_val = values.max
      best_val
    end
  end

  def score(board, move, marker, max_marker)
    involved = board.lines_involved move

    total = 0

    # return inf if immediate win is available
    total += 9001 if involved.any? { |x| x.win_chance? marker }

    risk = involved.count { |x| x.at_risk? marker }
    risk *= board.side ** 2
    total += risk

    blockable = involved.count { |x| x.blockable? marker }
    total += blockable * 3

    buildable = involved.count { |x| x.buildable? marker }
    total += buildable * 2

    layable = involved.count(&:empty?)
    total += layable
    marker == max_marker ? total : -total
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
  b = Board.new 3,3
  m = MaximizingComputer.new
  a = Analyzing1Computer.new
  #b[2] = m.marker
  b[5] = m.marker
  #b[9] = m.marker
  b[4] = m.marker

  b[1] = a.marker
  b[3] = a.marker
  b[8] = a.marker
  
  puts b
  puts m.choose b
  puts m.score b, 6, m.marker, m.marker
end
