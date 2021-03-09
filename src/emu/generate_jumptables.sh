#!/usr/bin/env bash

set -o xtrace

pushd .
cd ../d-jump/source/
./compile ../../emu/jumptable/jumptable-arm.jpp ../../emu/jumptable/jumptable_arm.d
popd

pushd .
cd ./jumptable
python make-jumptable.py python3 make-jumptable.py jumptable-thumb-config.cpp jumptable-thumb.d jumptable-thumb.h 16 8 jumptable_thumb JUMPTABLE_THUMB_H uint16_t instruction_thumb
popd
