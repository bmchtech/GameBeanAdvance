# usage: make <test name> INSTRUCTIONS=<num of instructions>

SRC_DIR := src
OUT_DIR := out
BIN_DIR := bin
LOG_DIR := logs

all:

clean:
	rm -f $(OUT_DIR)/*
	rm -f $(BIN_DIR)/*

%: %.gba
	-visualboyadvance-m $(BIN_DIR)/$@.gba $(INSTRUCTIONS) &>/dev/null
	mv out.log $(LOG_DIR)/$@_$(INSTRUCTIONS).log

%.gba: %.out
	arm-none-eabi-objcopy $(OUT_DIR)/$(basename $(@)).out -O binary $(BIN_DIR)/$@

%.out:
	arm-none-eabi-gcc -mthumb-interwork -specs=gba.specs $(SRC_DIR)/$(basename $(@)).S -o $(OUT_DIR)/$@