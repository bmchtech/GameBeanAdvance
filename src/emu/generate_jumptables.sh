#!/usr/bin/env bash

# set -o xtrace

pushd .
cd ./jumptable
echo "Generating jumptable..."
make -e all
popd
