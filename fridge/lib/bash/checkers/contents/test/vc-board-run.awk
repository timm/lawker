BEGIN {
  define_globals();
}

/^([012] *)*$/ {
  for (i = 1; i <= NF; i++)
  {
    board[NR, i] = $i;
  }
}

! /^([012] *)*$/ {
  print_error("Invalid board input: " $0);
  exit EXIT_FAILURE;
}

END {
  show(board);
  print "has_won(board, BLACK); => " has_won(board, BLACK);
  print "has_won(board, WHITE); => " has_won(board, WHITE);
}
