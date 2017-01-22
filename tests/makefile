SUBDIRS := $(wildcard */.)

all: test

test: $(SUBDIRS)
	$(MAKE) -C $<

.PHONY: all clean $(SUBDIRS)

clean: $(SUBDIRS) 
	$(MAKE) -C $< clean
