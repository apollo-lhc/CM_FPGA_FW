.PHONY: doc doc_kintex doc_tcl clean push push_kintex push_tcl

VHDL_SEARCH_PATHS = "INPUT=./main_fw.md ../src/ ../proj/c2cSlave/synth/ ../proj/c2cSlave/hdl/ "$(wildcard  ../proj/c2cSlave/ip/*/synth/)


all: doc

clean:
	@echo "Cleaning up"
	@rm -rf ./html_kintex > /dev/null 2>&1
	@rm -rf ./html_tcl > /dev/null 2>&1

doc : doc_kintex doc_tcl

doc_kintex : 
	@echo "Generating doxygen for Kintex"
	@(cat ./CM_FW.cfg ; echo ${VHDL_SEARCH_PATHS}) | ./doxygen-patched -

#doc_tcl :
#	@echo "Generating doxygen for TCL"
#	@doxygen ./SM_TCL.cfg

push : push_kintex push_tcl

push_kintex : doc_kintex
	@scp -r html_kintex/* apollo@ohm.bu.edu:~/public_html/Doc/CM_FW/

#push_tcl : doc_tcl
#	@scp -r html_tcl/* apollo@ohm.bu.edu:~/public_html/Doc/SM_TCL/
