SRC_FILE := ticktick.sh
BASH_PATH := $(shell which bash)
INSTALL_PATH := $(shell dirname $(BASH_PATH))

default: help

help:
	@echo
	@echo 'make test - Run the TickTick test suite'
	@echo 'make install - Install ticktick.sh (next to bash)'
	@echo

test:
	(cd tests; ./runall.sh)

install:
	cp $(SRC_FILE) $(INSTALL_PATH)
	chmod +x $(INSTALL_PATH)/$(SRC_FILE)
