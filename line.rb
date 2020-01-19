class Line
  attr_reader :markers, :numbers, :cells

  def initialize(cells_ar)
    @cells = validate cells_ar
    @numbers = cells_ar.map(&:number)
    @markers = cells_ar.map(&:marker)
  end

  def empty_cell?(number)
    empty_cells.include?(number)
  end

  def intersect(other); end

  def full?
    !cells.any?(&:empty?)
  end

  def empty?
    cells.all?(&:empty?)
  end

  def empty_cells
    cells.select(&:empty?)
  end

  def empty_cell_numbers
    empty_cells.map(&:number)
  end

  def filled_cells
    cells.reject(&:empty?)
  end

  def filled_cell_numbers
    filled_cells.map(&:number)
  end

  def filled_by_numbers(marker)
    cells.select { |c| c.marker == marker }.map(&:number)
  end

  # line already contested, no possible win
  # Note: line size is win_length
  # exists 2+ unique markers == blocked
  def blocked?
    markers.reject(&:nil?).uniq.count > 1
  end

  # adding this marker, will block the line
  def blocks?(marker)
    !blocked? && blockable?(marker)
  end

  # not empty, not full, not filled by marker
  # dominated by other marker
  def blockable?(marker)
    !empty? && !full? && !blocked? &&
      filled_cells.none? { |c| c.marker == marker }
  end

  # contains marker, not blocked by other markers
  def buildable?(marker)
    !empty? && filled_cells.all? { |c| c.marker == marker }
  end

  # 1 empty with all others are marked with same but by other marker
  def at_risk?(marker)
    first, *rest = filled_cells.map(&:marker)

    return false if marker == first
    empty_cells.count == 1 && rest.all?(first)
  end

  def win_chance?(marker)
    empty_count = 0
    cells.each do |c|
      m = c.marker
      if m.nil?
        empty_count += 1
        next
      end
      return false if c.marker != marker
    end

    empty_count == 1 ? true : false
  end

  def won?(marker)
    markers.all? marker
  end

  def formed?
    first, *rest = markers
    return false if first.nil?
    rest.all? first
  end

  def to_a
    numbers
  end

  def to_numbers
    numbers
  end

  def to_markers
    markers
  end

  private

  def validate(cells)
    raise ArgumentError, 'cells cant be nil' if cells.nil?
    raise ArgumentError, 'cells cant be empty' if cells.empty?
    cells
  end
end
