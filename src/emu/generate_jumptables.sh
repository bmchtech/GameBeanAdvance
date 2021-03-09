#!/usr/bin/env bash

set -o xtrace

pushd .
cd ./jumptable
make all
popd
