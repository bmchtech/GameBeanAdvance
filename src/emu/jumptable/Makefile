.PHONY: clean

JUMPTABLE_OUT_DIR := source
PYTHON := python3

all: $(JUMPTABLE_OUT_DIR)/jumptable_arm.d $(JUMPTABLE_OUT_DIR)/jumptable_thumb.d

$(JUMPTABLE_OUT_DIR)/jumptable_thumb.d: jumptable-thumb-config.d make-jumptable.py
	$(PYTHON) make-jumptable.py $< $@ $@ 16 8 jumptable_thumb JUMPTABLE_THUMB_H ushort instruction_thumb

$(JUMPTABLE_OUT_DIR)/jumptable_arm.d: jumptable-arm.jpp
	$(PYTHON) ../../d-jump/source/compile.py $< $@

clean:
	rm jumptable_thumb.d
	rm jumptable_arm.d