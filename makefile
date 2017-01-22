TEST_DIR = tests

.PHONY: test test_clean

test:
	$(MAKE) -C $(TEST_DIR)

test_clean:
	$(MAKE) -C $(TEST_DIR) clean




