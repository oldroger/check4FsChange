.PHONY: clean test

MKDIR_PV = mkdir -pv
root_test_dir = test_dir

ALL: snapshot_later.txt 

good_tests: check_snapshot_former check_snapshot_later good_test1 
bad_test:  

TEST_LOG:=test.log

test_dir_initial:	
	$(MKDIR_PV) $(root_test_dir)/test_1/test_c
	$(MKDIR_PV) $(root_test_dir)/test_2/test_c
	$(MKDIR_PV) $(root_test_dir)/test_3/test_c
	$(MKDIR_PV) $(root_test_dir)/test_1/test_b
	$(MKDIR_PV) $(root_test_dir)/test_2/test_b
	$(MKDIR_PV) $(root_test_dir)/test_3/test_b
	$(MKDIR_PV) $(root_test_dir)/test_1/test_a
	$(MKDIR_PV) $(root_test_dir)/test_2/test_a
	$(MKDIR_PV) $(root_test_dir)/test_3/test_a

test_dir_abs_path:=$(shell realpath test_dir)

snapshot_former.txt: test_dir_initial
	./check4FsChange.sh -s -d $(test_dir_abs_path) -o $@

test_dir_further:
	$(MKDIR_PV) $(root_test_dir)/test_1/test_c/test_bla
	$(MKDIR_PV) $(root_test_dir)/test_4/test_a
	$(MKDIR_PV) $(root_test_dir)/test_1/test_d

snapshot_later.txt: test_dir_further
	./check4FsChange.sh -s -d $(test_dir_abs_path) -o $@


check_snapshot_former: snapshot_former.txt
	test -e snapshot_former.txt
	test -s snapshot_former.txt 

check_snapshot_later: snapshot_later.txt
	test -e snapshot_later.txt
	test -s snapshot_later.txt


	
bad1: 
	! ./check4FsChange.sh -s $(test_dir_abs_path) -o $@ > $(TEST_LOG) 2>&1
	egrep "\[ERROR\] You need to name a directory with '-d' for action \"createDirectorySnapshot\"!" $(TEST_LOG)


.PHONY: clean test

clean:
	rm -rf test_dir
	rm snapshot_former.txt
	rm snapshot_later.txt
	 



