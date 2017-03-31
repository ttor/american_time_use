#!/bin/bash

# directory of source file
DIR=$(dirname "$(readlink -f "$0")")

#change to figures directory
cd ${DIR}/../figures

#convert to png in 300 dpi and 100 dpi
for i in *pdf; do convert -density 300 $i $(basename $i .pdf).png; done
for i in *pdf; do convert -density 100 $i $(basename $i .pdf)_sm.png; done
