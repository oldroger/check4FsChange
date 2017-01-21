#!/bin/bash

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

readonly VERSION=0.1

#todo:
#absolute for snapshot necessary?
#silent mode/verbose mode

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

#$1 former file list
#$2 later file list
#$3 file to store result which shows added (+) and deleted (-) files
#$4 indicator wether to extract added or deleted files
function generalCompareSnapshots
{
	local outFile=	
	if [ ! -z $4] && ( [ $4 == "$EXTRACT_DELETED" ] || [ $4 == "$EXTRACT_ADDED" ] ); then
		outFile=/tmp/$3
	else
		outFile=$3
	fi
	
	compareSnapshots $1 $2 $outFile
	
	if [ ! -z $4];then
		extractFiles $3 $4 
		rm $outFile
	fi
}


#Retrieves added files from a diff created by createDiffFileList and stores result to a files only showing the absolute pathes (no '+').
#$1 file to store result
#$2 indicator wether to extract added or deleted files
function extractFiles
{			
	charToFind=	
	if [ $2 == "extractDeleted" ];then
		charToFind='-'
	elif [ $2 == "extractAdded" ];then
		charToFind='+'
	fi

	if [ -z charToFind ];then
		errorAndExit "Internal error occured. Don't what to extract." 	
	fi
	
	while IFS='' read -r line || [[ -n "$line" ]]; do
        if [[ $line == $charToFind* ]]
        then
                echo "$line" |  cut -c 2- >> $2
        fi
	done < "$1"
}	



#Compares two files created with createFileList and stores resulting diff in given file.
#$1 former file list
#$2 later file list
#$3 file to store result which shows added (+) and deleted (-) files
function compareSnapshots
{
	printInfo "Comparing $1 and $2 - result will be stored in $3!"	
	
	diff -daU 0 $1 $2 | grep -vE '^(@@|\+\+\+|---)' > $3
}

#Scans files in a given directory and stores result in a file.
#arg1 directory to scan
#arg2 output file to store file list
function createSnapshot
{
	REDIRECT=	
	if [[ ! -z $2 ]]; then
		REDIRECT="> $2"
		printInfo "Scanning directory $1 for snapshot and putting output to $OUTPUT!"				
	else
		printInfo "Scanning directory $1 for snapshot!"
	fi
		
	find $1 -xdev | sort `$REDIRECT`
}

function print
{
	printf "$PROGNAME: $1\n" 1>&2
}

function printUsage
{
	echo -e "Dropbox Snyc v$VERSION"
    echo -e "Philipp Savun - philipp.savun@gmx.de\n"
    echo -e "Usage: $PROGNAME"
    echo -e "\nModes:"
	echo -e "\tsnapshot: create a file list of your directory."
	echo -e "\t\tCompare it to another file list of the same directory you"
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
	echo -e "\t\twhere <OUTPUT_FILE> is the file where the file list with"
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


function printSnapshotUsage
{
	echo -e "Dropbox Snyc v$VERSION"
    echo -e "Philipp Savun - philipp.savun@gmx.de\n"
    echo -e "Usage for snapshot feature: $PROGNAME snapshot -d <DIRECORY> -o <OUTPUT_FILE>"  
	echo -e "\t\twhere <DIRECTORY> is the root where you want to make"
	echo -e "\t\tyour snapshot."
	echo -e "\t\twhere <OUTPUT_FILE> is the file where the file list with"
	echo -e "\t\tthe current content of your directory is created."
}

function printInfo
{
	print "[INFO] $1" >&2
}

function errorAndExit
{
	print "[ERROR] $1" 	
	exit 1	
}

function setAction
{
	if [ -z $ACTION ];then	
		ACTION="$1"
	else
		errorAndExit "Too many actions!"
	fi
}

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
	
	#realpath strips the trailing '/' so in case this $direcory had one and realpath stripped it the second check ist done
	if [ `realpath $directory` != $directory ] && [ `realpath $directory`'/' != $directory ];then
		errorAndExit "$directory is not absolute - please provide the full path!"
	fi
}

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

function checkDeps
{
	local BIN_DEPS="realpath"
	
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

#argument which parameter is checked
#parameter to be checked
function checkForValidParameterOrExit
{
	if [[ -z $2 ]]; then
		errorAndExit "Parameter for argument \"$1\" missing!"
	elif [[ $2 == -* ]] || [[ $2 == --* ]]; then
		errorAndExit "Parameter \"$2\" not valid for argument \"$1\"!"
	fi
}

#Used example of https://gist.github.com/dgoguerra/9206418
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
function parseAndExecureForCompareMode
{
	local IN_SNAPSHOT_FORMER=
	local IN_SNAPSHOT_LATER=
	local OUT_FILE=	
	local EXTRACT_MODE=
	
	readonly local EXTRACT_DELETED="extract_deleted"
	readonly local EXTRACT_ADDED="extract_added"

	local extractDeletedFiles=false
	local extractAddedFiles=false
	
	while [ "$#" -gt 0 ];do
		case "$1" in
			-a|--added ) extractAddedFiles=true
				;;
			-f|--formter ) #existent and readable 
				IN_SNAPSHOT_FORMER=$OPTARG
				;;	
			-h|--help ) printUsage
				exit 0
				;;
			-l|--later ) #existent and readable 
				IN_SNAPSHOT_LATER=$OPTARG
				;;
			-o|--out ) #out file should be able to be created and read, error if it already exists 
				OUT_FILE=$OPTARG
				;;		
			-x|--deleted ) extractDeletedFiles=true
				;;
		   	-* ) errorAndExit "Parameters not set correctly!"
				;;
			* )
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
		$EXTRACT_MODE = $EXTRACT_ADDED
	else # $extractDeletedFiles == true
		$EXTRACT_MODE = $EXTRACT_DELETED
	fi

	generalCompareSnapshots $IN_SNAPSHOT_FORMER $IN_SNAPSHOT_LATER $OUT_FILE $EXTRACT_MODE
}

readonly SNAPSHOT_MODE="snapshot"
readonly COMPARE_MODE="compare"

MODE=
IN_DIRECTORY=

checkDeps

if [[ -z "$1" ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]] ; then
	printUsage
	exit 0
elif [[ "$1" = $SNAPSHOT_MODE ]] ; then
	MODE="$SNAPSHOT_MODE"   
elif [[ "$1" = $COMPARE_MODE ]] ; then
	MODE="$COMPARE_MODE"
else
	errorAndExit "No valid program mode named. Must be \"snapshot\" or \"compare\"!"
fi
shift

if [ $MODE == $SNAPSHOT_MODE ];then
	parseAndExecureForSnapshotMode $@
else #$MODE == $COMPARE_MODE
	parseAndExecureForCompareMode $@
fi







