#!/bin/sh
zcat training-data.txt.gz | ../../feedme.py 
../../buildz80com.py -o CHAT.COM
../../buildzxspectrum.py -o block.bin
../../cpm CHAT.COM