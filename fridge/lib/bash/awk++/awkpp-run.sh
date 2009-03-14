#!/bin/sh
prog=$1;shift
gawk -f awkpp.awk $prog | gawk -f - $@
