require 'pry'

class Grid
  def initialize(matrix, padding: 1, display_grid_numbers: true)
    @display_grid_numbers = display_grid_numbers
    @side_len = matrix.first.size
    @count = matrix.flatten.count
    @matrix = matrix
  end

  def to_s
    gridder(matrix.flatten, (1..count).to_a, side_len).join
  end

  private

  attr_reader :matrix, :count, :side_len, :display_grid_numbers

  def gridder(input_ar, grid_numbers, side_length)
    raise ArgumentError.new "#{input_ar} size must be odd" if !input_ar.size.odd?
    raise ArgumentError.new "#{input_ar} size must be 3 or more" if input_ar.size <= 3

    z = input_ar.each_slice(side_length).zip grid_numbers.each_slice(side_length)
    row_elems = z.map { |x, y| row_elements x, y }
    grid = row_elems.map { |e| rower e }
    grid << column_ender(side_length)
  end

  def cell(x, n)
    raise ArgumentError.new("#{x} is too long.") unless x[1].nil?

    cell_number = display_grid_numbers ? format("%-4.3s", n) : "|   "
    [
      "+---",
      cell_number,
      "| #{x} ",
      "|   "
    ]
  end

  def row_ender
    [
      '+',
      '|',
      '|',
      '|'
    ]
  end

  def column_ender(len)
    "+---" * len + '+'
  end

  def row_elements(ar_x, ar_n)
    raise ArgumentError.new("Mismatching sizes") if ar_x.size != ar_n.size

    cells = (0...ar_x.size).map do |i|
      cell(ar_x[i], ar_n[i])
    end

    cells << row_ender
  end

  def rower(row_elems)
    raise ArgumentError, "Element columns size mismatch" if row_elems.map(&:size).uniq == 1

    row, *rest = row_elems
    rest.each do |cell|
      (0...cell.size).each { |i| row[i] << cell[i] }
    end

    row.join("\n") + "\n"
  end
end

if __FILE__ == $PROGRAM_NAME
  g3 = Grid.new [['x', 'x', 'x'],
                 ['x', 'o', 'x'],
                 ['x', 'x', 'x']], display_grid_numbers: false

  g5 = Grid.new [['x', 'x', 'x', 'x', 'x'],
                 ['x', 'x', 'o', 'x', 'x'],
                 ['x', 'o', 'o', 'o', 'x'],
                 ['x', 'x', 'o', 'x', 'x'],
                 ['x', 'x', 'x', 'x', 'x']]
  binding.pry
  puts g3.to_s
  puts g5.to_s
end
