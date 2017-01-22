.PHONY: clean test

MKDIR_PV = mkdir -pv
ROOT_TEST_DIR = test_dir
TEST_LOG:=test.log
CHECK_4_FS_CHANGE = ../../check4FsChange.sh
TEST_DIR_ABS_PATH:=$(shell realpath test_dir)

ALL: good_tests
	 	
good_tests: good_no_compare_arguments \
			good_compare_help_short \
			good_compare_help_long

fail_tests: 

prerequesites: check_snapshot_former check_snapshot_later

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
	$(CHECK_4_FS_CHANGE) snapshot -d $(TEST_DIR_ABS_PATH) -o $@

snapshot_later.txt: test_dir_further
	$(CHECK_4_FS_CHANGE) snapshot -d $(TEST_DIR_ABS_PATH) -o $@

check_snapshot_former: snapshot_former.txt
	test -e $<
	test -s $<
	diff $< reference_snapshot_former.txt 

check_snapshot_later: snapshot_later.txt
	test -e $<
	test -s $<
	diff $< reference_snapshot_later.txt 

good_no_compare_arguments: prerequesites
	$(CHECK_4_FS_CHANGE) compare  > $(TEST_LOG) 2>&1
	tail -n +4 $(TEST_LOG) | diff reference_compare_usage.txt -

good_compare_help_short: prerequesites
	$(CHECK_4_FS_CHANGE) compare -h > $(TEST_LOG) 2>&1
	tail -n +4 $(TEST_LOG) | diff reference_compare_usage.txt -

good_compare_help_long: prerequesites
	$(CHECK_4_FS_CHANGE) compare --help > $(TEST_LOG) 2>&1
	tail -n +4 $(TEST_LOG) | diff reference_compare_usage.txt -

good_compare_no_optional_args: prerequesites
	$(CHECK_4_FS_CHANGE) compare -f snapshot_former.txt -l snapshot_later.txt > $(TEST_LOG) 2>&1
	tail -n +4 $(TEST_LOG) | diff reference_compare_usage.txt -

.PHONY: clean 

clean:
	rm -rf test_dir \
	snapshot_former.txt \
	snapshot_later.txt \
	test.log



