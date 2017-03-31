#!/bin/bash

# directory of source file
DIR=$(dirname "$(readlink -f "$0")")

#change to data/raw directory
cd ${DIR}/../data/raw

#get data file from bls and unzip
wget "https://www.bls.gov/tus/special.requests/atussum_0315.zip"
unzip atussum_0315.zip atussum_0315.dat
mv atussum_0315.dat atussum.csv
rm atussum_0315.zip


