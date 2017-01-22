.PHONY: clean test

MKDIR_PV = mkdir -pv
ROOT_TEST_DIR = test_dir
TEST_LOG:=test.log
CHECK_4_FS_CHANGE = ../../check4FsChange.sh
TEST_DIR_ABS_PATH:=$(shell realpath test_dir)

ALL: 	prerequesites \
	 	good_tests \
		fail_tests 

good_tests: good_no_snapshot_arguments \
			good_snapshot_help_long \
			good_snapshot_help_short \
			good_snapshot_no_output_arg \
			good_snapshot_all_arguments
			#check_snapshot_former check_snapshot_later

fail_tests: fail_snapshot_no_directory_arg \
			fail_snapshot_invalid_directory_name \
			fail_snapshot_directory_not_existing \
			fail_snapshot_no_directory_name \
			fail_snapshot_directory_name_not_absolute

prerequesites: test_dir_initial

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

good_no_snapshot_arguments:
	$(CHECK_4_FS_CHANGE) snapshot > $(TEST_LOG) 2>&1
	tail -n +4 $(TEST_LOG) | diff reference_snapshot_usage.txt -

good_snapshot_help_long:
	$(CHECK_4_FS_CHANGE) snapshot --help > $(TEST_LOG) 2>&1
	tail -n +4 $(TEST_LOG) | diff reference_snapshot_usage.txt -

good_snapshot_help_short:
	$(CHECK_4_FS_CHANGE) snapshot -h > $(TEST_LOG) 2>&1
	tail -n +4 $(TEST_LOG) | diff reference_snapshot_usage.txt -

good_snapshot_no_output_arg: test_dir_initial
	$(CHECK_4_FS_CHANGE) snapshot -d $(realpath test_dir) > $(TEST_LOG) 2>&1
	diff $(TEST_LOG) reference_snapshot_no_output.txt

good_snapshot_all_arguments: test_dir_initial
	$(CHECK_4_FS_CHANGE) snapshot -d $(realpath test_dir) -o snapshot.txt > $(TEST_LOG) 2>&1
	diff snapshot.txt reference_snapshot_to_file.txt

fail_snapshot_no_directory_arg:
	! $(CHECK_4_FS_CHANGE) snapshot -o snapshot.txt > $(TEST_LOG) 2>&1
	diff $(TEST_LOG) reference_snapshot_no_directory.txt

fail_snapshot_invalid_directory_name:
	! $(CHECK_4_FS_CHANGE) snapshot -d -o snapshot.txt > $(TEST_LOG) 2>&1
	diff $(TEST_LOG) reference_snapshot_parameter_for_directory_invalid.txt

fail_snapshot_directory_not_existing:
	! $(CHECK_4_FS_CHANGE) snapshot -d blablub snapshot.txt > $(TEST_LOG) 2>&1
	diff $(TEST_LOG) reference_snapshot_directory_not_existing.txt
	
fail_snapshot_no_directory_name:
	! $(CHECK_4_FS_CHANGE) snapshot -d > $(TEST_LOG) 2>&1
	diff $(TEST_LOG) reference_snapshot_parameter_for_directory_missing.txt

fail_snapshot_directory_name_not_absolute:
	! $(CHECK_4_FS_CHANGE) snapshot -d test_dir > $(TEST_LOG) 2>&1
	diff $(TEST_LOG) reference_snapshot_directory_name_not_absolute.txt


#check with "relatively" arbitrary string, that firs argument needs to be "snaphot" or "compare"
#general test
fail_no_valid_command: 
	! $(CHECK_4_FS_CHANGE) -s $(TEST_DIR_ABS_PATH) > $(TEST_LOG) 2>&1
	egrep "\[ERROR\] No valid program mode named. Must be \"snapshot\" or \"compare\"!" $(TEST_LOG)

.PHONY: clean 

clean:
	rm -rf test_dir \
	snapshot_former.txt \
	snapshot_later.txt \
	snapshot.txt \
	test.log



