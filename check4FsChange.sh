#!/bin/bash

PROGNAME=$0

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
	if [ ! -z $4] && ( [ $4 == "extractDeleted" ] || [ $4 == "extractAdded" ] ); then
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
	printInfo "Scanning directory $1 for snapshot and putting output to file $2!"	
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

ACTION=
IN_DIRECTORY=
IN_SNAPSHOT_FORMER=
IN_SNAPSHOT_LATER=
OUT_FILE=
extractAddedFiles=false
extractDeletedFiles=false


checkDeps

while getopts "acd:f:l:ho:sx" options; do
  case $options in
	a ) extractAddedFiles=true
		setAction "compareSnapshots"
		;;   
	c ) setAction "compareSnapshots"
		;;	
	d ) IN_DIRECTORY=$OPTARG
		acceptDirectoryOrExit $IN_DIRECTORY
		;; 
	f ) #existent and readable 
		IN_SNAPSHOT_FORMER=$OPTARG
		;;	
    h ) printUsage
        exit 0
        ;;
	l ) IN_SNAPSHOT_LATER=$OPTARG
		;;
	o ) #out file should be able to be created and read, error if it already exists 
		OUT_FILE=$OPTARG
		;;	
	s ) setAction "createSnapshot"
		;;	
	x ) extractDeletedFiles=true
		setAction "compareSnapshots"
		;;
   \? ) errorAndExit "Parameters not set correctly!"
		;;
  esac
done

if [ -z $ACTION ] ;then
	errorAndExit "There has to be exactly one argument s) or c)!"
fi

if [ $ACTION == "createSnapshot" ] && [ -z $IN_DIRECTORY ] ;then
	errorAndExit "You need to name a directory with '-d' for action \"$ACTION\"!"
fi

if 	( [ $ACTION == "compareSnapshots" ] || [ $ACTION == "compareSnapshotsExtractDeleted" ] || [ $ACTION == "compareSnapshotsExtractAdded" ] ) && 
	( [ -z $IN_SNAPSHOT_FORMER ] && [ -z $IN_SNAPSHOT_LATER ]) ;then
	errorAndExit "You need to name the former and later snapshots for action \"$ACTION\"!"
fi

if [ $extractAddedFiles == true ] && [ $extractDeletedFiles == true ];then
	errorAndExit "Only one of -a (extract added files) or -x (extract deleted files) possible!"
fi

#local variable and local check or what?
case $ACTION in
	"createSnapshot" ) 					createSnapshot $IN_DIRECTORY $OUT_FILE
										;;
	"compareSnapshots" ) 				generalCompareSnapshots $IN_SNAPSHOT_FORMER $IN_SNAPSHOT_LATER $OUT_FILE
										;;
	"compareSnapshotsExtractDeleted" ) 	generalCompareSnapshots $IN_SNAPSHOT_FORMER $IN_SNAPSHOT_LATER $OUT_FILE "extractDeleted"
										;;
	"compareSnapshotsExtractAdded" ) 	generalCompareSnapshots $IN_SNAPSHOT_FORMER $IN_SNAPSHOT_LATER $OUT_FILE "extractAdded"
										;;
	*) ;;
esac





