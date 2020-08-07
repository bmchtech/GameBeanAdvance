SRC_DIR := src
OUT_DIR := out
BIN_DIR := bin

clean:
	rm -f $(OUT_DIR)/*
	rm -f $(BIN_DIR)/*

%: %.S
	arm-none-eabi-objcopy $(OUT_DIR)/$@.out -O binary $(BIN_DIR)/$@.gba

%.S:
	arm-none-eabi-gcc $(SRC_DIR)/$@ -o $(OUT_DIR)/$(basename $(@)).out