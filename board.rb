require_relative 'square.rb'
require_relative 'grid.rb'
require_relative 'line.rb'

class Board
  attr_reader :side, :squares, :lines, :win_length

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

  def to_s; grid; end

  def [](key)
    squares[key].marker
  end

  def []=(key, marker)
    squares[key].marker = marker
  end

  def square_numbers
    (1..side * side).to_a
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

  def at_risk(marker)
    risk, _ = lines.select { |l| l.at_risk? marker }
    risk.nil? ? return : risk.empty_cells[0]
  end

  def at_chance(marker)
    chance, _ = lines.select { |l| l.win_chance? marker }
    chance.nil? ? return : chance.empty_cells[0]
  end

  # return [] of empty squares
  # grid indexed by int 1..9, left..right, top..bottom
  def unmarked_squares
    squares.select { |_, val| val.empty? }.keys
  end

  def lines
    squares_at_lines.map { |squares_at_line| Line.new squares_at_line }
  end

  def lines_with_empty(number)
    lines.select { |l| l.empty_cell? number }
  end

  def center_square
    side.next / 2
  end

  private

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
    starts = col_start_squares | row_start_squares
    ends = row_end_squares | col_end_squares

    groups = starts.map do |n|
      line = []
      loop do
        line << n
        break line if ends.include?(n) || n < 1
        n += (side + 1)
      end
    end

    groups
      .reject { |line| line.size < win_length }
      .flat_map { |line| line.each_cons(win_length).to_a }
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

  def squares_at_lines(g = groups)
    g.map { |g| squares_at(*g) }
  end

  def squares_at(*args)
    squares.values_at(*args)
  end

  def line_formed
    squares_at_lines.select do |line|
      square1 = line.first
      next if square1.empty?
      line.all? { |square| square.marker == square1.marker }
    end
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
