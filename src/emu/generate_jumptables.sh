#!/usr/bin/env bash

set -o xtrace

pushd .
cd ../d-jump/source/
pypy3 ./compile.py ../../emu/jumptable/jumptable-arm.jpp ../../emu/jumptable/jumptable_arm.d
popd

pushd .
cd ./jumptable
pypy3 make-jumptable.py jumptable-thumb-config.cpp jumptable_thumb.d jumptable_thumb.d 16 8 jumptable_thumb JUMPTABLE_THUMB_H uint16_t instruction_thumb
popd
