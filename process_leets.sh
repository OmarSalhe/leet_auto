#! /usr/bin/env bash

TODAY=$(date +"%Y-%m-%d")

input_file="unprocessed.txt"
output_file="processed.txt"
config_file="config.txt"
tmp_file="tmp.txt"

trap '[[ -f "$tmp_file" ]] && rm -f "$tmp_file"' EXIT # Clean up temporary file, if script terminates prematurely

run_log="run_log.txt"
error_log="error_log.txt"

last_run="last_run.txt"

check_if_file_exists() {
	local file="$1"
	local description="$2"

	if [[ ! -f "$file" ]]; then
		echo "$TODAY - [ERROR] Required file $file is missing. Please ensure the $description exists and is in the correct directory."
		exit 1
	fi
}
# Ensures necessary files exist before executing
check_if_file_exists "$input_file" "Input File"
check_if_file_exists "$run_log" "Log containing successful executions"
check_if_file_exists "$last_run" "Most recent execution is saved onto a txt file and"
check_if_file_exists "$error_log" "Log containing all errors and or warnings"

if [[ ! -f "$config_file" ]]; then
	echo "$TODAY - [ERROR] Required file $config_file is missing. Please create or provide the necessary file." >> "$error_log"
	exit 1
fi

last_executed=""
# Contains the date of the most recent successful execution
if [[ -f "$last_run" && -s "$last_run" ]]; then
    last_executed=$(<"$last_run")
else
    last_executed="none"
fi

# Ensures script only executes once a day
if [[ "$last_executed" != "$TODAY" ]]; then

	# Source external repository from user configurations
	source "$config_file"

	# Ensure path provided leads to a directory
	if [[ ! -d "$EXTERNAL_REPO_PATH" ]]; then
		echo "$TODAY - [ERROR] Configured path does not lead to an external repository." >> "$error_log"
		exit 1
	fi

	solution_file="dummy.txt"
	
	difficulty=""
	name=""
	type=""

	marker="EOS" # End-of-solution
	touch "$tmp_file"

	while IFS= read -r line
	do	
		# Skips lines containing ONLY whitespaces (i.e. \n, \t, \b, etc.)
	        if [[ -z "$line" || "$line" =~ ^[[:space:]]*$ ]] && [[ "$line" != "$marker" ]]; then
				echo "$TODAY - [WARNING] Skipping empty line." >> "$error_log" 
				continue
		fi
		
		# Stops processing input once marker reached
		if [[ "$line" == "$marker" ]]; then
			break
		fi
		
		# Updates solution_file variable with given metadata, if still defaulted
		if [[ "$solution_file" == "dummy.txt" ]]; then
			IFS=',' read -r difficulty name type <<< "$line"

			# Terminates script if missing any fields
			if [[ -z "$difficulty" || -z "$name" || -z "$type" ]]; then
					printf "%s - [ERROR] Malformed input line\n\t%s.\n" "$TODAY" "$line" >> "$error_log"
				exit 1
			fi
			
			# Makes a directory for the created file, if it does not exist
			mkdir -p "$EXTERNAL_REPO_PATH/$difficulty/$name" || {
				echo "$TODAY - [ERROR] Failed to create directory $EXTERNAL_REPO_PATH/$difficulty/$name."
				exit 1
			}
			
			# Creates a file for the solution on the external repository
			solution_file="$EXTERNAL_REPO_PATH/$difficulty/$name/$name.$type" 
			touch "$solution_file" || {
				echo "$TODAY - [ERROR] Failed to create file $EXTERNAL_REPO_PATH/$difficulty/$name/$name.$type."
				exit 1
			}
		
		# Writes solution, if solution file exists
		else
			echo "$line" >> "$solution_file"
		fi
		
		# Archive processed data
		echo "$line" >> "$output_file"

	done < "$input_file"

	# Create a backup for the input file
	if ! cp "$input_file" "${input_file}.bak"; then
		echo "$TODAY - [ERROR] Failed to create a backup file"
		exit 1
	fi

	# Writes remaining unprocessed data onto a temporary file
	awk -v marker="$marker"	'
    		BEGIN { marker_found = 0 }
    		$0 == marker && marker_found == 0 { marker_found = 1; next }
    		marker_found { print }
		' "$input_file" > "$tmp_file"

	# Ensures temporary file contains data before overwriting input file
	if [[ -s "$tmp_file" ]]; then
		mv "$tmp_file" "$input_file"
		rm -f "${input_file}.bak" # Clean up backup file if overwriting is successful
	else
		echo "$TODAY - [ERROR] Overwriting failed, restoring backup." >> "$error_log"
		mv "${input_file}.bak" "$input_file" # Restores input file
		exit 1
	fi

	echo "$TODAY" > "$last_run" # Updates most recent successful execution
	echo "$TODAY - [INFO] Execution completed on $TODAY." >> "$run_log" # Stores successful execution

else
	printf "$TODAY - [ERROR] Script already executed on %s.\nTo force execution, clear the %s file or update its content manually.\n" "$TODAY" "$last_run" >> "$error_log"
fi

exit 0