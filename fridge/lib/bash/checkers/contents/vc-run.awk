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

