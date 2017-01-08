#!/bin/bash


#Retrieves added files from a diff created by createDiffFileList and stores result to a files only showing the absolute pathes (no '+').
#$1 diff file created by createDiffFileList
#$2 file to store added files ad directories
function createAddedFileList
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
function createDiffFileList
{
	diff -daU 0 $1 $2 | grep -vE '^(@@|\+\+\+|---)' > $3
}

#Scans files in a given directory and stores result in a file.
#arg1 directory to scan
#arg2 output file to store file list

function createFileList
{
	find $1 -xdev | sort > $2
}

