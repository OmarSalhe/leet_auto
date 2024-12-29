#! /usr/bin/env bash

input_file = "unprocessed.txt
output_file = "processed.txt"

if [[ ! -f "$input_file"]]; then
	echo "No Leetcodes to process or incorrect file provided:
	exit 1
fi


i = 0
while IFS= -r read line
do
	if [$line = 1]; then
		name = $line
	if [ $line = 2 ]; then
		awk 
	if [ $line =  3 ]; then
	
	echo $line >> output_file
	((i++))	
done < input_file
