#!/usr/local/bin/gawk -f 

# Copyright (c) 2008,2009 Jim Hart, jhart@mail.avcnet.org
# All rights reserved. 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program. If not, see http://www.gnu.org/licenses/.
# 

BEGIN {
	version = "alpha 21"
	TRUE = 1
	FALSE = 0
	RS="\r\r\n"
	FS="\r\r\n"

	# the maximum parameters to be passed to a class; increase as needed
	passedParameters = "p1,p2,p3,p4,p5,p6,p7,p8,p9"

	# command string to use if the compiled program is to be run immediately ( -r option )
	# mainly this is to allow for a full path name to the gawk executable. The '-f - ' is
	# absolutely required so that the compiled program can be fed directly to gawk. However,
	# -v and -W options may also be added if all of your awk++ programs need the same ones.
	rungawk = "gawk -f - "          

	# regular expressions are defined at the end for neatness
	defineREs()

	#options

	# first, the optional -r flag
	# -r causes the output program to be fed into the 'rungawk' command, above, via pipe (|),
	# eliminating the need for shell or batch files

	# second, the path of the awk++ file to be translated

	# 3rd, if the output program is to be executed, the awk options to give it

	# 4th, the files, if any, to be processed by the translated program
	# NOTE: the translated program can't read data from standard input when executed immediately;
	#       stdin is used to pass the compiled program to gawk

		if(ARGV[1] == "-r") { runprog = TRUE; delete ARGV[1]} #run the progam after translation
		ac = 2             # skip the name of the program to be compiled
		while(++ac < ARGC) {
			parms = parms ARGV[ac] " "
		}

################################################################################################

	# The whole program is read in at once due to the RS setting
	getline
	compiled = compileProg("#### translated by awk++ version " version "\n" $0)
}

END {

	compiled = appendClassSelector(compiled)
	compiled = appendUtilityFunctions(compiled)
	if(runprog)
		print finishUp(compiled) | (rungawk  parms)
	else
		print finishUp(compiled)
}
	
function appendClassSelector(compiled) {
	# output the class selector
	compiled = compiled  "function __CallMethod(object,method,"passedParameters", __results) {\n"
	compiled = compiled "if(method ==\"delete\") __DestroyObject(object);\n"
	for(i in classes) 
		compiled = compiled  "else if(__objects[object] == \"" i "\") __results = " i "(object,method,"passedParameters");\n"
	compiled = compiled  "return __results}\n"
	return compiled
}

function appendUtilityFunctions(compiled) {
	# append utility functions
	compiled = compiled  "function __ConstructObject(class,"passedParameters") {\n"
	compiled = compiled  "	# This function assigns an object number and stores the class of the\n"
	compiled = compiled  "	# object so that the method call function can switch to the right class\n"
	compiled = compiled  "	# function. It also calls the \"new\" method for object initialization.\n"
	compiled = compiled  "	# It returns the unique object number.\n"
	compiled = compiled  "	__objects[++__ObjectNumber] = class\n"
	compiled = compiled  "    __CallMethod(__ObjectNumber,\"new\","passedParameters") \n"
	compiled = compiled  "	return __ObjectNumber\n"
	compiled = compiled  "}\n"
	compiled = compiled  "function __DestroyObject(object,    i,__indices) {\n"
	compiled = compiled  "	for( i in __attributes ) {\n"
	compiled = compiled  "		split(i,__indices,SUBSEP)\n"
	compiled = compiled  "		if(__indices[1] == object)\n"
	compiled = compiled  "			delete __attributes[__indices[1],__indices[2]]\n"
	compiled = compiled  "	}\n"
	compiled = compiled  "	delete __objects[object] \n"
	compiled = compiled  "}\n"
	return compiled
}

function attributeDef(program,currentClass,   hold,__attarr) {

	while(match(program,attributeDefRE,__attarr)) {
		hold = hold beforeMatch(program)
		__attributes[currentClass,__attarr[5]] = 1

		program = afterMatch(program)
	}
	return hold program
}

function callMethod(text,   n,cmarr) {

	### New version
	# calls a function switcher at run time
		n = split(text,cmarr,/[.()]/)
		return "__CallMethod(" cmarr[1] ",\"" cmarr[2] "\"" ( cmarr[3] ? ","  cmarr[3] : "" ) ")"
}

function classDef(classFound,program,arrCurrentClass,  n,i,__work,__inheritedClasses,currentClass,retainBegin,retainEnd) {
	# input contains:
	#   classFound:  commandPreceder class classname [ : inheritedClass ]...  defFollower
	#   program: the block of code for the class

	# return:
	#	the class function with inherited class code at the end


			n = match(classFound,classDefRE,__work)   # allow inherited classes to be specified
			currentClass = __work[4]
			arrCurrentClass[1] = currentClass
			classes[currentClass] = 1


			gsub(/(^[{])|([}]$)/,"",program)   # get the braces around 'program' out of the way

			# MULTIPLE INHERITANCE

			# Add calls to superclasses if the method isnt' recognized.
			# Call them in specified order until one returns something.
			#
			# This almost works. But, it will call too many superclasses if the intended one returns nothing, which will be a
			# problem if the same method appears in more than one of them.

			if(__work[5]) {
				n = split(__work[5],__inheritedClasses,classSepRE)
				for(i=2;i<=n;i++) {
					program = program "else if(( ret = "__inheritedClasses[i] "(this,method,"passedParameters")) != \"\") return ret\n"                    # pass unidentified method to superclasses
				}
			}
			program = __work[1] "function " currentClass \
				"(this,method,"passedParameters") " __work[7] program "}"
			return program
}


function classToFunction(classFound,program, currentClass,__work) {
	# input is:
	# classFound: the string that matches classDefRE
	# program: the block of code for the class

	program = classDef(classFound,program,arrCurrentClass) 
	currentClass = arrCurrentClass[1]

	return varsToAttributes( translateOO( methodCallRE,methodDef( attributeDef( program,currentClass))) ,currentClass)

}

function compileProg(program) {
	# Remove all comments
	program = removeComments(program)

	# Process lists, list variable assignments and multi-index for() loops
	#program = nonOO(program)

	# Process classes, object definitions and method calls
	program = translateOO(classDefRE,program)
	program = translateOO(objectDefRE,program)
	program = translateOO(methodCallRE,program)

	#print program

	#program = translateOO(includeRE,program)

	# output the translated program
	return program
}

function defineObject(text,  n,object,class,commandFollower ) {

		# record the object variable name and its associated class
		# determine the class

		### New version
		### can appear anywhere and takes parameters
		### format "Classname.new(parameters)"

		n = split(text,__work,/[.()]/)  

		class = __work[1]
		if(! (class in classes)) { print "No such class for object constructor " \
			text > "/dev/stderr";exit }
		return "__ConstructObject(\"" class "\"" ( __work[3] == "" ? "" : "," __work[3] ) ")"
}
	
function forLoop(text,len,   parts,n,vars,i,cmds) {
    # Handle multi-dimensional array indexing in a for loop
    # Cases:
    #   1- The "for..." is followed by a brace on the same line
    #   2- The "for..." is followed by a brace at the start of the next line
    #
    # When a brace is present, the extra commands can be placed right
    #   after it separated by semicolons.
    #
    #   3- The "for..." is not followed by a brace on the same line,
    #     but there is other stuff on the line. The extra stuff could be
    #       - part of a command (continuation line)
    #       - one command
    #       - multiple commands separated by semicolons
    #   4- The "for..." is not followed by a brace on the same line or the
    #      next line, and there is no extra stuff on the same line. 
    #      The next line could be:
    #       - part of a command (continuation line)
    #       - one command
    #       - multiple commands separated by semicolons
    #
    # When no braces are present, we have to add them, which means figuring
    #  out the extent of the one command that goes with the "for...".
    #----------------------------------------------------------------------
    match(substr(text,1,len),multiDimRE,parts)
    cmds = "for( _i in " parts[3] ") { "
    n = split(parts[1],vars,elemSepRE)
    cmds = cmds "split(_i,_vals,SUBSEP);"
    for(i=1;i<=n;i++) 
        cmds = cmds vars[i] " = _vals[" i "];"
    text = substr(text,len+1)
    if(text ~ /^[[:space:]]*$/) {
        # Nothing after the for loop, so grab another line
        getline text < input[stackptr]
        text = getCont(text)
    }
    if(text ~ /^[[:space:]]*{/) {
        # There is a brace
        sub(/^[[:space:]]*\{/,cmds,text)
    } else {
        # No brace
        # There could be semicolons in strings or REs or comments
        text = replaceSemicolons(text)

        # put the closing brace at the first semicolon or at the end
        #  of the line
        if(index(text,";"))
            sub(/;/,"}",text)
        else sub(/$/,"}",text)
        text = restoreSemicolons(text)
        # put the commands at the front
        sub(/^[[:space:]]*/,cmds,text)
    }
    return text
}

function getFirstBlock(code,  skip,hold,pos,se,n,i,j,blockStart,blockEnd,braceCount) {
		# Given a set of AWK code, return the complete block beginning at the
		# start of the code.
		# Blocks are delineated by {}.
		# Must ignore { and } inside string literals and regular expressions.

		# Split the code into characters the GAWK way
		hold = code
		n = split(hold,__chars,"")
		
		blockStart = index(code,"{")
		if( ! blockStart )
			return "Error: no blocks in the code."

		# Determine where all of the strings and regexps are

		se = locateStringsAndREs(code,__ses,__see)


		braceCount = 0
		for(i=blockStart;i<=n;i++) {
			skip = 0
			for(j=1;j<=se;j++) {
				if(i >= __ses[j] && i <= __see[j]) skip = 1 # this char is in string or RE
			}
			if(! skip) {
				if(__chars[i] == "{") braceCount++
				if(__chars[i] == "}") braceCount--
			}
			if(braceCount == 0) break
		}

		return substr(code,1,i)
	}

function locateStringsAndREs(hold,__ses,__see,  se,code,pos) {
	code = hold
	pos = 0
	while(match(code,stringRE)) {
		__ses[++se] = RSTART + pos
		__see[se] = RSTART + RLENGTH - 1 + pos
		code = afterMatch(code)
		pos += RSTART + RLENGTH - 1
	}
	code = hold
	pos = 0
	while(match(code,regExpRE)) {
		__ses[++se] = RSTART + pos
		__see[se] = RSTART + RLENGTH - 1 + pos
		code = afterMatch(code)
		pos += RSTART + RLENGTH - 1
	}
	return se
}

# Add support for lists and for multidimensional array keys in the for loop.
#
# LIST SUPPORT:
# A list of constants and variables separated by commas and contained within
#  braces is translated into a string with SUBSEP as a separator.
#   {d,e,f}  => d SUBSEP e SUBSEP f
#
# LIST ASSIGNMENT SUPPORT:
#  a,b,c = <any string with SUBSEP separators in it>
# becomes:
#  TEMPVAR = <any string with SUBSEP separators in it>
#  split(TEMPVAR,TEMPARR,SUBSEP)
#  a = TEMPARR[1]
#  b = TEMPARR[2]
#  c = TEMPARR[3]
#
# MULTI-DIMENSIONAL ARRAY KEYS:
#
#   for(i,j,k in array) { myvar = array[i,j,k]}
# becomes:
#   for(TEMPVAR in array) {
#    split(TEMPVAR,TEMPARR,SUBSEP)
#    i = TEMPARR[1]
#    j = TEMPARR[2]
#    k = TEMPARR[3]
#    myvar = array[i,j,k]
#   }
#
# Jim Hart, jhart@mail.avcnet.org, October 2004
#################################################
BEGIN {
	srand()
    randNmbr = int(rand() * 1000000)
}

function makeList(text,   arr,i,n) {
    gsub(/[[:space:]{}]/,"",text)
    n = split(text,arr,elemSepRE)
    text = ""
    for(i=1;i<=n;i++)
        text = text arr[i] " SUBSEP "
    sub(/ SUBSEP $/,"",text)
    return text
}

function methodDef(program,  hold,i,n,pars,method,__mdarr,firstMethod) {
	firstMethod = TRUE
	while(match(program,methodDefRE)) {
		hold = hold beforeMatch(program)

		n = split(atMatch(program),__mdarr,/method|[()]/)
		method = __mdarr[2]
		gsub(blankRE,"",method)
		hold = hold ( firstMethod ? "if(method == \"" method "\") {" \
			:  "else if(method == \"" method "\") {" )
		firstMethod = FALSE

		pars = __mdarr[3]
		n = split(pars,__mdarr,attrSepRE)
		for(i=1;i<=n;i++) hold =  hold " " __mdarr[i] " = p" i ";"

		program = afterMatch(program)
	}
	return hold program
	
}

function nonOO(text,  parts) {

    # convert lists into strings with variables/constants separated by SUBSEP
    while(match(text,listRE)) 
        text = beforeMatch(text) makeList(atMatch(text)) afterMatch(text)

    # set a list of variables from a list
    # if the number of variables is less than the number of items in the
    #  list, the extras are ignored
    # if the number of variables is greater than the number of items in the
    #  list, the extra variables are set to null
    while(match(text,varListEqRE)) 
		split(atMatch(text),parts,/=/)
        text = beforeMatch(text) setVars(parts[1],parts[3]) afterMatch(text)

    # Handle multiple array indexes in a "for...in..." loop.
    #while(match(text,multiDimRE)) {
        #text = beforeMatch(text) forLoop(substr(text,RSTART),RLENGTH)
    #}
    return text
}

function replaceSemicolons(text,   n) {
        while (1) {
            if(n = index(text,";")) 
                if(match(text , /"([^"]|\\")*;([^"]|\\")*"/) ||
                   match(text , "/([^/]|\\\\/)*;([^/]|\\\\/)*/") || 
                   match(text , /#.*;/))
                       if(n > RSTART && n < (RSTART + RLENGTH - 1))
                        sub(/;/,randNmbr,text)
                    else break
                else break
            else break
        }
        return text
}

function restoreSemicolons(text) {
        # put back semicolons in strings, REs and comments
        gsub(randNmbr,";",text)
        return text
}

function setVars(varList,value,   cmds,restOfLine,list,vars,vals,i,n,m) {
    # get the vars
    n = split(varList,vars,elemSepRE) # separate out the var names

    # build the commands
    cmds = "_val = " list ";_m = split(_val,_vals,SUBSEP);"
    for(i=1;i<=n;i++)
        cmds = cmds vars[i] " =  _vals[" i "];"
    sub(/;$/,"",cmds)
    return restoreSemicolons(cmds restOfLine)
}

function translateOO(regex,program,
						progRstart,progRlength,pHold,reFound,reLength,commandPreceder,block,follower,oo) {

	# Work through the code processing everything that matches the particular OO RE

	while(match(program,regex)) {

		progRstart = RSTART
		progRlength = RLENGTH
		pHold = pHold beforeMatch(program,progRstart) # everything prior to the match

		reFound = atMatch(program,progRstart,progRlength)
		reLength = length(reFound)

		# Set oo to just the code to be translated
		oo = reFound

		if(match(reFound,precedeCommandRE)) {   
			commandPreceder = atMatch(reFound) #RSTART better be 1

			oo = afterMatch(reFound)
		}

		if(match(oo,followCommandRE "|" followDefRE)) {   
			follower = atMatch(oo)

			oo = beforeMatch(oo)
		}

		# For class definitions
		#---------------------

		if(regex == classDefRE) {

			# Match the braces to determine where the class begins and ends
			block = getFirstBlock(substr(program,progRstart)) 

			# Remove the re declaration leaving only the code for the re
			sub(reFound,"",block)

			# Convert the re and its code to the appropriate AWK code
			# This includes handling property and method
			# definitions.
			functionCode =  classToFunction(reFound,block)
			pHold = pHold commandPreceder functionCode

			# Put the remaining code into 'program' for processing.
			program = afterMatch(program,progRstart, reLength + length(block))
		}

		# For object definitions
		#---------------------

		else if(regex == objectDefRE) {

			pHold = pHold defineObject(oo) 

			# Put the remaining code into 'program' for processing.
			program = afterMatch(program,progRstart, progRlength)
		}

		# For method calls
		#---------------------

		else if(regex == methodCallRE) {

			pHold = pHold callMethod(atMatch(program,progRstart,progRlength))

			# Put the remaining code into 'program' for processing.
			program = afterMatch(program,progRstart, progRlength)
		}

	}

	# append any remaining code to what's been processed and store it in 'program'
	# for reprocessing by the next section
	return  pHold program  
}
	
function varsToAttributes(hold,currentClass,  se,ind,n,returnText) {
#	print "vars2att currentClass=" currentClass
	#print "vars2att in |" hold "|"
	for(ind in __attributes) {
		#print "attr index =" ind
		se = locateStringsAndREs(hold,__ses,__see)
		split(ind,__work,SUBSEP)
		eClass = __work[1]
		eName = __work[2]
		returnText = ""
		pos = 0
		if(eClass == currentClass) {
			while(match(hold,eName)) {
				skip = 0
				pos += RSTART
				for(j=1;j<=se;j++) {
					if(pos >= __ses[j] && pos <= __see[j]) {
						skip = 1
					} # this var name is in a string or RE
				}
				returnText = returnText beforeMatch(hold)
				if(skip)
					returnText = returnText atMatch(hold)
				else
					returnText = returnText "__attributes[this,\"" eName "\"]"

				hold = afterMatch(hold)
				pos += RLENGTH
			}
		}
		hold = returnText hold
	}
	#print "var2attr out |" hold "|"
	return hold
}

function finishUp(code) {
	srand()

	objects =  "a" int(rand() * 10000)
	attributes =  "a" int(rand() * 10000)

	gsub(/__objects/,objects,code)
	gsub(/__attributes/,attributes,code)

	return code

}

######## utility functions ##########

# array functions

function arr2string(__work,   i,n,string) {
	# turn sequential array into string with SUBSEP delimiter
	n = asize(__work)
	for(i=1;i<=n;i++)
		string = i == 1 ? __work[1] : string SUBSEP __work[i]
}
function string2arr(string,__work,   n) {
	n =split(string,__work,SUBSEP)
	return n
}
function asize(arr,  i,a) {
  # returns length of an array for awk's which don't support length(arr)
  for( i in arr) ++a
  return a
}
function acopy(arr1,arr2,  i,n){
	for(i in arr1) {
		arr2[i] = arr1[i]
		n++
	}
	return n
}

# string functions

function beforeMatch(text,optionalStartPosition) { return ( optionalStartPosition ?  substr(text,1,optionalStartPosition - 1) : substr(text,1,RSTART - 1) )}

function atMatch(text,optionalStartPosition,optionalLength) { return ( optionalStartPosition ?  substr(text,optionalStartPosition , optionalLength) : substr(text,RSTART , RLENGTH) )}

function afterMatch(text,optionalStartPosition,optionalLength) { return ( optionalStartPosition ?  substr(text,optionalStartPosition + optionalLength) : substr(text,RSTART + RLENGTH) )}

function removeComments(program) { gsub("(" lineEndRE ")" blankRE "*#[^" lineEndRE "]*","\n",program); return program}


### Define all the regular expressions

function defineREs() {
	blankRE = "[ \\t]"
	spaceRE = "[ \\t\\n\\r]"
	lineEndRE = "(\\r\\n|\\r|\\n)"
	comparisonRE = "<=|>=|!=|==|!~|[~<>=]"
	assignmentRE = "[*][*]=|+=|-=|[*]=|^=|/=|%=|="
	operatorsRE =  comparisonRE "|" assignmentRE "|&&|[|][|]|[*][*]|in|[()!+-%^*/?:]"
	varRE = "[_A-Za-z][_A-Za-z0-9]*"
	regExpRE = "/([^/]|\\\\/)*/"
	#stringRE = "\"(\\\\\"|[^\"])*\""
	stringRE = "\"([^\"]*(\\\\\")*[^\"]*)*\""
	posIntRE = "[0-9]+"
	intRE = "[+-]?" posIntRE
	numberRE = "[+-]?(([0-9]+)|([.][0-9]+)|([0-9]+[.][0-9]+))" # cannot allow comma
	                              # because it is the list item separator
	arrayIndexRE = "\\[(" stringRE "|" varRE "|" posIntRE ")(,(" stringRE "|" varRE "|" posIntRE "))*\\]"
	arrRE = varRE arrayIndexRE
	constRE = litRE = "(" stringRE "|" numberRE ")"
	elemSepRE = attrSepRE = blankRE "*," blankRE "*"
	varListRE = varRE "(" attrSepRE varRE ")*"
	litOrVarRE = "(" varRE "|" litRE ")"
	litVarArrRE = "((" varRE "(" arrayIndexRE ")?)|" litRE ")"
	litOrVarListRE = litOrVarRE "?(" attrSepRE litOrVarRE ")*"
	litVarArrListRE = litVarArrRE "?(" attrSepRE litVarArrRE ")*"
	
	parametersRE = "[(](" blankRE ")*" litVarArrListRE "(" blankRE ")*[)]"
	functionCallRE = varRE parametersRE
	rhsRE = "(" blankRE "|" stringRE "|" numberRE "|" regExpRE "|" varRE "|" arrRE "|" functionCallRE "|(" operatorsRE "))+"

    constOrVarListRE = "((" varRE "|" constRE ")" attrSepRE ")+(" varRE "|" constRE ")"
    listRE = "[{] *" constOrVarListRE " *[}]"
    multiDimRE = "for *\\( *(" varListRE ") *in *(" varRE ") *\\)"
	varListEqRE = varListRE blankRE "*="

	precedeCommandRE = "([\\n]|;)" blankRE "*" 
	followDefRE = spaceRE "*[{]"
	followCommandRE = blankRE "*(" lineEndRE "|;)"

	functionNameRE = varRE
	functionCallRE = functionNameRE parametersRE
	functionRE = "function" blankRE "+"
	functionDefRE = precedeCommandRE functionRE functionCallRE followDefRE 

	classNameRE = varRE
	classRE = "class" blankRE "+"
	classSepRE = blankRE "*:" blankRE "*" 
	#classDefRE = precedeCommandRE classRE classNameRE "(" classSepRE \
  		#classNameRE ")*" followDefRE   # allow inherited classes to be specified
	classDefRE = "(" precedeCommandRE ")(" classRE ")(" classNameRE ")"  "(" \
		classSepRE "(" classNameRE "))*(" followDefRE ")"
	attributeNameRE = varRE
	attributeRE = "(attribute|attr|property|prop|element|elem|variable|var)" blankRE "+"
	attributeDefRE = "(" precedeCommandRE ")(" attributeRE ")(" attributeNameRE ")"
	#attributeDefRE = "(" precedeCommandRE ")(" attributeRE ")(" attributeNameRE ")(" followCommandRE ")"

	objectNameRE = varRE
	# (old version) objectDefRE = precedeCommandRE objectNameRE blankRE "*=" blankRE "*New" blankRE "+" classNameRE followCommandRE 
	# in keeping with AWK behavior, an object can be created anywhere so it can be
	# stored anywhere
	objectDefRE = classNameRE "[.]new" "(" parametersRE ")?"

	methodNameRE = varRE
	methodRE = "method" blankRE "+"
	methodDefRE = precedeCommandRE methodRE methodNameRE parametersRE  followDefRE 
	methodCallRE = objectNameRE "[.]" methodNameRE "(" parametersRE ")?"

	# wrong --> includeRE = precedeCommandRE blankRE "*@include" blankRE "+(" stringRE ")("\
		attrSepRE stringRE ")*"
}

