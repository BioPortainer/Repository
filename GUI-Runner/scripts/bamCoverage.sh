#!/bin/bash

#I had to insert a command to copy the index files (*.bai) to
#any temp/uploadFiles/ folders where the "file_upload" parameter type takes the input bam file.
#because the file upload can't copy the index files
#and alignmentSieve can't work if the index is not in the same directory as the bam.
#Otherwise, we'd have to use "text" as parameter type, but
#the would have to type the bam file's name;
#that would be boring to the user
#WE DO THINK ABOUT YOU, DEAR USER!

cp ./*.bai temp/uploadFiles/*/* 2>/dev/null & bamCoverage $@

