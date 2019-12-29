require_relative 'errors.rb'

class Square
  EMPTY = ' '

  attr_reader :marker, :number

  def initialize(number, marker = nil)
    @marker = marker
    @number = number
  end

  def copy
    Square.new number, marker
  end

  def empty?; !marker; end

  def marker=(marker)
    raise SquareAlreadyMarkedError if !empty?
    @marker = marker
  end

  def symbol
    marker || Square::EMPTY
  end

  def to_s; symbol; end
end
