# minimax algo
[source](https://www.geeksforgeeks.org/minimax-algorithm-in-game-theory-set-3-tic-tac-toe-ai-finding-optimal-move/)

function minimax(board, depth, ismax)
  if current board state is terminal
    return value

  if ismax
    best-val = -Infinity
    for each move in board
      value = minimax(board, depth+1, false)
      best-val = max( best-val, value)
    return best-val

  else
    best-val = Infinity
    for each move in board
      value = minimax(board, depth+1, true)
      best-val = min( best-val, value)
    return best-val

