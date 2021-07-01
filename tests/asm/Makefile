.PHONY: clean

SRC_DIR        := src
OUT_DIR        := out
BIN_DIR        := bin
LOG_DIR        := logs

COMPILER       := arm-none-eabi-gcc
COMPILER_FLAGS := -mthumb-interwork -specs=gba.specs -B /opt/devkitpro/devkitARM/arm-none-eabi/lib/ -lsysbase
LINKER         := arm-none-eabi-objcopy
LINKER_FLAGS   := 

all: $(LOG_DIR)/thumb-simple.log \
     $(LOG_DIR)/arm-addressing-mode-1.log \
     $(LOG_DIR)/arm-addressing-mode-2.log \
	 $(LOG_DIR)/arm-addressing-mode-3.log \
	 $(LOG_DIR)/arm-opcodes.log

clean:
	rm -f $(OUT_DIR)/*
	rm -f $(BIN_DIR)/*






$(LOG_DIR)/thumb-simple.log: $(SRC_DIR)/thumb-simple.S
# compile and link the files
	$(COMPILER) $(COMPILER_FLAGS) $(SRC_DIR)/thumb-simple.S   -o        $(OUT_DIR)/thumb-simple.out
	$(LINKER)   $(LINKER_FLAGS)   $(OUT_DIR)/thumb-simple.out -O binary $(BIN_DIR)/thumb-simple.gba
	
# fix the gba to give it a valid checksum
	gbafix $(BIN_DIR)/thumb-simple.gba

# generate the instruction logs
	NanoBoyAdvance --num_instructions 200300 $(BIN_DIR)/thumb-simple.gba
	@sed -n -i.bak -e '196634,200300p' out.log
	@rm out.log.bak
	mv out.log $(LOG_DIR)/thumb-simple.log






$(LOG_DIR)/arm-addressing-mode-1.log: $(SRC_DIR)/arm-addressing-mode-1.S
# compile and link the files
	$(COMPILER) $(COMPILER_FLAGS) $(SRC_DIR)/arm-addressing-mode-1.S   -o        $(OUT_DIR)/arm-addressing-mode-1.out
	$(LINKER)   $(LINKER_FLAGS)   $(OUT_DIR)/arm-addressing-mode-1.out -O binary $(BIN_DIR)/arm-addressing-mode-1.gba
	
# fix the gba to give it a valid checksum
	gbafix $(BIN_DIR)/arm-addressing-mode-1.gba

# generate the instruction logs
	NanoBoyAdvance --num_instructions 197924 $(BIN_DIR)/arm-addressing-mode-1.gba 
	@sed -n -i.bak -e '196634,197924p' out.log
	@rm out.log.bak
	mv out.log $(LOG_DIR)/arm-addressing-mode-1.log






$(LOG_DIR)/arm-addressing-mode-2.log: $(SRC_DIR)/arm-addressing-mode-2.S
# compile and link the files
	$(COMPILER) $(COMPILER_FLAGS) $(SRC_DIR)/arm-addressing-mode-2.S   -o        $(OUT_DIR)/arm-addressing-mode-2.out
	$(LINKER)   $(LINKER_FLAGS)   $(OUT_DIR)/arm-addressing-mode-2.out -O binary $(BIN_DIR)/arm-addressing-mode-2.gba
	
# fix the gba to give it a valid checksum
	gbafix $(BIN_DIR)/arm-addressing-mode-2.gba

# generate the instruction logs
	NanoBoyAdvance --num_instructions 197924 $(BIN_DIR)/arm-addressing-mode-2.gba 
	@sed -n -i.bak -e '196634,197924p' out.log
	@rm out.log.bak
	mv out.log $(LOG_DIR)/arm-addressing-mode-2.log






$(LOG_DIR)/arm-addressing-mode-3.log: $(SRC_DIR)/arm-addressing-mode-3.S
# compile and link the files
	$(COMPILER) $(COMPILER_FLAGS) $(SRC_DIR)/arm-addressing-mode-3.S   -o        $(OUT_DIR)/arm-addressing-mode-3.out
	$(LINKER)   $(LINKER_FLAGS)   $(OUT_DIR)/arm-addressing-mode-3.out -O binary $(BIN_DIR)/arm-addressing-mode-3.gba
	
# fix the gba to give it a valid checksum
	gbafix $(BIN_DIR)/arm-addressing-mode-3.gba

# generate the instruction logs
	NanoBoyAdvance --num_instructions 197924 $(BIN_DIR)/arm-addressing-mode-3.gba
	@sed -n -i.bak -e '196634,197924p' out.log
	@rm out.log.bak
	mv out.log $(LOG_DIR)/arm-addressing-mode-3.log






$(LOG_DIR)/arm-opcodes.log: $(SRC_DIR)/arm-opcodes.S
# compile and link the files
	$(COMPILER) $(COMPILER_FLAGS) $(SRC_DIR)/arm-opcodes.S   -o        $(OUT_DIR)/arm-opcodes.out
	$(LINKER)   $(LINKER_FLAGS)   $(OUT_DIR)/arm-opcodes.out -O binary $(BIN_DIR)/arm-opcodes.gba
	
# fix the gba to give it a valid checksum
	gbafix $(BIN_DIR)/arm-opcodes.gba

# generate the instruction logs
	NanoBoyAdvance --num_instructions 198634 $(BIN_DIR)/arm-opcodes.gba 
	@sed -n -i.bak -e '196634,198634p' out.log
	@rm out.log.bak
	mv out.log $(LOG_DIR)/arm-opcodes.log


red-screen: $(SRC_DIR)/red-screen.S
	$(COMPILER) $(COMPILER_FLAGS) $(SRC_DIR)/red-screen.S   -o        $(OUT_DIR)/red-screen.out
	$(LINKER)   $(LINKER_FLAGS)   $(OUT_DIR)/red-screen.out -O binary $(BIN_DIR)/red-screen.gba

texan-frog: $(SRC_DIR)/texan-frog.S
	$(COMPILER) $(COMPILER_FLAGS) $(SRC_DIR)/texan-frog.S   -o        $(OUT_DIR)/texan-frog.out
	$(LINKER)   $(LINKER_FLAGS)   $(OUT_DIR)/texan-frog.out -O binary $(BIN_DIR)/texan-frog.gba

mode4: $(SRC_DIR)/mode4.S
	$(COMPILER) $(COMPILER_FLAGS) $(SRC_DIR)/mode4.S   -o        $(OUT_DIR)/mode4.out
	$(LINKER)   $(LINKER_FLAGS)   $(OUT_DIR)/mode4.out -O binary $(BIN_DIR)/mode4.gba