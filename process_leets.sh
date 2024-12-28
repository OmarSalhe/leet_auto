#! /usr/bin/env bash

FILE = "leets.txt"

if [[ ! -f "$FILE"]]; then
	echo "File not found !!!"
	exit 1
fi

while IFS= -r read line
do
	
done
