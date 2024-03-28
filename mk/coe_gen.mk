SCRIPT_DIR = ./scripts
#EVENTS_DIR = ./src/tt_skinny_chain/emData/MemPrintsReduced/InputStubs
#EVENTS_DIR = ./src/tracktrigger/emData/MemPrintsBarrel/InputStubs
#EVENTS_DIR = ./src/tt_barrel_config/emData/MemPrintsBarrel/InputStubs
#EVENTS_DIR = ./src/tt_master/emData/MemPrintsBarrel/InputStubs
EVENTS_DIR = ./src/tt_combined/emData/MemPrintsCM/InputStubs
#OUT_MEM_EVT_DIR = ./src/tt_skinny_chain/IntegrationTests/ReducedConfig/IRtoTB/script/dataOut
#OUT_MEM_EVT_DIR = ./src/tt_barrel_config/IntegrationTests/BarrelConfig/IRtoTB/script/dataOut
#OUT_MEM_EVT_DIR = ./src/tt_master/IntegrationTests/BarrelConfig/IRtoTB/script/dataOut
OUT_MEM_EVT_DIR = .src/tt_combined/IntegrationTests/ReducedCombinedConfig/script/dataOut
NUM_SKIP =18
NUM_EVENTS = 18
OM_NUM_SKIP = 18
OM_NUM_EVENTS = 18
INPUTS = $(wildcard $(EVENTS_DIR)/Link_*.dat)
OM_INPUTS = $(wildcard $(OUT_MEM_EVT_DIR)/TF_*.txt)
OUTPUTS = $(patsubst %.dat,%.coe,$(INPUTS))
OM_OUTPUTS = $(patsubst %.txt,%.coe,$(OM_INPUTS))

coe_gen: $(OUTPUTS) $(OM_OUTPUTS)

%.coe:: %.dat
	@echo "Generating .coe input memory file '$@'"
	@python $(SCRIPT_DIR)/processMemory.py -i $< -s $(NUM_SKIP) -n $(NUM_EVENTS)

%.coe:: %.txt
	@echo "Generating .coe output memory file '$@'"
	@python $(SCRIPT_DIR)/procOutMemory.py -i $< -s $(OM_NUM_SKIP) -n $(OM_NUM_EVENTS)

clean_coe:
	@echo "Cleaning up .coe generated files"
	@find $(EVENTS_DIR) -type f -name '*.coe' -delete
	@find $(OM_EVENTS_DIR) -type f -name '*.coe' -delete

.PHONY: clean_coe
