#! /usr/bin/env bash

input_file="unprocessed.txt"
output_file="processed.txt"

solution_file="dummy.txt"

if [[ ! -f "$input_file" ]]; then
	echo "Cannot access solutions to process."
	exit 1
fi

difficulty=""
name=""
type=""
 
while IFS= -r read line
do	
	if [[ -z "$line" || "$line" =~ ^[[:space:]]*$ ]]; then
        	echo "Warning: Skipping empty line."
        	continue
    	fi
 
	if [[ "$line" == "EOS" ]]; then
		difficulty=""
		name=""
		type=""
		break
	fi

	if [[ "$solution_file" == "dummy.txt" ]]; then
		IFS=',' read difficulty name type <<< "$line"
		if [[ -z "$difficulty" || -z "$name" || -z "$type" ]]; then
    			echo "Error: Malformed input line - $line"
   	 		continue
		fi
 
		mkdir -p "$difficulty/$name"
		solution_file="$difficulty/$name/$name.$type"
		touch "$solution_file"

		if [[ ! -f "$solution_file" ]]; then
			echo "Failed to create solution file"
			exit 1
		fi
	else
		echo $line >> "$solution_file"
	fi

	echo $line >> output_file	
done < input_file 
