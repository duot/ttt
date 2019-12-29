require_relative 'errors.rb'

class Square
  EMPTY = ' '
  MARKER_LENGTH = 1
  MARKERS_ALLOWED = /[[:graph:]]+/

  attr_reader :marker, :number

  def initialize(number, marker = nil)
    @marker = marker.nil? ? marker : validate(marker)
    @number = number
  end

  def copy
    Square.new number, marker
  end

  def empty?; !marker; end

  def marker=(marker)
    validate(marker)
    raise SquareAlreadyMarkedError if !empty?
    @marker = marker
  end

  def symbol
    marker || Square::EMPTY
  end

  def to_s; symbol; end

  private

  def validate(marker)
    raise ArgumentError, 'Too long' if marker.size != MARKER_LENGTH
    raise ArgumentError, 'Invalid marker' unless MARKERS_ALLOWED.match? marker
    marker
  end
end
