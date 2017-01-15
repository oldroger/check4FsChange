.PHONY: clean test

MKDIR_PV = mkdir -pv
ROOT_TEST_DIR = test_dir
TEST_LOG:=test.log
CHECK_4_FS_CHANGE = ../../check4FsChange.sh
TEST_DIR_ABS_PATH:=$(shell realpath test_dir)


ALL: good_tests


usage_tests: usage_test1 
bad_tests: 

usage_test1: 
	$(CHECK_4_FS_CHANGE) 
	

bad_tests: 
	! $(CHECK_4_FS_CHANGE) -s $(TEST_DIR_ABS_PATH) -o $@ > $(TEST_LOG) 2>&1
	egrep "\[ERROR\] You need to name a directory with '-d' for action \"createDirectorySnapshot\"!" $(TEST_LOG)




.PHONY: clean 

clean:




