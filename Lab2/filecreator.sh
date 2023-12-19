#!/bin/bash

yourName="maria"
filePrefix="${yourName}"

if [ -e "$filePrefix"* ]; then
    lastFileNumber=$(ls -1 "$filePrefix"* | grep -oE '[0-9]+' | sort -n | tail -n 1)
    if [ -z "$lastFileNumber" ]; then
        lastFileNumber=0
    fi
else
    lastFileNumber=0
fi

numFiles=25

for ((i = 1; i <= numFiles; i++)); do
    currentFileNumber=$((lastFileNumber + i))
    currentFileName="${filePrefix}${currentFileNumber}"
    touch "$currentFileName"
done
