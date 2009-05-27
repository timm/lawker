### define_globals()
 # Defines globals.
 ##
function define_globals()
{
  FALSE = 0;
  TRUE = 1;
  EMPTY = 0;
  BLACK = 1;
  WHITE = 2;

  BOARD_SIZE = 8;
  DISPLAY = FALSE;
  
  EXIT_SUCCESS = 0;
  EXIT_FAILURE = 1;
}
### Votey Checkers
 # Aaron Hawley
 # University of Vermont
 # CSSA Programming Contest
 # February 16, 2003
 # Last changed January 11, 2005
 ##

BEGIN {
  define_globals();
  current_color = BLACK; ## Black goes first.
  # my_color = command line argument (-v my_color=)
  if (my_color == "") {
    print_error("Error: no color given to me.");
    exit EXIT_FAILURE;
  } else if (my_color != WHITE && my_color != BLACK) {
    print_error("Error: invalid color: " color_to_string(my_color) \
                " (" my_color ")");
    exit EXIT_FAILURE;
  }
  their_color = flip_color(my_color);
  init(my_board);
  setup(my_board);
  #DISPLAY show(my_board);
  srand();
  if (my_color == current_color) { ## Black goes first.
    DISPLAY = TRUE;
    move = 0;
    play(my_board, their_color, move);
    current_color = flip_color(current_color);
  } ## else continue expecting Black play
} ## end BEGIN

### play(board, color, move)
 # Take a board, and a color and a move command.
 # Respond with a counter move printed to stdout.
 # Return True if move was valid, else exit as winner.
 ##
function play(board, color, move,    winning_color)
{
  if (!update(error, board, color, abs_val(move))) {
    print_error("Error: illegal move received: " error[0]);
    exit EXIT_SUCCESS;
  }
  if (DISPLAY && move > 0) {
    print_error(move " # move by " color_to_string(color));
    show(my_board);
  }
  if (move < 0) {
    if (winning_color = is_win(board)) {
       print_message("Winner! (color: " color_to_string(winning_color) ")");
       exit EXIT_SUCCESS;
    } else {
      print_error("Error: not an endgame move: " move);
      exit EXIT_SUCCESS;
    }
  } else if (winning_color = is_win(board)) {
    print_error("Error: move ended game: " move " (winner: " winner ")");
    exit EXIT_SUCCESS;
  }
  move = make_move(board, flip_color(color));
  print_move(move);
  if (DISPLAY && move > 0) {
    print_error(move " # move by " color_to_string(flip_color(color)));
    show(my_board);
  }
  if (move < 0) {
    exit EXIT_SUCCESS;
  }
  return TRUE;
}

current_color == their_color \
  && /^-?[1-9][1-9][1-9][1-9]$/ { ## ASSERT(BOARD_SIZE < 10)
  delete graph;
  play(my_board, their_color, $0);
}

! /^-?[1-9][1-9][1-9][1-9]$/ { ## ASSERT(BOARD_SIZE < 10)
  print_error("Error: bad input: " $0);
  exit EXIT_SUCCESS; ## Comment out for human-interactive play.
}

### Board Functions

### setup(board)
 # Places pieces on starting places.
 # global: BOARD_SIZE
 ##
function setup(board,    i, j)
{
  for (i = 2; i <= BOARD_SIZE - 1; i++) {
    # black
    board[1, i] = BLACK;
    board[BOARD_SIZE, i] = BLACK;
    # white
    board[i, 1] = WHITE;
    board[i, BOARD_SIZE] = WHITE;
  }
}

### init(board)
 # Initializes the board to empty.
 # global: BOARD_SIZE
 ##
function init(board,    i, j)
{
  for (i = 1; i <= BOARD_SIZE; i++) {
    for (j = 1; j <= 8; j++) {
      board[i, j] = EMPTY;
    }
  }
}

### show(board)
 # Prints the board in a simple way: zeros and ones.
 # global: BOARD_SIZE
 ##
function show(board,    i, j, str)
{
  print_debug(color_to_string(BLACK) " = " BLACK ", " \
              color_to_string(WHITE) " = " WHITE);
  for (i = 1; i <= BOARD_SIZE; i++) {
    str = "";
    for (j = 1; j <= BOARD_SIZE; j++) {
      str = str board[i, j] " ";
    }
    print_debug(str);
  }
  print_debug("---------------");
}

### update(error, board, color, move)
 # Takes a board: an 8x8 array.
 # Takes a move command: some 4-digit integer (1111 <= move <= 8888).
 # Verifies the move follows the rules made in is_legal_move().
 ##
function update(error, board, color, move,    m)
{
  if (move == 0) {
    return TRUE;
  }
  split(move, m, ""); ## ASSERT(BOARD_SIZE < 10)
  if (!is_legal_move(error, board, m[1], m[2], m[3], m[4], color)) {
    return FALSE;
  }
  #DEBUG print "board[" m[3] ", " m[4] "] = board[" m[1] ", " m[2] "];";
  board[m[3], m[4]] = board[m[1], m[2]];
  #DEBUG print "board[" m[1] ", " m[2] "] = EMPTY;";
  board[m[1], m[2]] = EMPTY;
  return TRUE;
}

### is_legal_move(error, board, row1, col1, row2, col2, color)
 # Returns true if the move (row1, col1) of "color" to (row2, col2) is legal.
 # Takes an error array to give back put ant error messages at index 0
 # if move was illegal.
 # 
 # Verifies the move follows the following rules:
 #   Move is within board boundaries.
 #   Moves the correct color piece.
 #   Move does not jump an opponent.
 #   Moves to an open space or a space an opponent occupies.
 #   Move is correct distance.
 ##
function is_legal_move(error, board, row1, col1, row2, col2, color)
{
  #DEBUG print "is_legal_move(error, board, " row1 ", " col1 " ," row2 ", " col2 ", " color ");";
  move = row1 "" col1 "" row2 "" col2;
  if (!is_location(board, row1, col1)) {
      error[0] = "off board: " row1 col1;
      return FALSE;
  } else if (!is_location(board, row2, col2)) {
      error[0] = "off board: " row2 col2;
      return FALSE;
  } else if (board[row1, col1] == EMPTY) {
    error[0] = "no piece at: " row1 col1;
    return FALSE;
  } else if (board[row1, col1] != color) {
    error[0] = "Not your piece at: " row1 col1 " (expecting color: " \
               color_to_string(color) ")";
    return FALSE;
  } else if (!is_move_valid_length(board, row1, col1, row2, col2)) {
    error[0] = "wrong length move: " move;
    return FALSE;
  } else if (move_jumps_opponent(opp, board, row1, col1, row2, col2, color)) {
    error[0] = "Error: jumped opponent at: " opp[1] opp[2] " (move: " move ")";
    return FALSE;
  } else if (board[row2, col2] == EMPTY) {
    error[0] = "legal move: " move;
  } else {
    if (board[row1, col1] == board[row2, col2]) {
      error[0] = "move error: cannot land on your own piece";
      return FALSE;
    } else {
      error[0] = "capture at: " row2 col2 " (move: " move ")";
    }
  }
  return TRUE;
}

### move_jumps_opponent(pos, board, row1, col1, row2, col2, color)
 # True if any piece of opponent "color" is found between points
 # (row1, col1) and (row2, col2).  Else false.
 ##
function move_jumps_opponent(pos, board, row1, col1,
			     row2, col2, color,    d_row, d_col)
{
  #DEBUG print "move_jumps_opponent(pos, board, " row1 ", " col1 ", " row2 ", " col2 " , " color ");";
  d_row = row2 - row1;
  d_row = d_row == 0 ? 0 : (d_row > 0 ? 1 : -1);
  d_col = col2 - col1;
  d_col = d_col == 0 ? 0 : (d_col > 0 ? 1 : -1);
  if (row1 + d_row == row2 && col1 + d_col == col2) {
    ## Catches case when base case could miss eachother.
    return FALSE;
  }
  return color_between(pos, board, row1 + d_row, col1 + d_col,
		       row2, col2, flip_color(color),
		       d_row, d_col);
}

### color_between(pos, board, row1, col1, row2, col2,
 #                color, d_row, d_col)
 # True if piece of "color" is found between (inclusively) points
 # (row1, col1) and (row2, col2) traveling in forward and reverse
 # direction of (d_row, d_col). Else false.
 ##
function color_between(pos, board, row1, col1, row2, col2,
		       color, d_row, d_col)
{
  #DEBUG print "color_between(pos, board, " row1 ", " col1 ", " row2 ", " col2 " , " color " , " d_row ", " d_col ");";
  if (((row1, col1) in board && board[row1, col1] == color)) {
    pos[1] = row1;
    pos[2] = col1;
    return TRUE;
  } else if (((row2, col2) in board && board[row2, col2] == color)) {
    pos[1] = row2;
    pos[2] = col2;
    return TRUE;
  }
  if (row1 == row2 && col1 == col2) {
    return FALSE;
  }
  return color_between(pos, board, row1 + d_row, col1 + d_col,
                        row2, col2, color,
                        d_row, d_col);
}

### is_move_valid_length(board, row1, col1, row2, col2)
 # If move from (row1, col1) to (row2, col2) travels according to the
 # distance rules that the move length should be equal to the number of
 # pieces in that line.
 ##
function is_move_valid_length(board, row1, col1, row2, col2,    diag_length, n_pieces)
{
  ## This could probably be more generalized for any direction
  ## rather than calculating each differently depending on the
  ## direction (horizontal, vertical, diagonal).

  if (is_horizontal_move(row1, col1, row2, col2)) {
    #DEBUG print "abs_val(col2 - col2) = " abs_val(col2 - col2);
    n_pieces = count_pieces_in_row(board, row1);
    #DEBUG print "number of pieces in row: " n;
    return n_pieces == abs_val(col2 - col1);
  } else if (is_vertical_move(row1, col1, row2, col2)) {
    #DEBUG print "abs_val(row2 - row1) = " abs_val(row2 - row1);
    n_pieces = count_pieces_in_col(board, col1);
    #DEBUG print "number of pieces in column: " n_pieces;
    return n_pieces == abs_val(row2 - row1);
  } else if (diag_length = is_diagonal(row1, col1, row2, col2)) {
    #DEBUG print "diagonal length = " diag_length;
    n_pieces = count_pieces_in_diagonal(board, row1, col1, row2, col2);
    #DEBUG print "number of pieces in diagonal: " n_pieces;
    return n_pieces == diag_length;
  } else {
    return FALSE;
  }
}

### count_pieces_in_diagonal(board, row1, col1, row2, col2)
 # Count pieces in diagonal line represented by path of
 # (row1, col1) to (row2, col2).
 # Recursive ("cause it's easier") function with subproblem
 # functions count_pieces_from() and count_pieces_in_line.
 ##
function count_pieces_in_diagonal(board, row1, col1,
				  row2, col2,     d_row, d_col)
{
  d_row = row2 - row1 > 0 ? 1 : -1;
  d_col = col2 - col1 > 0 ? 1 : -1;
  return count_pieces_in_line(board, row1, col1, d_row, d_col);
}

### count_pieces_in_line(board, row, col, d_row, d_col)
 # Counts pieces in the line passing throw (row, col) and going in both
 # the forward and reverse directions of (d_row, d_col).
 ## 
function count_pieces_in_line(board, row, col, d_row, d_col)
{
  ## current piece + pieces after position + pieces before position
  return (((row, col) in board \
	   && board[row, col] == EMPTY) ? 0 : 1) \
    + count_pieces_from(board, row + d_row, col + d_col, d_row, d_col) \
    + count_pieces_from(board, row - d_row, col - d_col, -d_row, -d_col);
}

### count_pieces_from(board, row, col, d_row, d_col)
 # Finds the number of pieces including (row, col) and continuing
 # incrementing by (d_row, d_col).
 ##
function count_pieces_from(board, row, col, d_row, d_col)
{
  #DEBUG print "count_pieces_from(board, " row ", " col ", " d_row ", " d_col" );";
  if (!is_location(board, row, col)) {
    #DEBUG print "is_location(board, " row ", " col ") == \
    #DEBUG         " is_location(board, row, col);
    return 0; ## base case
  } ## else
  return count_pieces_from(board, row + d_row, col + d_col, d_row, d_col) \
    + (board[row, col] == EMPTY ? 0 : 1);
}

### is_location(board, row, col)
 # Is location (row, col) on board.
 # global: BOARD_SIZE
 ##
function is_location(board, row, col)
{
  return 1 <= row && row <= BOARD_SIZE \
           && 1 <= col && col <= BOARD_SIZE;
  ## Could optionally just return the result of board[row, col] != ""
  ## Though that puts to much trust in the algorithm will never go
  ## out of bounds; an optimistic and naive expectation.
}

### count_pieces_in_row(board, row)
 # global: BOARD_SIZE
 ##
function count_pieces_in_row(board, row,    n, i)
{
  #DEBUG print "count_pieces_in_row(board, " row ");";
  n = 0;
  for (i = 1; i <= BOARD_SIZE; i++) {
    n += (row, i) in board && board[row, i] == EMPTY ? 0 : 1;
  }
  return n;
}

### count_pieces_in_col(board, col)
 # Count pieces in column.
 # global: BOARD_SIZE
 ##
function count_pieces_in_col(board, col,    n, i)
{
  #DEBUG print "count_pieces_in_col(board, " col ");";
  n = 0;
  for (i = 1; i <= BOARD_SIZE; i++) {
    n += (i, col) in board && board[i, col] == EMPTY ? 0 : 1;
  }
  return n;
}

### is_diagonal(row1, col1, row2, col2)
 # A diagonal is when the column and row lengths are equal (which is
 # assumed here).
 # A diagonal move of zero length is not a move.
 # (Because) True value is also distance of diagonal.
 ##
function is_diagonal(row1, col1, row2, col2,    d_row, d_col)
{
  d_row = row2 - row1;
  d_col = col2 - col1;
  return (abs_val(d_row) == abs_val(d_col) \
	  && d_row != 0) ? abs_val(d_row) : FALSE;
}

### is_horizontal_move(row1, col1, row2, col2)
 # is move from (row1, col1) to (row2, col2) horizontal?
 ##
function is_horizontal_move(row1, col1, row2, col2)
{
  return row1 == row2;
}

### is_vertical_move(row1, col1, row2, col2)
 # is move from (row1, col1) to (row2, col2) vertical?
 ##
function is_vertical_move(row1, col1, row2, col2)
{
  return col1 == col2;
}

### flip_color(color)
 # if White return Black else White.
 ##
function flip_color(color)
{
  return color == WHITE ? BLACK : WHITE;
}

### color_to_string(color)
 # Return string representation of color, else empty-string.
 ##
function color_to_string(color)
{
  return color == BLACK ? "Black" : (color == WHITE ? "White" : "");
}

### is_win(board)
 # Whether there is a winner on the board.
 # Tests if black or white won, or if there was a draw (is this even
 # possible?).
 ##
function is_win(board,    black_won, white_won)
{
  black_won = has_won(board, BLACK);
  white_won = has_won(board, WHITE);
  if (black_won) {
    if (white_won) {
      print_error("Error: Draw (tie)!");
      exit EXIT_FAILURE;
    }
    return BLACK;
  } else if (white_won) {
    return WHITE;
  } ## else
  return FALSE;
}

### has_won(board, color)
 # Given the board, is "color" in winning position (connected).
 ##
function has_won(board, color,    n_pieces, pieces, n_edges, edge)
{
  n_pieces = make_edge_graph(pieces, n_edges, edge, board, color);
  if (edges_continuous(pieces, n_edges, edge, n_pieces)) {
    return color; ## ASSERT(EMPTY == 0 && color != EMPTY)
  }
  delete n_edges;
  delete edge;
  delete pieces;
  return FALSE;
}

### edges_continuous(pieces, n_edges, edge, n_pieces)
 # Start at some piece in pieces, color each connected piece, then
 # iterate through all pieces making sure it has been colored.
 ##
function edges_continuous(pieces, n_edges, edge, n_pieces,    colored,
			  i, j, piece)
{
  if (n_pieces <= 1) {
    #DEBUG print "Only one piece!";
    ## Only one piece.
    return TRUE;
  } ## else
  piece = pieces[1];
  n_colored = color_connected_to(colored, n_edges, edge, piece);
  delete colored;
  ## If number of pieces connected of a color equals the total number
  ## of pieces of that color then continuous, else false.
  return n_colored == n_pieces;
}

### color_connected_to(colored, n_edges, edge, piece)
 # Mark current "piece" as colored (set "piece" in "colored" equal to 1).
 # For each "edge" of current "piece" (n_edges[piece]) that aren't already
 # "colored" color pieces to which it is connected.
 ##
function color_connected_to(colored, n_edges, edge, piece,    i, n_colored)
{
  #DEBUG print "color_connected_to(colored, n_edges, edge, " piece ");";
  n_colored = 0;
  colored[piece] = 1;
  for (i = 1; i <= n_edges[piece]; i++) {
    if (!(edge[i, piece] in colored)) {
      n_colored \
	+= color_connected_to(colored, n_edges, edge, edge[i, piece]);
      ## "I lost my eye-piece!" -- 2004.02.16 12:41 AM
    }  
  }
  return n_colored + 1;
}

### make_edge_graph(pieces, n_edges, edge, board, color)
 # For all "pieces" find pieces of "color".
 # Find number of connecting edges for each piece of "color".
 # Relate each piece to its connected piece(s).
 # global: BOARD_SIZE
 # Return n_pieces (Integer).
 ##
function make_edge_graph(pieces, n_edges, edge, board, color,    n_pieces, row, col)
{
  #DEBUG print "make_edge_graph(pieces, n_edges, edge, board, " color ");";
  n_pieces = 0;
  for (row = BOARD_SIZE; row >= 1; row--) {
    for (col = BOARD_SIZE; col >= 1; col--) {
      if (!is_location(board, row, col)) {
        return TRUE;
      } else if (board[row, col] == color) {
        n_pieces++;
        pieces[n_pieces] = row SUBSEP col;
        if (is_location(board, row, col - 1) \
            && board[row, col - 1] == color) {
          #DEBUG print "edge: vertical";
          add_edge(n_edges, edge, row, col, row, col - 1, color);
        }
        if (is_location(board, row - 1, col) \
            && board[row - 1, col] == color) {
          #DEBUG print "horizontal";
          add_edge(n_edges, edge, row, col, row - 1, col, color);
        }
        if (is_location(board, row - 1, col - 1) \
            && board[row - 1, col - 1] == color) {
          #DEBUG print "diagonal[a]";
          add_edge(n_edges, edge, row, col, row - 1, col - 1, color);
        }
      } else if (board[row, col - 1] == color \
                 && board[row - 1, col] == color) {
        #DEBUG print "diagonal[b]";
        add_edge(n_edges, edge, row, col - 1, row - 1, col, color);
      }
    }
  }
  return n_pieces;
}

### add_edge(n_edges, edge, row1, col1, row2, col2, color)
 # Increment count in number-of-edges-from-piece array (n_edges)
 # and add edge to two-way edge array.
 # piece-to-piece array.
 ##
function add_edge(n_edges, edge, row1, col1, row2, col2, color)
{
  #DEBUG print "add_edge(n_edges, edge, " row1 ", " col1 ", " row2 ", " col2 ", " color ");";
  n_edges[row1, col1]++; 
  n_edges[row2, col2]++;

  #DEBUG print "edge: ((" row1 " " col1 ") (" row2 " " col2 "))";
  #DEBUG print "edge: ((" row2 " " col2 ") (" row1 " " col1 "))";

  edge[n_edges[row1, col1], row1, col1] = row2 SUBSEP col2;
  edge[n_edges[row2, col2], row2, col2] = row1 SUBSEP col1;
}

### abs_val(val)
 # Absolute value of val.
 ##
function abs_val(val)
{
  return val < 0 ? -val : val;
}

### print_move(move)
 # Standard syntax for printing move.
 # Buffering and flushing problems are localized here.
 ##
function print_move(move)
{
  print move;
  fflush();
}

### print_message (move)
 # For printing a status message to the user.
 ##
function print_message(str)
{
  print_error("# " str);
}

### print_debug(move)
 # For printing a debug message.
 ##
function print_debug(str)
{
  print_error("#DEBUG " str);
}

### print_error(move)
 # For printing an error message.  Sent to standard-out.
 ##
function print_error(str)
{
  print str > "/dev/stderr";
}

### print_array(array)
 # Outputs literal keys and values of array.
 ##
function print_array(array,    i)
{
  print_debug("array(");
  for (i in array) {
    print_debug("\t[" i "] => " array[i]);
  }
  print_debug(")");
}
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
  move_num = int(n_moves / 2) + 1;
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
