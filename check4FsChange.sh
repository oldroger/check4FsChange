#!/bin/bash

#todo:
#absolute for snapshot necessary?
#silent mode/verbose mode
#check for valid files
#tests for snapshot into output file missing
#mv some tests from snapshot to general and complete those tests

#program version
readonly VERSION=0.2
#external command line programs used by this one
readonly BIN_DEPS="realpath getopt"

# File name
readonly PROGNAME=$(basename $0)
# File name, without the extension
readonly PROGBASENAME=${PROGNAME%.*}
# File directory
readonly PROGDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# Arguments
readonly ARGS="$@"
# Arguments number
readonly ARGNUM="$#"

readonly EXTRACT_DELETED="extract_deleted"
readonly EXTRACT_ADDED="extract_added"

#checks for if all programs used by this one are available on this system
function checkDeps
{
	which $BIN_DEPS > /dev/null
	if [[ $? != 0 ]]; then
		for i in $BIN_DEPS; do
		    which $i > /dev/null ||
		        NOT_FOUND="$i $NOT_FOUND"
		done
		echo -e "Error: Required program could not be found: $NOT_FOUND"
		exit 1
	fi
}

#general function which can execute all compare functions
#it takes the former snapshot file as as first and the later snapshot as second parameter
#then it needs a file name to store the result
#with the last parameter you can optionally say if the result should be just added or deleted files
###
#$1 former snapshot
#$2 later snapshot
#$3 file to store result
#$4 indicator wether to extract added or deleted files
function generalCompareSnapshots
{
	if [[ ! -z $3 ]];then	
		printInfo "Comparing $1 and $2 - result will be stored in $3!"		
	else
		printInfo "Comparing $1 and $2"
	fi
	
	local outFile=	
	if [ ! -z $4 ] && ( [ $4 == "$EXTRACT_DELETED" ] || [ $4 == "$EXTRACT_ADDED" ] ); then
		outFile=/tmp/$3
	else
		outFile=$3
	fi
	
	compareSnapshots $1 $2 $outFile
	
	if [ ! -z $4 ];then
		local inputFile=$outFile
		local outFile=$3	
		extractFiles $inputFile $4 $outFile
		#rm $outFile
	fi
}


#Extracts added or deleted files from a snapshot
#strips preceding added/deleted identifiers '-'/'+' off
###
#parameter $1: file read input from
#parameter $2: indicator wether to extract added or deleted files
#parameter $3: file to store extracted lines
function extractFiles
{			
	set -x	
	local inputFile=$1
	local outputFile=$3

	charToFind=	
	if [[ $2 == $EXTRACT_DELETED ]];then
		charToFind='-'
	elif [[ $2 == $EXTRACT_ADDED ]];then
		charToFind='+'
	fi

	if [ -z $charToFind ];then
		errorAndExit "Internal error occured. Don't know what to extract." 	
	fi
	
	#create the file, because in case there was no added line it' irritating if there's nothing at all
	touch $outputFile
	while IFS='' read -r line || [[ -n "$line" ]]; do
        if [[ $line == $charToFind* ]]
        then
                echo "$line" |  cut -c 2- >> $outputFile
        fi
	done < "$inputFile"
	set +x
}	



#Compares two files created with createFileList and stores resulting diff in given file.
###
#parameter $1: former snapshot
#parameter $2: later snapshot
#parameter $3: optional file to store result which shows added (+) and deleted (-) files
function compareSnapshots
{	
	local readonly OUTPUT=$3
	local readonly COMMAND="diff -daU 0 $1 $2 | grep -vE '^(@@|\+\+\+|---)'"
	local REDIRECT=		
	if [[ ! -z $OUTPUT ]]; then
		REDIRECT="> $OUTPUT"
		COMMAND="$COMMAND $REDIRECT"
	fi

	eval ${COMMAND}
}

#Scans files in a given directory
#Optionally redirects to a file or to stdout as default
#parameter 1: directory to scan
#parameter 2: output file to store snapshot (optional)
function createSnapshot
{
	local readonly OUTPUT=$2 	
	local readonly COMMAND="find $1 -xdev | sort"	
	local REDIRECT=	
	if [[ ! -z $2 ]]; then
		REDIRECT="> $2"
		COMMAND="$COMMAND $REDIRECT"
		printInfo "Scanning directory $1 for snapshot and putting output to $OUTPUT!"				
	else
		printInfo "Scanning directory $1 for snapshot!"
	fi
	
	eval ${COMMAND}
}

#prints a usage for the whole program
function printUsage
{
	printProgramHeader
    echo -e "Usage: $PROGNAME"
    echo -e "\nModes:"
	echo -e "\tsnapshot: create a snapshot of your directory."
	echo -e "\t\tCompare it to another snapshot of the same directory you"
	echo -e "\t\tmade earlier or you make later."
	echo -e "\tcompare: compare two snapshots."
	echo -e "\t\tYou will get a list with deleted '-' and added '+' files"
	echo -e "\t\tbetween a former and a later snapshot."
	echo -e "\t\tAdditionally you can ask to get only a list with added or"
	echo -e "\t\tdeleleted files. The file names have no prefix '-' or '+'." 
	echo -e "\nSee below how the two modes are used:"    
	echo -e "\tsnapshot -d <DIRECORY> -o <OUTPUT_FILE>"
	echo -e "\t\twhere <DIRECTORY> is the root where you want to make"
	echo -e "\t\tyour snapshot."
	echo -e "\t\twhere <OUTPUT_FILE> is the file where the snapshot with"
	echo -e "\t\tthe current content of your directory is created."
	echo -e "\n\tcommand  -f <FORMER_SNAPSHOT> -l <LATER_SNAPSHOT> -o <OUT_FILE> [-a|-x]"
	echo -e "\t\twhere <FORMER_SNAPSHOT> is the snapshot you made earlier."
	echo -e "\t\twhere <LATER_SNAPSHOT> is the younger snapshot."
	echo -e "\t\twhere <OUT_FILE> is the file where the diff output is stored."
	echo -e "\t\twhere -a indiciates that only files that are in <LATER_SNAPSHOT>" 
	echo -e "\t\tbut not in <FORMER_SNAPSHOT> (added files) should be"
	echo -e "\t\tin <OUT_FILE>."
   	echo -e "\t\twhere -x indiciates that only files that are in"
	echo -e "\t\t<FORMER_SNAPSHOT> but not in <LATER_SNAPSHOT> (deleted files)"
	echo -e "\t\tshould be in <OUT_FILE>."
}

#prints the usage of this program in mode "snapshot"
function printSnapshotUsage
{
	printProgramHeader
    echo -e "Usage for snapshot feature:"
	echo -e "$PROGNAME snapshot -d <DIRECORY> [-o <OUTPUT_FILE>]"  
	echo -e "\t\twhere <DIRECTORY> is the root where you want to make"
	echo -e "\t\tyour snapshot."
	echo -e "\t\twhere <OUTPUT_FILE> is the optional file where the snapshot with"
	echo -e "\t\tthe current content of your directory is created."
}

function printCompareUsage
{
	printProgramHeader
    echo -e "Usage for compare feature:"
	echo -e "$PROGNAME compare -f <FORMER_SNAPSHOT> -l <LATER_SNAPSHOT> [-o <OUTPUT_FILE>] [-a|-x]"  
	echo -e "\t\twhere <FORMER_SNAPSHOT> is the earlier snapshot you made."
	echo -e "\t\twhere <LATER_SNAPSHOT> is the later snapshot you made."
	echo -e "\t\twhere <OUTPUT_FILE> is the optional file where the snapshot with"
	echo -e "\t\tthe current content of your directory is created."
	echo -e "\t\t-a just lists the added files."
	echo -e "\t\t-x just lists the deleted files."
}

#helper function which prints the header
function printProgramHeader
{
	echo -e "Dropbox Snyc v$VERSION"
    echo -e "Philipp Savun - philipp.savun@gmx.de\n"
}

#prints a message as an info message 
###
#parameter 1: the message to be printed
function printInfo
{
	print "[INFO] $1"
}

#prints a message as an error message and exits with error code
###
#parameter 1: the message to be printed
function errorAndExit
{
	print "[ERROR] $1" 	
	exit 1	
}

#prints a given message
#preceds the message with this program name, so root of message can easily be identified
function print
{
	printf "$PROGNAME: $1\n" 1>&2
}

#checks if a directory can be accepted as argument
#because it the name exists, is a directory and has reading permissions and if the path to it is absolute
###
#parameter 1: directory name to be checked
function acceptDirectoryOrExit
{
	local directory=$1
	
	if [ ! -e $directory ];then
		errorAndExit "Directory $directory does not exist!"
	fi
	
	if [ ! -d $directory ];then
		errorAndExit "$directory is not a directory!"
	fi
	
	if [ ! -r $directory ];then
		errorAndExit "No reading permission on $directory!"
	fi
	
	#realpath strips the trailing '/' 
	#so if a directory name was given with trailing '/' we add it to the check
	if [ `realpath $directory` != $directory ] && [ `realpath $directory`'/' != $directory ];then
		errorAndExit "$directory is not absolute - please provide the full path!"
	fi
}

#not used at the moment
#used or get rid of it
function acceptFileToWriteOrExit
{
	local filename=$1
	
	
	if [ ! -e $filename ];then
		errorAndExit "File $directory does not exist!"
	fi
	
	if [ ! -f $filename ];then
		errorAndExit "$filename is not a file!"
	fi
	
	if [ ! -w $filename ];then
		errorAndExit "No writing permission on $filename!"
	fi
	
	if [ ! -r $filename ];then
		errorAndExit "No reading permission on $filename!"
	fi

	#realpath strips the trailing '/' so in case this $direcory had one and realpath stripped it the second check ist done
	if [ `realpath $directory` != $directory ] && [ `realpath $directory`'/' != $directory ];then
		errorAndExit "$directory is not absolute - please provide the full path!"
	fi
}

#Used example of https://gist.github.com/dgoguerra/9206418 for argument checking
#if not argument besides mode is given, print help
#otherwise check for directory and optional output file or if the user requested a helping guidance
#if everything is fine, a snapshot of given directory will be made
###
#parameter 1: program arguments array with the first argument (mode) stripped of
function parseAndExecureForSnapshotMode
{
	local OUT_FILE=	
	local IN_DIRECTORY=

	if [ "$#" == 0 ];then
		printSnapshotUsage
		exit 0
	fi 

	while [ "$#" -gt 0 ];do
		case "$1" in
			-d|--directory )
				checkForValidParameterOrExit $1 $2
				IN_DIRECTORY=$2
				acceptDirectoryOrExit $IN_DIRECTORY
				shift
				;; 
			-h|--help)
				printSnapshotUsage
				exit 0
				;;
			-o|--output)
				OUT_FILE="$2"
				shift
				;;
			-*) errorAndExit "Invalid option '$1'. Use --help to see the valid options!"
				;;
			*)	errorAndExit "Invalid word '$1'. Use --help to see the valid options!"
				;;
		esac
		shift
	done

	if [ -z $IN_DIRECTORY ] ;then
		errorAndExit "You need to name a directory with '-d' for mode \"$MODE\"! Please, see \"$PROGNAME snapshot --help\"!"
	fi
	
	createSnapshot $IN_DIRECTORY $OUT_FILE
}

#Used example of https://gist.github.com/dgoguerra/9206418
#if not argument besides mode is given, print help
#otherwise check for valid snapshot file names and check if only one extract option was given
#if everything is fine, snapshots will be compared and redirected stdin if no output file was named or a file otherwise 
###
#parameter 1: program arguments array with the first argument (mode) stripped of
function parseAndExecureForCompareMode
{
	local IN_SNAPSHOT_FORMER=
	local IN_SNAPSHOT_LATER=
	local OUT_FILE=	
	local EXTRACT_MODE=

	local extractDeletedFiles=false
	local extractAddedFiles=false
	
	if [ "$#" == 0 ];then
		printCompareUsage
		exit 0
	fi 

	while [ "$#" -gt 0 ];do
		case "$1" in
			-a|--added ) extractAddedFiles=true
				;;
			-f|--former ) #existent and readable 
				checkForValidParameterOrExit $1 $2
				IN_SNAPSHOT_FORMER=$2
				shift
				;;	
			-h|--help ) printCompareUsage
				exit 0
				;;
			-l|--later ) #existent and readable 
				checkForValidParameterOrExit $1 $2
				IN_SNAPSHOT_LATER=$2
				shift
				;;
			-o|--out ) #out file should be able to be created and read, error if it already exists 
				checkForValidParameterOrExit $1 $2
				OUT_FILE=$2
				shift
				;;		
			-x|--deleted ) extractDeletedFiles=true
				;;
		   	-* ) errorAndExit "Invalid option '$1'. Use --help to see the valid options!"
				;;
			*)	errorAndExit "Invalid word '$1'. Use --help to see the valid options!"
				;;
	  	esac
		shift
	done

	if [ -z $IN_SNAPSHOT_FORMER ] && [ -z $IN_SNAPSHOT_LATER ] ;then
		errorAndExit "You need to name the former and later snapshots for mode \"$MODE\"!"
	fi

	if [ $extractAddedFiles == true ] && [ $extractDeletedFiles == true ];then
		errorAndExit "Only one of -a (extract added files) or -x (extract deleted files) is possible for mode compare!"
	fi

	if [ $extractAddedFiles == true ];then
		EXTRACT_MODE=$EXTRACT_ADDED
	elif [ $extractDeletedFiles == true ];then
		EXTRACT_MODE=$EXTRACT_DELETED
	fi

	generalCompareSnapshots $IN_SNAPSHOT_FORMER $IN_SNAPSHOT_LATER $OUT_FILE $EXTRACT_MODE

}

#Checks if the parameter to an argument is not mean as another parameter (beginning with '-' or '--' or is missing
###
#parameter 1: argument which parameter should be checked
#parameter 2: parameter itself to be checked
function checkForValidParameterOrExit
{
	if [[ -z $2 ]]; then
		errorAndExit "Parameter for argument \"$1\" missing!"
	elif [[ $2 == -* ]] || [[ $2 == --* ]]; then
		errorAndExit "Parameter \"$2\" not valid for argument \"$1\"!"
	fi
}

#main routine checks dependencies, then the mode, then executes program dependent of mode
###
#main

#all modes used for this program
readonly SNAPSHOT_MODE="snapshot"
readonly COMPARE_MODE="compare" #actually not used, but for clarity

#storage for users choice regarding mode
MODE=

#check availability of programs used by this script
checkDeps


if [[ -z "$1" ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]] ; then
	#if no argument or "help" as first argument give user the usage guidance
	printUsage
	exit 0
elif [[ "$1" = $SNAPSHOT_MODE ]] ; then
	MODE="$SNAPSHOT_MODE"   
elif [[ "$1" = $COMPARE_MODE ]] ; then
	MODE="$COMPARE_MODE"
else
	errorAndExit "No valid program mode named. Must be \"snapshot\" or \"compare\"!"
fi
#shift program arguments as the first is mode and is handled
shift

#execute the program depending on mode
if [ $MODE == $SNAPSHOT_MODE ];then
	parseAndExecureForSnapshotMode $@
else #$MODE == $COMPARE_MODE
	parseAndExecureForCompareMode $@
fi







