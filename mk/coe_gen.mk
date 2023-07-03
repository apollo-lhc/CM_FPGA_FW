SCRIPT_DIR = ./scripts
#EVENTS_DIR = ./src/tt_skinny_chain/emData/MemPrintsReduced/InputStubs
#EVENTS_DIR = ./src/tracktrigger/emData/MemPrintsBarrel/InputStubs
#EVENTS_DIR = ./src/tt_barrel_config/emData/MemPrintsBarrel/InputStubs
EVENTS_DIR = ./src/tt_master/emData/MemPrintsBarrel/InputStubs
#OUT_MEM_EVT_DIR = ./src/tt_skinny_chain/IntegrationTests/ReducedConfig/IRtoTB/script/dataOut
#OUT_MEM_EVT_DIR = ./src/tt_barrel_config/IntegrationTests/BarrelConfig/IRtoTB/script/dataOut
OUT_MEM_EVT_DIR = ./src/tt_master/IntegrationTests/BarrelConfig/IRtoTB/script/dataOut
NUM_EVENTS = 18
OM_NUM_EVENTS = 18
INPUTS = $(wildcard $(EVENTS_DIR)/Link_*.dat)
OM_INPUTS = $(wildcard $(OUT_MEM_EVT_DIR)/TF_*.txt)
OUTPUTS = $(patsubst %.dat,%.coe,$(INPUTS))
OM_OUTPUTS = $(patsubst %.txt,%.coe,$(OM_INPUTS))

coe_gen: $(OUTPUTS) $(OM_OUTPUTS)

%.coe:: %.dat
	@echo "Generating .coe memory file '$@'"
	@python $(SCRIPT_DIR)/processMemory.py -i $< -n $(NUM_EVENTS)

%.coe:: %.txt
	@echo "Generating .coe memory file '$@'"
	@python $(SCRIPT_DIR)/procOutMemory.py -i $< -n $(OM_NUM_EVENTS)

clean_coe:
	@echo "Cleaning up .coe generated files"
	@find $(EVENTS_DIR) -type f -name '*.coe' -delete
	@find $(OM_EVENTS_DIR) -type f -name '*.coe' -delete

.PHONY: clean_coe
