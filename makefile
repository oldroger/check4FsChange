.PHONY: clean test

MKDIR_PV = mkdir -pv
root_test_dir = test_dir

ALL: snapshot_later.txt 


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

snapshot_former.txt: test_dir_initial
	./check4FsChange.sh -s `realpath test_dir` -o $@
	 
test_dir_further:
	$(MKDIR_PV) $(root_test_dir)/test_1/test_c/test_bla
	$(MKDIR_PV) $(root_test_dir)/test_4/test_a
	$(MKDIR_PV) $(root_test_dir)/test_1/test_d

snapshot_later.txt: snapshot_former.txt test_dir_further
	./check4FsChange.sh -s `realpath test_dir` -o $@

.PHONY: clean test

clean:
	rm -rf test_dir
	rm snapshot_former.txt
	rm snapshot_later.txt
	 



