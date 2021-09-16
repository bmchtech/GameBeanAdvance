.PHONY: clean

all: jumptable_arm.d jumptable_thumb.d

jumptable_thumb.d: jumptable-thumb-config.d make-jumptable.py
	python3 make-jumptable.py $< $@ $@ 16 8 jumptable_thumb JUMPTABLE_THUMB_H ushort instruction_thumb

jumptable_arm.d: jumptable-arm.jpp
	python3 ../../d-jump/source/compile.py $< $@

clean:
	rm jumptable_thumb.d
	rm jumptable_arm.d