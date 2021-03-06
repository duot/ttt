class Grid
  def initialize(flat_matrix, side_len, padding: 1, display_grid_numbers: true)
    @display_grid_numbers = display_grid_numbers
    @side_len = side_len
    @count = flat_matrix.size
    @flat_matrix = flat_matrix
    @padding = padding
  end

  def to_s
    gridder(flat_matrix, (1..count).to_a, side_len).join
  end

  private

  attr_reader :flat_matrix, :count, :side_len, :display_grid_numbers, :padding

  def gridder(input_ar, grid_numbers, side_len)
    raise ArgumentError, "#{input_ar} size must be odd" if !input_ar.size.odd?
    if input_ar.size <= 3
      raise ArgumentError, "#{input_ar} size must be 3 or more"
    end

    z = input_ar.each_slice(side_len).zip grid_numbers.each_slice(side_len)
    row_elems = z.map { |x, y| row_elements x, y }
    grid = row_elems.map { |e| rower e }
    grid << column_ender(side_len)
  end

  def cell(x, n)
    raise ArgumentError, "#{x} is too long." unless x[1].nil?

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
    raise ArgumentError, 'Mismatching sizes' if ar_x.size != ar_n.size

    cells = (0...ar_x.size).map do |i|
      cell(ar_x[i], ar_n[i])
    end

    cells << row_ender
  end

  def rower(row_elems)
    if row_elems.map(&:size).uniq == 1
      raise ArgumentError, "Element columns size mismatch"
    end

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
                 ['x', 'x', 'x']].flatten, 3, display_grid_numbers: false

  g5 = Grid.new [['x', 'x', 'x', 'x', 'x'],
                 ['x', 'x', 'o', 'x', 'x'],
                 ['x', 'o', 'o', 'o', 'x'],
                 ['x', 'x', 'o', 'x', 'x'],
                 ['x', 'x', 'x', 'x', 'x']].flatten, 5
  puts g3.to_s
  puts g5.to_s
end
