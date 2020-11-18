#################################################################################
# make stuff
#################################################################################
SHELL=/bin/bash -o pipefail

#add path so build can be more generic
MAKE_PATH := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

OUTPUT_MARKUP= 2>&1 | tee -a ../make_log.txt | ccze -A
SLACK_MESG ?= echo

all:
	@echo "Please specify a design to build"
	@$(MAKE) list 

#################################################################################
# Slack notifications
#################################################################################
NOTIFY_DAN_GOOD:
	${SLACK_MESG} "FINISHED building FW!"
NOTIFY_DAN_BAD:
	${SLACK_MESG} "FAILED to build FW!"

#################################################################################
# Help 
#################################################################################

#list magic: https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile
list:
	@echo
	@echo Apollo CM config:
	@$(MAKE) -pRrq -f $(MAKEFILE_LIST) | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | grep rev[[:digit:]] | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | column
	@echo
	@echo Vivado:
	@$(MAKE) -pRrq -f $(MAKEFILE_LIST) | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | grep open_ | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | column
	@echo
	@echo Clean:
	@$(MAKE) -pRrq -f $(MAKEFILE_LIST) | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | grep clean_ | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | column
	@echo

full_list:
	@$(MAKE) -pRrq -f $(MAKEFILE_LIST) | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | column
