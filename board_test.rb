require 'test/unit'
require_relative './board.rb'

class BoardTest < Test::Unit::TestCase
  def test_board_scaling
    assert [3, 5, 7, 9].map { |s| Board.new(3, side: s) }
  end

  def test_validate_board_size_on_initialize
    assert_raise(ArgumentError) do
      Board.new 3, side: 2
    end
  end

  def test_board_size_limit
    assert_raise NotImplementedError do
      Board.new 3, side: 11
    end
  end
end
