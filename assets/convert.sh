#!/usr/bin/env bash

for f in *.wav
do
  lame $f
  oggenc $f
  faac $f -o ${f/wav/m4a}
done
