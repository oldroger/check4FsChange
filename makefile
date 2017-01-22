TEST_DIR = tests

.PHONY: test clean

test:
	$(MAKE) -C $(TEST_DIR)

clean:
	$(MAKE) -C $(TEST_DIR) clean




