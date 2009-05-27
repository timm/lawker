
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
