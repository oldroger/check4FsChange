.PHONY: clean test

MKDIR_PV = mkdir -pv
ROOT_TEST_DIR = test_dir
TEST_LOG:=test.log
CHECK_4_FS_CHANGE = ../../check4FsChange.sh
TEST_DIR_ABS_PATH:=$(shell realpath test_dir)


ALL: good_tests

good_tests: check_snapshot_former check_snapshot_later
bad_tests: 

#how to call mkdir -pv $(ROOT_TEST_DIR)/test_{1,2,3}/test_{a,b,c} within a makefiles? 
test_dir_initial:	
	$(MKDIR_PV) $(ROOT_TEST_DIR)/test_1/test_c
	$(MKDIR_PV) $(ROOT_TEST_DIR)/test_2/test_c
	$(MKDIR_PV) $(ROOT_TEST_DIR)/test_3/test_c
	$(MKDIR_PV) $(ROOT_TEST_DIR)/test_1/test_b
	$(MKDIR_PV) $(ROOT_TEST_DIR)/test_2/test_b
	$(MKDIR_PV) $(ROOT_TEST_DIR)/test_3/test_b
	$(MKDIR_PV) $(ROOT_TEST_DIR)/test_1/test_a
	$(MKDIR_PV) $(ROOT_TEST_DIR)/test_2/test_a
	$(MKDIR_PV) $(ROOT_TEST_DIR)/test_3/test_a

test_dir_further:
	$(MKDIR_PV) $(ROOT_TEST_DIR)/test_1/test_c/test_bla
	$(MKDIR_PV) $(ROOT_TEST_DIR)/test_4/test_a
	$(MKDIR_PV) $(ROOT_TEST_DIR)/test_1/test_d



snapshot_former.txt: test_dir_initial
	$(CHECK_4_FS_CHANGE) -s -d $(TEST_DIR_ABS_PATH) -o $@

snapshot_later.txt: test_dir_further
	$(CHECK_4_FS_CHANGE) -s -d $(TEST_DIR_ABS_PATH) -o $@


check_snapshot_former: snapshot_former.txt
	test -e snapshot_former.txt
	test -s snapshot_former.txt


check_snapshot_later: snapshot_later.txt
	test -e snapshot_later.txt
	test -s snapshot_later.txt

bad1: 
	! $(CHECK_4_FS_CHANGE) -s $(TEST_DIR_ABS_PATH) -o $@ > $(TEST_LOG) 2>&1
	egrep "\[ERROR\] You need to name a directory with '-d' for action \"createDirectorySnapshot\"!" $(TEST_LOG)


.PHONY: clean 

clean:
	rm -rf test_dir
	rm -f snapshot_former.txt
	rm -f snapshot_later.txt



