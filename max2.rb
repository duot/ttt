require 'timeout'
require_relative 'player.rb'

class Max2 < Analyzing1Computer
  def initialize; super; end

  # minimax when 2 players
  # maximax when 3+
  def choose(board)
    Player.count > 2 ? super : minimaxing(board)
  end

  def minimaxing(board)
    @oppo = @@markers.reject { |m| m == marker }.first

    board
      .unmarked_squares
      .map { |move| [move, minimax(6, board, move, true)] }
      .max_by(&:last)
      .first
  end

  private

  attr_reader :oppo

  def minimax(depth, board, move, ismax)
    m = ismax ? marker : oppo

    board = board.copy
    value = evaluate(board, move, m)

    # prefer win at shallower depth
    value = increase_magnitude(value, depth)

    board[move] = m
    return value if terminal?(board, depth)

    if ismax
      board.unmarked_squares
           .map { |mmove| minimax(depth - 1, board, mmove, false) }
           .min

    else
      board.unmarked_squares
           .map { |mmove| minimax(depth - 1, board, mmove, true) }
           .max
    end
  end

  # increase the (distance from zero) by depth
  # if negative, val - depth
  # if positive, val + depth
  def increase_magnitude(val, depth)
    return val if val.zero?
    val.positive? ? (val + depth) : (val - depth)
  end

  def terminal?(board, depth)
    (depth == 0) || board.full? || board.line_formed?
  end

  # scores only -1, 0 or 1
  # -1 if in favor of oppo
  #  1 if in favor of player
  #  0 otherwise
  # NOTE defending is 0 for both players
  def evaluate(board, move, m)
    i = in_favor(m, board, move)

    m == marker ? i : (i * -1) # reverse sign if oppo
  end

  # win is 1
  # los is -1
  # other is 0
  def in_favor(m, board, move)
    win_chance = board.at_chance(m)
    risk = board.at_risk(m)

    # chance to win and din't take
    return -1 if win_chance && win_chance != move
    return 1 if win_chance == move

    # chance to loose and doesn't defen
    return -1 if risk && risk != move

    # when risk == move then 0
    0
  end
end

if __FILE__ == $PROGRAM_NAME
  require_relative 'tttgame.rb'
  require_relative 'board.rb'

  b = Board.new(3, 3)
  m = Max2.new
  mark = m.marker
  h = Human.new('TesterMcTestFace', 'T')

  b[1] = 'T'
  b[2] = mark

  op = {
    board: b,
    players: [h, m],
    draw_limit: 2
  }
  TTTGame.new(op).play
end
