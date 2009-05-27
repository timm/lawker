### make_move(board, color)
 # Given a "board" and a "color" determine a move to make
 # and return it.
 ##
function make_move(board, color,    moves, n_moves, move)
{
  find_all_moves(moves, board, color);
  #DEBUG print_array(moves)
  n_moves = moves[0];
  move = make_random_move(board, moves, color, n_moves)
  if (!update(error, board, color, move)) {
    print_error("Error: illegal move generated: " error[0]);
    exit EXIT_SUCCESS;
  }
  delete moves;
  return is_win(board) ? -move : move;
}

### make_random_move(board, moves, color, n_moves)
 # Out of all the legal "moves", choose one randomly. (Brilliant!)
 # The "board" and the "color" are also available to the function
 # (but are unused).
 ##
function make_random_move(board, moves, color, n_moves,    move_num)
{
  if (color == BLACK) {
    move_num = int(rand() * n_moves) + 1;
  } else if (color == WHITE) {
    move_num = int(n_moves / 2) + 1;
  }
  return moves[move_num];
}

### find_all_moves(moves, board, color)
 # Find all moves available to color on board.
 # Storing each move to an array of moves (a move being a 4-digit
 # strings).
 # Iterates through board finding "color" pieces then gets all
 # legal moves for that pieces.
 # global: BOARD_SIZE
 ##
function find_all_moves(moves, board, color,    distances, row, col)
{
  moves[0] = 0;
  for (row = BOARD_SIZE; row >= 1; row--) {
    for (col = BOARD_SIZE; col >= 1; col--) {
      if ((row, col) in board \
          && board[row, col] == color) {
        all_distances_at(distances, board, row, col);
        #DEBUG print "distances at (" row ", " col ")";
        #DEBUG print_array(distances);
        all_legal_moves_at(moves, distances, board, row, col, color);
        #DEBUG print "moves available at (" row ", " col ")";
        #DEBUG print_array(moves)
      }
    }
  }
}

### all_legal_moves_at(moves, distances, board, row, col, color)
 # Find all legal moves at location (row, col) returning as
 # array of moves (a move being a 4-digit strings).
 # Takes distances available at the location.
 # The board.
 # The location and its color.
 ##
function all_legal_moves_at(moves, distances, board, row, col,
			    color,    n_moves, direction, distance)
{
  #DEBUG print "all_legal_moves_at(moves, distances, board, " row ", " col ", " color ");";
  for (direction in distances) {
    split(direction, delta, SUBSEP);
    d_row = delta[1];
    d_col = delta[2];
    distance = distances[direction];
    get_move_in_direction(moves, board, row, col, d_row, d_col,
			  distance, color);
    get_move_in_direction(moves, board, row, col, -d_row, -d_col,
			  distance, color);
  }
}

### get_move_in_direction(moves, board, row, col, d_row, d_col,
 #                         distance, color)
 # Check whether move from (row, col) by piece "color" can be made in
 # direction (d_row, d_col) over length "distance".
 # If so incrment move counter at moves[0], and store as nth move
 # in moves array.
 ##
function get_move_in_direction(moves, board, row, col, d_row, d_col,
			       distance, color,    row2, col2, error, n_moves)
{
  #DEBUG print "get_move_in_direction(moves, board, " row " ," col ", "d_row ", " d_col ", " distance ", " color ");";
  row2 = row + (distance * d_row);
  col2 = col + (distance * d_col);
  if (is_legal_move(error, board, row, col, row2, col2, color)) {
    moves[0]++;
    n_moves = moves[0];
    moves[n_moves] = row "" col "" row2 "" col2;
  }
}

### all_distances_at(distances, board, row, col)
 # Find all distances that can be traveled in all directions
 # from location (row, col).
 # Returns "distances" array where index is (d_row, d_col)
 ##
function all_distances_at(distances, board, row, col)
{
  ## Diagonal up or down notation is based on travelling a diagonal
  ## line from left-to-right.
  n_diagonal_up = count_pieces_in_line(board, row, col, -1, 1);
  n_diagonal_down = count_pieces_in_line(board, row, col, 1, 1);
  n_horizontal = count_pieces_in_line(board, row, col, 1, 0);
  n_vertical = count_pieces_in_line(board, row, col, 0, 1);
  
  distances[0, 1] = n_vertical;
  distances[0, -1] = n_vertical;
  distances[-1, 1] = n_diagonal_up;
  distances[1, -1] = n_diagonal_up;
  distances[1, 0] = n_horizontal;
  distances[-1, 0] = n_horizontal;
  distances[1, 1] = n_diagonal_down;
  distances[-1, -1] = n_diagonal_down;
  return;
}
