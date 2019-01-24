#!/bin/bash

cat *.fastq|fastx_barcode_splitter.pl $@

