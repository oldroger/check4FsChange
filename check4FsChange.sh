#!/bin/bash

ACTION=
IN_DIRECTORY=
IN_FILE_1=
IN_FILE_2=
OUT_FILE=

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

#Retrieves added files from a diff created by createDiffFileList and stores result to a files only showing the absolute pathes (no '+').
#$1 diff file created by createDiffFileList
#$2 file to store added files ad directories
function extractAddedFiles
{
	while IFS='' read -r line || [[ -n "$line" ]]; do
        if [[ $line == +* ]]
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
	diff -daU 0 $1 $2 | grep -vE '^(@@|\+\+\+|---)' > $3
}

#Scans files in a given directory and stores result in a file.
#arg1 directory to scan
#arg2 output file to store file list
function createDirectorySnapshot
{
	printInfo "Scanning directory $1 and putting output to file $2!"	
	find $1 -xdev | sort > $2
}

function print
{
	printf "$PROGNAME: $1\n" 1>&2
}

function printUsage
{
	echo "Usage:"
}

function printInfo
{
	print "[INFO] $1"
}

function errorAndExit
{
	print "[ERROR] $1" 	
	printUsage
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

#function checkNumberOfArguments
#{
#	if [ $1 != $2 ];then
#		errorAndExit "Wrong number of arguments!"
#	fi	
#}

#sanitycheck



checkDeps

while getopts "hs:o:c1:2:" options; do
  case $options in
    s ) IN_DIRECTORY=$OPTARG
		setAction "createDirectorySnapshot"
		acceptDirectoryOrExit $IN_DIRECTORY
		;; 
	
	c ) setAction "compareSnapshots"
		;;
	
	1 ) IN_FILE_1=$OPTARG
		;;
	2 ) IN_FILE_2=$OPTARG
		;;
	o ) #out file should be able to be created and read, error if it already exists 
		OUT_FILE=$OPTARG
		;;	

    h ) printUsage
        exit 0
        ;;
   \? ) errorAndExit "Parameters not set correctly!"
		;;
  esac
done

if [ -z $ACTION ] ;then
	errorAndExit "There has to be exactly one argument s) or c)!"
fi

printInfo "Executing action $ACTION on directory $IN_DIRECTORY - Output in $OUT_FILE" 

#local variable and local check or what?
case $ACTION in
	"createDirectorySnapshot" ) createDirectorySnapshot $IN_DIRECTORY $OUT_FILE
								;;
	"compareSnapshots" ) createDirectorySnapshot $IN_DIRECTORY $OUT_FILE
									;;
	*) ;;
esac





