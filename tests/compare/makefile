.PHONY: clean test


#grep   -o -P "^/mnt/Dropbox/Development/\K.*" reference_compare_added_files.txt
MKDIR_PV = mkdir -pv
ROOT_TEST_DIR = test_dir
TEST_LOG:=test.log
CHECK_4_FS_CHANGE = ../../check4FsChange.sh
TEST_DIR_ABS_PATH:=$(shell realpath test_dir)
absToRelPath:=grep   -o -P "^$(CURDIR)/\K.*"

ALL: good_tests fail_tests
	 	
good_tests: good_no_compare_arguments \
			good_compare_help_short \
			good_compare_help_long \
			good_compare_no_optional_args_only_added \
			good_compare_no_optional_args_only_deleted \
			good_compare_out_file_added_only_deleted \
			good_compare_out_file_added \
			good_compare_out_file_deleted 
			

fail_tests: fail_compare_no_former_parameter \
			fail_compare_no_later_parameter \
			fail_compare_invalid_argument \
			fail_compare_too_many_extract_arguments			

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

good_compare_no_optional_args_only_added: prerequesites
	$(CHECK_4_FS_CHANGE) compare -f snapshot_former.txt -l snapshot_later.txt > $(TEST_LOG) 2>&1
	diff $(TEST_LOG) reference_compare_no_optional_args.txt 

good_compare_no_optional_args_only_deleted: prerequesites
	$(CHECK_4_FS_CHANGE) compare -f snapshot_later.txt -l snapshot_former.txt > $(TEST_LOG) 2>&1
	diff $(TEST_LOG) reference_compare_no_optional_args_deleted.txt 

good_compare_out_file_added_only_deleted: prerequesites
	$(CHECK_4_FS_CHANGE) compare -f snapshot_later.txt -l snapshot_former.txt -o added_files.txt -a > $(TEST_LOG) 2>&1
	! test -s added_files.txt 

good_compare_out_file_added: prerequesites
	$(CHECK_4_FS_CHANGE) compare -f snapshot_former.txt -l snapshot_later.txt -o added_files.txt -a > $(TEST_LOG) 2>&1
	$(absToRelPath) added_files.txt | diff - reference_compare_added_files.txt

good_compare_out_file_deleted: prerequesites
	$(CHECK_4_FS_CHANGE) compare -f snapshot_later.txt -l snapshot_former.txt -o deleted_files.txt -x > $(TEST_LOG) 2>&1
	$(absToRelPath) deleted_files.txt | diff - reference_compare_deleted_files.txt

fail_compare_no_former_parameter: prerequesites
	! $(CHECK_4_FS_CHANGE) compare -f -l snapshot_later.txt > $(TEST_LOG) 2>&1
	diff $(TEST_LOG) reference_compare_no_former_parameter.txt

fail_compare_no_later_parameter: prerequesites
	! $(CHECK_4_FS_CHANGE) compare -f snapshot_former.txt -l > $(TEST_LOG) 2>&1
	diff $(TEST_LOG) reference_compare_no_later_parameter.txt

fail_compare_invalid_argument: prerequesites
	! $(CHECK_4_FS_CHANGE) compare -f snapshot_former.txt -l snapshot_later.txt -o deleted_files.txt -y > $(TEST_LOG) 2>&1
	diff $(TEST_LOG) reference_compare_invalid_argument.txt

fail_compare_too_many_extract_arguments: prerequesites
	! $(CHECK_4_FS_CHANGE) compare -f snapshot_former.txt -l snapshot_later.txt -o deleted_files.txt -a -x > $(TEST_LOG) 2>&1
	diff $(TEST_LOG) reference_compare_too_many_extract_arguments.txt

	
 
test_1:
	echo $(absToRelPath)


.PHONY: clean 

clean:
	rm -rf test_dir \
	snapshot_former.txt \
	snapshot_later.txt \
	test.log \
	added_files.txt \
	deleted_files.txt



