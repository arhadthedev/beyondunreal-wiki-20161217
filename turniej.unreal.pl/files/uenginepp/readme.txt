It's copy of UT3 preprocessor. Currently supported directives are:

	`process - should be in the first line of .uc file. Tells preprocessor to parse file
	`include file - embade file in the currently opened .uc (do not parses it)
	`inc_process file - embade file in the currently opened .uc and parses it
	`define variable - defines empty variable (used in `ifdef and `ifndef directives)
	`define variable=value - defines variable with specified value
	`write variable - writes defined variable
	`ifdef variable - evaluates to true if variable is defined
	`ifndef variable - evaluates to true if variable is not defined
	`else  - part of conditional statement
	`endif - ends conditional statement
	`check definition==value - evaluates to true if defined variable (definition) equals value. Used in strings, floats, integers.
	`check definition<>value - evaluates to true if defined variable (definition) does not match value. Used in strings, floats, integers.
	`check definition>value - evaluates to true if defined variable (definition) is greater then value. Used in floats, integers.
	`check definition<value - evaluates to true if defined variable (definition) is less then value. Used in floats, integers.

usage:

	utpreprocessor <project_dir>/<project_file> <modifiers>

	where:

		<project_dir> - relative project directory.
		<project_file> - file (.upc extension) conaining all options. If file is detected, no fuhrer modifiers are checked.

	modifiers:

		-clean - deletes preprocessor directives from .uc file
		-debug - turns on debug mode (prints every operation on parsed .uc file)
		-make <ini file> - runs ucc.exe with specified ini
		-h - prints help
                -global someglobal=somevalue - defines global variable

project file:


	[project]                 - project informations
	path=path                 - path to project
	debug=true                - turns on debug mode (prints every operation on parsed .uc)
	make=true                 - if true, ucc will be executed
	make_ini=ini_file.ini     - if present runs ucc.exe with specified ini
	clean=true                - if true will delete preprocessor directives
	output=folder             - override default output folder where parsed .uc files are written
	input=folder              - override default input folder where parsed .uc files are stored

	[globals]                 - group contatin global variables for whole project
	someglobal=somevalue      - global variable (sample)

example:

	[project]
	path=../MyProject/
	debug=true
	make=true
	make_ini=make.ini
	clean=true
	output=classes
	input=classes_ucp

	[globals]
	global_value1=test1
	global_value2=test2
	
	
Let's say you have project file in <UTDir>/system called RUI.upc with content:

Code:
[project]
path=../RComputerUI/
debug=true
make=true
make_ini=make.ini
clean=true
output=classes
input=classes_ucp


whe you'll call uenginepp.exe RUI.upc parser will process all files in classes_ucp, and generates output code in classes, which will be striped out (or not) from preprocessor directives. Let's say you have class:


Code:
`process
`define int1=120
`define int2=123
`define nc=var() class<actor> NewActor;
class PreProcessorTest extends Actor;

`check int1>int2
var() int test1;
`else
var() int test2;
`write nc
`endif


You run preprocessor and:

1. `process directive is found, so preprocessor knows that this class has to be parsed
2. it sets int1 variable as 120
3. it sets int2 variable as 123
4. it sets nc variable as var() class<actor> NewActor;
5. it detects `check directive and compare int1 and int2. because int1 is smaller then int2, expression evaluates to false and all next lines are skipped and deleted
6. it detects `else directive. preprocessor stops deleting lines and searches for next directives
7. var() int test2; is not detected as directive so it's left alone
8. directive `write is detected. preprocessor searches for variable named nc and (if found) writes it in .uc file
9. directive `endif stops conditional expression

output .uc file in classes will look like:

Code:
class PreProcessorTest extends Actor;

var() int test2;
var() class<actor> NewActor;

Now same output code with clean turned off:

Code:
////`process
//`define int1=120
//`define int2=123
//`define nc=var() class<actor> NewActor;
class PreProcessorTest extends Actor;

////`check int1>int2
//var() int test1;
//`else
var() int test2;
var() class<actor> NewActor; //`write nc
//`endif

Of course input file can look different, but most important thing is to write `process in first line.