# check4FsChange
Bash script which determines if there was a change in a given direcory against a certain baseline.
####NOTE: ONLY snapshot mode really working at the moment!

##Examples
###Example1
Creates a baseline snapshot into a certain baseline:	
./create4FsChange snapshot \<absolute-path-to-directory\> \<<my-snapshot-direcory-now>\>

###Example2
Creates a baseline snapshot after you made changes to the directory in example 1:
./create4FsChange snapshot \<absolute-path-to-directory\> \<<my-snapshot-direcory-later>\>

###Example3
Now, as you have two snaphost, you want to compare them to
./createFsChange compare \<<my-snapshot-direcory-now>\> \<<my-snapshot-direcory-later>\> \<my-diff-file\>
