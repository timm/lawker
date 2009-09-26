awk++

IMPORTANT NOTES:

1) awk++ is a 'preprocessor', in the sense that it reads in a program written in
the awk++ language and outputs a new program. It can be used as a run time interpreter,
ala 'igawk', by running the included shell script or BAT file. However, it's
different than 'awka'. The output from the awk++ preprocessor is awk code, not C
or an executable program. So, some version of AWK, such as awk or gawk, has
to be used to run the 'preprocessed' program. 'awka' can be used, in a second step,
to turn the preprocessed awk++ program into an executable, if desired. 

The command to preprocess a program looks like this:

gawk -f awk++.awk file-name-of-awk++-program

2) There is a bug in the standard AWK distributions that affects the preprocessor.
Additionally, the preprocessor uses the 3rd array option of the match() function.
So, it's best to use GAWK to run the preprocessor.

On the other hand, the AWK code created by translating awk++ code is intended
to work with all versions of AWK. If you find otherwise, please notify the
developer.

-----------------------

The awk++ language provides object oriented programming for AWK that includes:
	- classes
	- class properties (persistent object variables)
	- methods
	- inheritance

  Method polymorphism is planned.


Support for lists as a data structure is also planned.
(an AWK addition, not an OO feature)

A list can be used anywhere that text can be, and consists of constants and
variables that are separated by commas and contained in braces. For example:

 {vara,arrayb,1,"Hello"}

 In addition, a list can be assigned to multiple variables in one statement like this:

  a,b,c = {"Hello","World","!"}


-------
 OO syntax goals:
 - easy to parse and match to awk code using an awk program as the "preprocessor"
 - easy to understand
 - easy to remember
 - easy and fast to type
 - distinct from existing AWK syntax


The OO syntax is based partly on C++, partly on Javascript, partly on Ruby and
partly on the book "The Object-Oriented Thought Process". It isn't lifted in
toto from one langauage because other languages provide features that gawk can't
accomplish or have syntax that is hard to parse using regular expressions. (I
have no desire to write a character-by-character parser.) 

 In particular, Javascript
 - doesn't support inheritance (desirable)
 - determines variable scope automatically (gawk doesn't)
 - a variable can contain a function (gawk supports only 'string' and 'number' types)

 C++
- allows classes, variables and methods to be private or public. awk can only
do variables, and those in a limited way.

------------ 


 OO syntax for awk++.
---------------------

Synopsis:


a = class1.new[(optional parameters)]   *** similar to Ruby

b = a.get("aProperty")

a.delete

class class1 {

  property aProperty

  method new([optional parameters]) {
  	# put initialization stuff here
  }

  method get(propName) {
      if(propName = "aProperty")
	  	return aProperty              ### Note the use of 'return'. It behaves
		                              ### exactly the same as in an AWK function.
  }
}


Details:

*** To define a class (similar to C++ but no public/private):

  class class_name {.....}


*** To define a class with inheritance (similar to C++ but no public/private):

 class class_name : inherited_class_name [ : inherited_class_name...] {.....}


*** To add local/private variables (persistent variables; syntax is unique to awk++):

  class class_name {

	attribute|attr|property|prop|element|elem|variable|var variable_name     
 ..... }


To help programmers who are used to other OO languages, "attribute",
"property", "element", and "variable", along with their 4-letter abbreviations,
are interchangeable. 

Note: these persistent variables cannot be accessed directly. The programmer
must define method(s) to return them, if their values are to be made available
to code that's outside the class.

*** To add methods

  class class_name {

	attribute variable_name1

	method method_name(parameters) {
	...any awk code....
	}
 ..other method definitions...
  }



*** To define an object

 object_variable = class_name.new[(optional parameters)] 
 
 (runs the method named "new", if it exists; returns an integer)


# To call an object method

 object_variable.method_name(parameters)

 ( The dot isn't used for concatenation in awk/gawk, so it's a natural choice
 for the separator between the object and method. It's also simple to type, and
 it's the same as Javascript. ) 

# To reclaim the memory used by an object, use the delete method, i.e.:

  object_variable.delete

 but don't define delete() in your classes. awk++ recognizes delete() as a special
 method and will take care of deleting the object. Note: deleting objects is
 only necessary if the program creates a lot of them or if they hold a lot of
 data. Object variables are the only significant overhead. 


*** Naming and behavior rules:

 Classes must obey the same rules as user defined functions.

 Method names must follow the same rules as AWK function names.

 Class "local" variable names (properties, attributes, etc.) must follow the same
 rules as AWK variables.

 Objects are number variables, so they must obey number variable rules. However,
 the values in variables holding objects should never be changed, as they are
 simply identifiers. Performing math operations on them is meaningless.

 Calls to undefined methods do nothing and return nothing, silently.

 As one might expect, AWK syntax errors will show up when the "preprocessed" program
 is run, so one of awk++'s goals is to assist debugging by keeping the line numbers
 matched between the source and preprocessed code. However, this isn't guaranteed
 to be possible for all programs, so the programmer shouldn't assume that the
 match is exact. 

Copyright (c) 2008 Jim Hart, jhart@mail.avcnet.org
All rights reserved. Licensed under the GNU Public license (GPL) any version.
 August 2008, December 2008

