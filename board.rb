require_relative 'square.rb'
require_relative 'grid.rb'

class Board
  attr_reader :side, :squares, :lines, :lv, :cv, :rv, :th, :ch, :bh, :dd, :ud
  attr_reader :win_length

  # note: no need for write access for squares hash
  # only read and write once for square marker

  def initialize(side, win_length, squares = {})
    if squares.empty?
      @side = validate_side_length(side)
      @squares = squares
      reset
    else
      @side = validate_side_length(Math.sqrt(squares.count).to_i)
      @squares = copy_squares squares
    end

    @win_length = validate_winning_line_length(win_length)
  end

  def copy
    Board.new side, win_length, copy_squares(squares)
  end

  # we initialize a copy of each Square obj
  # if board is initialized with old(possibly still being used) squares,
  def copy_squares(s)
    s.map { |number, square_obj| [number, square_obj.copy] }.to_h
  end

  def reset
    square_numbers.each { |key| @squares[key] = Square.new(key) }
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
    rs = almost_a_line.select do |line|
      !line.any? marker
    end

    return if rs.empty?
    rs.first.select(&:empty?).first.number
  end

  def at_chance(marker)
    lt = almost_a_line.select do |line|
      line.map(&:marker).any? marker
    end
    return if lt.empty?
    lt.first.select(&:empty?).first.number
  end

  private

  # returns an array of arrays
  # each the length of winning_line_length
  # generate_groups_to_scan
  def groups
    horizontals + verticals + upwards + downwards
  end

  def horizontals
    # select each full groups that are between row-start and row-ends
    square_numbers.each_slice(side).flat_map do |row|
      row.each_cons(win_length).to_a
    end
  end

  def verticals
    v = square_numbers.each_slice(side).to_a.transpose
    v.flat_map { |col| col.each_cons(win_length).to_a }
  end

  def downwards
    *even_slice, extra = square_numbers.each_slice(side + 1).to_a

    # trim the extra number, transpose, and add it back to first row
    first_row, *rest = even_slice.transpose
    groups = rest.unshift(first_row + extra)

    # reject those row end squares in the middle of the group
    groups
      .select { |line| line[0..-2] == line[0..-2] - row_end_squares }
      .flat_map { |g| g.each_cons(win_length).to_a }
  end

  def upwards
    starts = row_start_squares | col_end_squares
    ends = col_start_squares | row_end_squares

    groups = starts.map do |n|
      line = []
      loop do
        line << n
        break line if ends.include?(n) || n < 1
        n -= (side - 1)
      end
    end

    groups
      .reject { |line| line.size < win_length }
      .flat_map { |line| line.each_cons(win_length).to_a }
  end

  # array of numbers that are on the board
  def square_numbers
    (1..side * side).to_a
  end

  def row_start_squares
    square_numbers.each_slice(side).map(&:first)
  end

  def col_start_squares
    square_numbers.first side
  end

  # array of squares that are on the end of grid rows
  def row_end_squares
    square_numbers.each_slice(side).map(&:last)
  end

  def col_end_squares
    square_numbers.last side
  end

  def almost
    almost_a_line
  end

  # between 3 and side
  def validate_winning_line_length(len)
    unless len >= 3 && len <= side
      raise ArgumentError, "Length must be >= 3 and <= #{side}."
    end
    len
  end

  # square board side must be odd, starting up from 3
  def validate_side_length(side)
    raise NotImplementedError, 'Board size > 15 is not supported.' if side > 15

    return side if side.odd? && side >= 3
    raise ArgumentError, 'Side length must be odd and >= 3'
  end

  # a line with two+ same markers and 1 empty square
  # out: lines
  def almost_a_line
    lines.select do |line|
      markers = line.map(&:marker)
      markers.count(&:nil?) == 1 && markers.uniq.count == win_length - 1
    end
  end

  # accessor of named squares
  # left_vertical, center_vertical, right_vertical, etc
  def lines
    groups.map { |g| liner(*g) }
  end

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
  # test board display at side length 3..9

  b = Board.new 5, 4
  puts b
end