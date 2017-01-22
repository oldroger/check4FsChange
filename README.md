# check4FsChange
Bash script which determines if there was a change in a given direcory against a certain baseline.
####NOTE: ONLY snapshot mode really working at the moment!

##Examples
###Example1
Creates a baseline snapshot into and store it to a certain file:  

	./create4FsChange snapshot <absolute-path-to-directory> <my-snapshot-file-now>

###Example2
Creates a snapshot after you made changes to the directory in example 1:
  
	./create4FsChange snapshot <absolute-path-to-directory> <my-snapshot-file-later>

###Example3
Now, as you have two snaphots, you might want to compare them to:  

	./createFsChange compare <my-snapshot-file-now> <my-snapshot-file-later> <my-diff-file>


