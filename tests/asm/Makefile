# usage: make <test name> INSTRUCTIONS=<num of instructions>

.PHONY: clean

SRC_DIR        := src
OUT_DIR        := out
BIN_DIR        := bin
LOG_DIR        := logs

COMPILER       := arm-none-eabi-gcc
COMPILER_FLAGS := -mthumb-interwork -specs=gba.specs
LINKER         := arm-none-eabi-objcopy
LINKER_FLAGS   := 

all: $(LOG_DIR)/thumb-alu.log $(LOG_DIR)/arm-alu.log

clean:
	rm -f $(OUT_DIR)/*
	rm -f $(BIN_DIR)/*

$(LOG_DIR)/thumb-alu.log: $(SRC_DIR)/thumb-alu.S
# compile and link the files
	$(COMPILER) $(COMPILER_FLAGS) $(SRC_DIR)/thumb-alu.S   -o        $(OUT_DIR)/thumb-alu.out
	$(LINKER)   $(LINKER_FLAGS)   $(OUT_DIR)/thumb-alu.out -O binary $(BIN_DIR)/thumb-alu.gba
	
# fix the gba to give it a valid checksum
	gbafix $(BIN_DIR)/thumb-alu.gba

# generate the instruction logs
	-visualboyadvance-m $(BIN_DIR)/thumb-alu.gba 200300 > file 2>/dev/null |:
	@rm file
	@sed -n -i.bak -e '196634,200300p' out.log
	@rm out.log.bak
	mv out.log $(LOG_DIR)/thumb-alu.log

$(LOG_DIR)/arm-alu.log:  $(SRC_DIR)/arm-alu.S
# compile and link the files
	$(COMPILER) $(COMPILER_FLAGS) $(SRC_DIR)/arm-alu.S   -o        $(OUT_DIR)/arm-alu.out
	$(LINKER)   $(LINKER_FLAGS)   $(OUT_DIR)/arm-alu.out -O binary $(BIN_DIR)/arm-alu.gba
	
# fix the gba to give it a valid checksum
	gbafix $(BIN_DIR)/arm-alu.gba

# generate the instruction logs
	-visualboyadvance-m $(BIN_DIR)/arm-alu.gba 196924 > file 2>/dev/null |:
	@rm file
	@sed -n -i.bak -e '196634,196924p' out.log
	@rm out.log.bak
	mv out.log $(LOG_DIR)/arm-alu.log

