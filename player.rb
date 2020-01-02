require_relative 'errors.rb'

class Player
  @@markers = []
  attr_reader :marker, :name

  def self.markers; @@markers; end

  def initialize(marker, name)
    @name = name
    self.marker = marker
  end

  def choose(board); end

  def choose_marker; end

  def human?; false; end

  private

  def marker=(marker)
    raise SymbolNilError if marker.nil? || marker.empty?
    raise SymbolReusedError if @@markers.include? marker
    @marker = marker[0]
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
      input = gets.chomp.strip[0]
      break input unless input.empty? || Player.markers.include?(input)
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

  private

  def choose_name
    %w(Alpha Bravo Charlie Delta Echo).sample.prepend 'AI_'
  end

  def choose_marker
    taken = Player.markers.map(&:capitalize)
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
    return 5 if board[5].nil?
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
