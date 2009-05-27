#!/usr/bin/env bash

## Takes first argument as an awk program
## The rest of the arguments continue on 

GAWKPROG=\'`cat $1 | sed -e 's/^ *#.*$//' -e 's/"/\\"/' | grep -ve '^ *$'`\';
shift;
echo "#!/bin/sh

gawk $* $GAWKPROG
"
