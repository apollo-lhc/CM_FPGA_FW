#################################################################################
# Clean
#################################################################################
clean_prebuild:
	@echo "Cleaning up prebuild autogenerated files"
	@rm $(ADDSLAVE_TCL_PATH)/AddSlaves.tcl
	@rm $(ADDRESS_TABLE_CREATION_PATH)/slaves.yaml
	@rm $(SLAVE_DTSI_PATH)/slaves.yaml

#################################################################################
# prebuild 
#################################################################################
prebuild: $(SLAVE_DEF_FILE)
	./scripts/preBuild.py   -s $(SLAVE_DEF_FILE) \
				-t $(ADDSLAVE_TCL_PATH) \
				-a $(ADDRESS_TABLE_CREATION_PATH) \
				-d $(SLAVE_DTSI_PATH)

$(ADDSLAVE_TCL_PATH)/AddSlaves.tcl $(ADDRESS_TABLE_CREATION_PATH)/slaves.yaml $(SLAVE_DTSI_PATH)/slaves.yaml: prebuild
