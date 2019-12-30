class Line
  attr_reader :markers, :numbers, :cells

  def initialize(cells_ar)
    @numbers = cells_ar.map(&:number)
    @markers = cells_ar.map(&:marker)
    @cells = cells_ar
  end

  def intersect(other)
  end

  def full?
    !cells.any?(&:empty?)
  end

  def empty?
    cells.all?(&:empty?)
  end

  def empty_cells
    cells.select(&:empty?).map(&:number)
  end

  def filled_cells
    cells.reject(&:empty?)
  end

  def filled
    filled_cells.map(&:number)
  end

  def filled_by(marker)
    cells.select { |c| c.marker == marker }.map(&:number)
  end

  def blocked?(marker)
    !filled.any?(marker)
  end

  def blockable?(marker)
    !full? && !filled_cells.any?(&:marker)
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

  def layed(marker)
    markers.reject(&:nil?).all? marker
  end

  def layed?(marker)
    layed.any?
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
end
