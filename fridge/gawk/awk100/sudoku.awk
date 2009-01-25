#!/usr/local/bin/gawk -f 
#
# Solve sudoku puzzles using "human" strategies, not brute force
#
# Copyright 2006, 2007, 2008 Jim Hart, jhart50@gmail.com
#
# For more on this program, see
# http://awk.info/?awk100/004sudoku
#
# Load known values for the puzzle
#
# The logic is:
#
#   If x cells in the same column or the same row or the same set contain the
#   same values, where x is the number of digits in the value, those digits are
#   to be removed from every other cell in that column, row or set until all
#   cells in the puzzle contain only one digit, i.e. there are exactly 81 digits
#   in the puzzle. (Also, the total of all digits in all cells in the puzzle is
#   9*((9*(9+1))/2) = 9 * 45 = 405).
#
#  Need an additional strategy for solving harder puzzles:
#
#   If a particular digit can only appear in certain cells of a set that happen to
#   be in the same row or column, that digit can't be used anywhere else in that
#   row or column.
#
#   This requires that the puzzle have only one solution.
#
#   Each pass starts with length 1 and goes to min(max-length,8).
#
#
BEGIN {
# Fill grid with 1-9
	if(format == "coord") 
		for(i=1;i<=9;i++)
			for(j=1;j<=9;j++) {
				cells[i,j,"digits"] = "123456789"
				cells[i,j,"set"] = setCalc(i,j)
				#print i "," j ": " cells[i,j,"set"] 
			}

# Calculate the set ranges
	else if(format == "grid" || format == "fields")
		for(i=1;i<=9;i++)
			for(j=1;j<=9;j++) {
				cells[i,j,"set"] = setCalc(i,j)
				#print i "," j ": " cells[i,j,"set"] 
			}
		else {
			print "Usage: sudoku -v format=(coord|grid|fields)"
			print " where"
			print "       'coord' means each line of the input file has 3 fields separated by one or more spaces, x-coord, y-coord and cell value;"
			print "       'grid' means the input file contains 9 rows of 9 digits with no separation between them;"
			print "       'fields' means the input file contains 9 rows of 9 digits separated by one or more spaces;"
			_assert_exit = 1
			exit 
		}
}
{
	if(format == "coord")
		cells[$1,$2,"digits"] = $3
	else if(format == "grid"){
		++inRow
		for(i=1;i<=9;i++) {
			cellValue = substr($0,i,1)
			if(cellValue == " ")
				cells[inRow,i,"digits"] = "123456789"
			else	cells[inRow,i,"digits"] = cellValue
		}
	}
	else {
		++inRow
		for(i=1;i<=NF;i++)
			cells[inRow,i,"digits"] = $i
	}
}
END {
	if(_assert_exit) exit _assert_exit
	#print "Original Puzzle"
	#printPuzzle(cells)
	doPuzzle(cells)
	print numberOfPasses " passes"
	print ""
	printPuzzle(cells)
	exit
}

function calcPuzzleTotal(cells,i,j,puzzleTotal) {
	for(i=1;i<=9;i++)
		for(j=1;j<=9;j++)
			puzzleTotal += cells[i,j,"digits"]
	return puzzleTotal
}

function clearXrefs(cells,digit,x1,y1,x2,y2,n,m){
	#print "clear " x1 "," y2 " and " x2 "," y1 " of digit " digit
	if(cells[x2,y2,"digits"] == cells[x1,y2,"digits"]) {
		# Oops, the 3 cells are an exact match, so it may require guessing
		#print "3-way match, " x1 "," y2
	}
	else  if(length(cells[x1,y2,"digits"]) > 1) n = sub(digit,"",cells[x1,y2,"digits"])

	if(cells[x2,y2,"digits"] == cells[x2,y1,"digits"]) {
		# Oops, the 3 cells are an exact match, so it may require guessing
		#print "3-way match, " x2 "," y1
	}
	else if(length(cells[x2,y1,"digits"]) > 1) m = sub(digit,"",cells[x2,y1,"digits"])

	return n + m
}
function digitScan(cells,last,pattern,madeChanges,x,y,s,d,h,n) {
			#
			# Individual digit scan
			#
			# For each digit, set up a pattern array where cells having that digit
			# as an option are filled in.

			# "Pointing"
			# 1- Check each set (house) to
			# see if occurences of that digit fall only in one row or one column.
			# If true, remove all other occurences of that digit from the row or column,
			# both from the current pattern array and from the main "digits" array.
			#
			# "Claiming"
			# 2- Check each row/column to see if the digit only occurs in one 
			# set. If so, remove the digit from the rest of the set.
			#
			# Use the X and Y coordinates of the cells to tell whether they're in
			# the same row or column.

			madeChanges = 0

			if(last) {
				#print "Puzzle:"
				#printPuzzle(cells)
			}
			for(d=1;d<=9;d++) {
				for(x=1;x<=9;x++) 
					for(y=1;y<=9;y++)
						if(cells[x,y,"digits"] != "123456789" && index(cells[x,y,"digits"],d))
						   pattern[x,y] = d
						else pattern[x,y] = ""

			if(last) {
				#print "Pattern:"
				#printPattern(pattern)
			}
				#print "Pattern:"
				#printPuzzle(cells)
				#printPattern(pattern)
				# OK, we have a pattern. Now, we have to check for positions of
				# digits in the sets

				#print "digitScan for " d
				#printPuzzle(cells)

				# "Pointing"
				for(s=1;s<=9;s++) {
					#print "set " s " current coords: " sets[s,"x1"],sets[s,"y1"],sets[s,"x2"],sets[s,"y2"]
			if(last) {
					#print "set " s " current coords: " sets[s,"x1"],sets[s,"y1"],sets[s,"x2"],sets[s,"y2"]
			}
					#printPattern(pattern)
					delete hitsx
					delete hitsy
					delete crossx
					delete crossy
					h = 0
					for(x=sets[s,"x1"];x<=sets[s,"x2"];x++)
						for(y=sets[s,"y1"];y<=sets[s,"y2"];y++) {
							#print "pattern[" x "," y "]=" pattern[x,y]
							#print "looking for digit " d
							if(pattern[x,y] == d) {
								hitsx[++h] = x
								hitsy[h] = y
								crossx[x] = 1
								crossy[y] = 1
								#print "Hit " x "," y
			if(last) {
								#print "Hit " x "," y
			}
							}
						}
					# Now, check for all hits in a row or a column

					if(h > 9) {
						print "Program bug: the calculation for the number of cells in a set is out of range."
						exit
					}
					if(h > 0) {
						if(h == 1) # only option in the set
							cells[hitsx[1],hitsy[1],"digits"] = d
						else {
							allmatch = 1
							for(n=1;n<h;n++)
								if(hitsx[n] != hitsx[n+1]) allmatch = 0
							if(allmatch) {
								madeChanges = 1
								removeDigits(cells,"x",hitsx[1],d,crossy)
							}
							allmatch = 1
							for(n=1;n<h;n++)
								if(hitsy[n] != hitsy[n+1]) allmatch = 0
							if(allmatch) {
								madeChanges = 1
								removeDigits(cells,"y",hitsy[1],d,crossx)
							}
						}
					}
			}
			#print "After Pointing"
				#printPuzzle(cells)
				#printPattern(pattern)


			#if(madeChanges) doRowsColumnsAndHouses(cells)
			# "Claiming"

			# Rows
			delete setHits
			if(last) printPattern(pattern)
			for(x=1;x<=9;x++) {
				for(y=1;y<=9;y++) {
					if(pattern[x,y] == d) {
						setHits[cells[x,y,"set"]] = x
						if(last) print "setHit in set " cells[x,y,"set"] ", coords " x "," y
					}
				}
				if(last)
					#print "Row " x " has " alength(setHits) " hits"
				if(alength(setHits) == 1) {
					# Clear the other cells in the set
					for(setNmbr in setHits)
						row = setHits[setNmbr]
						for(i=sets[setNmbr,"x1"];i<=sets[setNmbr,"x2"];i++)
							for(j=sets[setNmbr,"y1"];j<=sets[setNmbr,"y2"];j++)
								if(i != row) {
									madeChanges = 1
									pattern[i,j] = ""
									sub(d,"",cells[i,j,"digits"])
								}

				}
				delete setHits
			}
			#print "After claiming rows"
				#printPuzzle(cells)
				#printPattern(pattern)
			
			#if(madeChanges) doRowsColumnsAndHouses(cells)

			# Columns
			delete setHits
			if(last) printPattern(cells)
			for(y=1;y<=9;y++) {
				for(x=1;x<=9;x++) {
					if(pattern[x,y] == d) {
						setHits[cells[x,y,"set"]] = y
						if(last) print "setHit in set " cells[x,y,"set"] ", coords " x "," y
					}
				}
				#print "Column " y " has " alength(setHits) " hits for digit " d
				if(last)
					#print "Column " y " has " alength(setHits) " hits"
				if(alength(setHits) == 1) {
					# Clear the other cells in the set
					for(setNmbr in setHits)
						#print "House nmbr " setNmbr
						col = setHits[setNmbr]
						#print "Column " col
						for(i=sets[setNmbr,"x1"];i<=sets[setNmbr,"x2"];i++)
							for(j=sets[setNmbr,"y1"];j<=sets[setNmbr,"y2"];j++)
								if(j != col) {
									#print "Clear " i "," j " of " d
									madeChanges = 1
									pattern[i,j] = ""
									#print cells[i,j,"digits"]
									sub(d,"",cells[i,j,"digits"])
									#print cells[i,j,"digits"]
								}

				}
				delete setHits
			}
			#print "After claiming columns"
				#printPuzzle(cells)
				#printPattern(pattern)

			#if(madeChanges) doRowsColumnsAndHouses(cells)
		}

		#return madeChanges
}

function doColumns(cells,i,j,madeChanges) {
	# Do columns
	for(i=1;i<=9;i++) {
		madeChanges += doRange(cells,1,i,9,i)
	}
	#print "Columns"
	#printPuzzle(cells)
	if(madeChanges) doColumns(cells)
	#return madeChanges
}

function doPuzzle(cells,i,j,k,puzzleTotal) {
	uniqueValues[1] = 0
	while(1) {
		# Are we done?
		prevPuzzleTotal = puzzleTotal
		puzzleTotal = calcPuzzleTotal(cells)
		if(puzzleTotal == prevPuzzleTotal) {
			# Puzzle isn't solved, yet, but the last run did nothing,
			# so try to cross reference cells with the same 2 digits

				print "Failed to solve the puzzle"

				break  # we're done
		}
		if(puzzleTotal > 405) {   #not done
			#doRowsColumnsAndHouses(cells)
			doRows(cells)
			doColumns(cells)
			doHouses(cells)

			# Digit scan
			digitScan(cells)
			#print "Digit Scan"
			#printPuzzle(cells)

			#xrefPairs(cells)

			++numberOfPasses
			#print "End of pass #" numberOfPasses
			#print ""
			#if((numberOfPasses % 100) == 0) printPuzzle(cells)
		}
		else break
	}
}
function doRange(cells,x1,y1,x2,y2,d,i,j,val,n,madeChanges,nmbrOfUnique){
			delete uniqueValues
			for(i=x1;i<=x2;i++)
				for(j=y1;j<=y2;j++) 
					uniqueValues[cells[i,j,"digits"]]++
			#print "Range: " x1","y1" "x2","y2


			# the unique values have to be sorted by length
			# then, after each run through of a certain length,
			# the unique values have to be recalculated
			
			for(val in uniqueValues) {
				#print val, uniqueValues[val]
				if(uniqueValues[val] == length(val) && val != "123456789") {
					++nmbrOfUnique
					#print "Have a unique value: " val
					 #OK, we have some unique cells; remove digits
					 #from other cells
					for(i=x1;i<=x2;i++)
						for(j=y1;j<=y2;j++) 
							if(cells[i,j,"digits"] != val) {
								n = split(val,digits,"")
								#print "Value " val " has " n " digits."
								#print "Before: "cells[i,j,"digits"]
								for(d=1;d<=n;d++)
									madeChanges += sub(digits[d],"",cells[i,j,"digits"])
								#print "After: "cells[i,j,"digits"]
							}
				}
			}
	return madeChanges
}

function doRows(cells,i,j,madeChanges) {
	# Do rows
	for(i=1;i<=9;i++) {
		madeChanges += doRange(cells,i,1,i,9)
	}
	#print "Rows"
	#printPuzzle(cells)
	if(madeChanges) doRows(cells)
	#return madeChanges
}

function doRowsColumnsAndHouses(cells,madeChanges) {
	madeChanges = 1
	while(madeChanges > 0) {
		while(madeChanges > 0) {
			madeChanges = 0
			madeChanges += doRows(cells)
			madeChanges += doColumns(cells)
		}
		madeChanges = 0
		madeChanges = doHouses(cells)
	}
}

function doHouses(cells,i,j,c,carr,madeChanges) {
			# Do houses (sets)
			for(c in cells) {
				split(c,carr,SUBSEP)
				if(carr[3] == "set"){
					i = carr[1]
					j = carr[2]
					#print "Set " cells[c] ", one pair of coordinates: " i,j
					sets[cells[c],"x1"] = min(i,sets[cells[c],"x1"])
					sets[cells[c],"x2"] = max(i,sets[cells[c],"x2"])
					sets[cells[c],"y1"] = min(j,sets[cells[c],"y1"])
					sets[cells[c],"y2"] = max(j,sets[cells[c],"y2"])
					#print "set " cells[c] " current coords: " sets[cells[c],"x1"],sets[cells[c],"x2"],sets[cells[c],"y1"],sets[cells[c],"y2"]
				}
			}
			for(i=1;i<=9;i++) {
				#print "set " i " coords: " sets[i,"x1"],sets[i,"x2"],sets[i,"y1"],sets[i,"y2"]
				madeChanges += doRange(cells,sets[i,"x1"],sets[i,"y1"],sets[i,"x2"],sets[i,"y2"])
				#printPuzzle()
			}
			#print "Sets"
			#printPuzzle(cells)
	if(madeChanges) doHouses(cells)
	#return madeChanges

}

function printPattern(pattern,i,j) {
	for(i=1;i<=9;i++) {
		for(j=1;j<=9;j++) {
			#printf "%9s|",pattern[i,j]
		}
		#print ""
	}
	#print ""

}

function printPuzzle(cells,i,j,puzzleTotal) {
	for(i=1;i<=9;i++) {
		for(j=1;j<=9;j++) {
			printf "|%9s",cells[i,j,"digits"]
			puzzleTotal += cells[i,j,"digits"]
		}
		print ""
	}
	print ""
	print "Puzzle total: " puzzleTotal
}

function removeDigits(cells,axis,position,digit,hits,i) {
	# Remove the specified digit from the appropriate row or column of both the
	# pattern and cells arrays, ignoring the cells in the hits array.

	#print ""
	#print "Remove digit " digit " from "axis"="position
	#print ""

	for(i=1;i<=9;i++)
		if(i in hits) {}
		else 
			if(axis == "x") {
				pattern[position,i] = ""
				sub(digit,"",cells[position,i,"digits"])
			}
			else if(axis == "y") {
				pattern[i,position] = ""
				sub(digit,"",cells[i,position,"digits"])
			}
}


function setCalc(x,y) {
	if(x < 4) {
		if(y < 4) return 1
		if(y < 7) return 4
		else return 7
	} else if(x<7) {
		if(y < 4) return 2
		if(y < 7) return 5
		else return 8
	} else {
		if(y < 4) return 3
		if(y < 7) return 6
		else return 9
	}

}

function validateRange(cells,x1,y1,x2,y2,d,x,y,nmbrOfCells,totalDigits) {
	# In order for a row, column or house to be valid, for each digit, 1-9,
	# the total of
	# the number of digits in the cells where it is found must be n(n+1)/2, where
	# n is the number of cells in which the digit is found.
	while(++d < 9) {
		for(x=x1;x<=x2;x++)
			for(y=y1;y<=y2;y++)
				if(sub(d,d,cells[x,y,"digits"])) {
					nmbrOfCells[d]++
					totalDigits[d] += length(cells[x,y,"digits"])
				}
		if(totalDigits[d] < nmbrOfCells[d] * (nmbrOfCells[d] + 1) / 2)
			print "Puzzle is broken, digit " d " range " x "," y
			return 0
	}
	return 1
}

function xrefPairs(cells,x,y,x2,y2,i,j,twoDigits,madeChanges){
	for(x=1;x<=9;x++)
		for(y=1;y<=9;y++) 
			if(length(cells[x,y,"digits"]) == 2)
				twoDigits[x,y] = cells[x,y,"digits"]
	for( key1 in twoDigits ) {
		split(key1,arr,SUBSEP)
		x = arr[1]
		y = arr[2]
		#print "twoDigits[" x "," y "]=" twoDigits[x,y]
	}
	for( key1 in twoDigits ) 
		for( key2 in twoDigits ) {
			#If x and y are the same, it's the same cell, ignore it
			if(key1 == key2) {}
			else {
				#extract the coordinates (stupid gawk!)
				split(key1,arr,SUBSEP)
				x = arr[1]
				y = arr[2]
				split(key2,arr,SUBSEP)
				x2 = arr[1]
				y2 = arr[2]

				# If they are in the same row or column, ignore them
				if(x == x2 || y == y2) {}
				else {

					# do they have the same digits
					if( twoDigits[x,y] == twoDigits[x2,y2] ) {
						split(twoDigits[x,y],pair,"")
						madeChanges += clearXrefs(cells,pair[1],x,y,x2,y2)
						madeChanges += clearXrefs(cells,pair[2],x,y,x2,y2)
					}
				}
			}
		}
	print "xref pass " ++xrefPass
	print madeChanges " cells changed"
	printPuzzle(cells)
	return madeChanges
}

############# GENERIC FUNCTIONS ####################
function min(i,j){
	return i < j ? i : j
}
function max(i,j){
	return i > j ? i : j
}

function alength(array,i,len) {
	for(i in array) {
		len++
	}
	return len
}
