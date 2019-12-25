require_relative 'square.rb'
require_relative 'grid.rb'

class Board
  attr_reader :side, :squares, :lines, :lv, :cv, :rv, :th, :ch, :bh, :dd, :ud

  # note: no need for write access for squares hash
  # only read and write once for square marker

  def initialize(squares = {}, winning_line_length, side: 3)
    @side = validate_side_length(side)
    @squares = squares
    reset if squares.empty?
  end

  def reset
    (1..side*side).each { |key| @squares[key] = Square.new(key) }
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
    squares[key].marker
  end

  def []=(key, symbol)
    squares[key].marker = symbol
  end

  # return [] of empty squares
  # grid indexed by int 1..9, left..right, top..bottom
  def unmarked_squares
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

  def at_chance(marker)
    lt = lines_with_two_marks.select do |line|
      line.map(&:marker).any? marker
    end
    return if lt.empty?
    lt.first.select(&:empty?).first.number
  end

  private

  # square board side must be odd, starting up from 3
  def validate_side_length(side)
    raise NotImplementedError.new 'Board size > 9 is not supported.' if side > 9

    return side if side.odd? && side >= 3
    raise ArgumentError.new('Side length must be odd and >= 3')
  end

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
    Grid.new(squares.values.map(&:symbol), side).to_s
  end
end

if __FILE__ == $PROGRAM_NAME
  ###
  # test board side length 3..9
  puts true if [3, 5, 7, 9].map { |s| Board.new(3, side:s) }

  begin
    Board.new 3, side:2
  rescue ArgumentError
    puts true
  end

  # test board display at side length 3..9
  puts Board.new 3, side: 5
  puts Board.new 3
  puts Board.new 3, side: 9

  begin
    Board.new 3, side: 11
  rescue NotImplementedError
    puts true
  end

  # test almost_a_line

  # test
end
