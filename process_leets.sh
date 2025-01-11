# #! /usr/bin/env bash

trap 'rm -f "$tmp_file" "${input_file}.bak" "${output_file}.bak" "${run_log}.bak" "${error_log}.bak" "${last_run}.bak"' EXIT

TODAY=$(date +"%Y-%m-%d")
SCRIPT_DIR_PATH=$(dirname "$0") # Path to the script's directory

# Functions
log_occurence() {
	local level="$1"
	local message="$2"
	local log="$3"

	echo "$TODAY - [$level] $message" >> "$log"
}

check_if_required_exists() {
	local missing=0
    local files=("$@")
    for file in "${files[@]}"; do
        case "$file" in
            "$input_file")
                description="Input file"
                ;;
            "$output_file")
                description="Output file"
                ;;
            "$config_file")
                description="Configuration file"
                ;;
            "$run_log")
                description="Log of successful runs"
                ;;
            "$last_run")
                description="File tracking the last execution"
                ;;
            "$error_log")
				description="Log of error and debugging messages"
				;;
			*)
                description="Unknown file"
                ;;
        esac
        
        if [[ ! -f "$file" ]]; then
			((missing++))
            log_occurence "ERROR" "Required file $file ($description) is missing." "$error_log"
        fi
    done

	if [[ $missing -gt 0 ]]; then
		log_occurence "ERROR" "Files missing: $missing. To execute script, ensure all files exist and are acessible" "$error_log"
		exit 1
	fi
}

restore_files() {
	local files=("$@")
	for file in "${files[@]}"; do
		if [[ -f "${file}.bak" ]]; then
			mv "${file}.bak" "$file"
		fi
	done
}

create_backups() {
	local files=("$@")
    for file in "${files[@]}"; do
		if ! cp "$file" "${file}.bak"; then
			restore_files "$input_file" "$output_file" "$run_log" "$error_log" "$last_run"
			log_occurence "ERROR" "Failed to create backup file for $file" "$error_log"
			exit 1
		fi
	done
}

# Files
input_file="unprocessed.txt"
output_file="processed.txt"
config_file="config.txt"
tmp_file="tmp.txt"

# Logs
run_log="run_log.txt"
error_log="error_log.txt"

# Time of last execution
last_run="last_run.txt"

# Ensures necessary files exist before executing
check_if_required_exists "$input_file" "$output_file" "$run_log" "$last_run" "$error_log" "$config_file"

# Quit if no input available
if [[ ! -s "$input_file" ]]; then
	log_occurence "ERROR" "No input to process. Please provide input before executing script" "$error_log"
	exit 1
fi

# Contains the date of the most recent successful execution
last_executed=""
if [[ -f "$last_run" && -s "$last_run" ]]; then
    last_executed=$(cat "$last_run")
else
    last_executed="none"
fi

# Ensures script only executes once a day
if [[ "$last_executed" != "$TODAY" ]]; then

	create_backups "$input_file" "$output_file" "$run_log" "$error_log" "$last_run"

	# Source external repository from user configurations
	source "$config_file"

	if [[ -z "$EXTERNAL_REPO_PATH" ]]; then
		log_occurence "ERROR" "Configurations not set. Please set configurations before executing script." "$error_log"
		exit 1
	# Ensure path provided leads to a directory
	elif [[ ! -d "$EXTERNAL_REPO_PATH" ]]; then
		log_occurence "ERROR" "Configured path does not lead to an external repository." "$error_log"
		exit 1
	fi

	solution_file="place_holder.txt"
	
	difficulty=""
	name=""
	type=""

	marker="EOS" # End-of-solution
	touch "$tmp_file"

	while IFS= read -r line
	do		
		# Stops processing input once marker reached
		if [[ "$line" == "$marker" ]]; then
			break
		fi
		
		# Updates solution_file variable with given metadata, if still defaulted
		if [[ "$solution_file" == "place_holder.txt" ]]; then
			IFS=',' read -r difficulty name type <<< "$line" || {
				log_occurence "ERROR" "Malformed input line - $line" "$error_log"
				log_occurence "DEBUG" "Likely cause(s): Missing necessary field(s) (difficulty, problem name, file type (language used))"
				restore_files "$input_file" "$output_file" "$run_log" "$error_log" "$last_run"
				exit 1
			}
			
			# Creates directory for the created file, if it does not exist
			solution_dir="$EXTERNAL_REPO_PATH/$difficulty/$name"
			mkdir -p "$solution_dir" || {
				log_occurence "ERROR" "System failed to create directory $solution_dir." "$error_log"
				restore_files "$input_file" "$output_file" "$run_log" "$error_log" "$last_run"
				exit 1
			}
			
			# Creates a file for the solution on the external repository
			solution_file="$solution_dir/$name.$type" 
			touch "$solution_file" || {
				log_occurence "ERROR" "System failed to create $solution_file." "$error_log"
				restore_files "$input_file" "$output_file" "$run_log" "$error_log" "$last_run"
				exit 1
			}
		
		# Writes solution, if solution file was created
		else
			echo "$line" >> "$solution_file"
		fi
		
		# Archive processed data
		echo "$line" >> "$output_file"

	done < "$input_file"

	# Writes remaining unprocessed data onto a temporary file
	awk -v marker="$marker"	'
    		BEGIN { marker_found = 0 }
    		$0 == marker && marker_found == 0 { marker_found = 1; next }
    		marker_found { print }
		' "$input_file" > "$tmp_file"

	# Ensures temporary file contains data before overwriting input file
	if [[ -s "$tmp_file" ]]; then
		mv "$tmp_file" "$input_file"
	else
		log_occurence "ERROR" "Overwriting failed, restoring backup." "$error_log"
		log_occurence "DEBUG" "Likely cause(s): solution(s) are not separated by markers or too few solutions in $input_file. (To fix, place an extra marker on the bottom)" "$error_log"
		restore_files "$input_file" "$output_file" "$run_log" "$error_log" "$last_run"
		exit 1
	fi

	echo "$TODAY" > "$last_run" # Updates most recent successful execution

	#Commit and push changes onto the script's remote repo
	# cd "$SCRIPT_DIR_PATH" || exit 1 # Ensure we're in the script's directory
	# git add "$run_log" "$input_file" "$output_file" "$error_log" "$last_run" && git commit -m "Successfully added $name on $TODAY" && git push || {
	# 	log_occurence "ERROR" "Failed to push changes onto the script's repository" "$error_log"
	# 	restore_files "$input_file" "$output_file" "$run_log" "$error_log" "$last_run"
	# 	exit 1
	# }

	# Commit and push changes onto the external repo's remote repo
	# cd "$EXTERNAL_REPO_PATH" || exit 1
	# git add "$solution_file" && git commit -m "Added $name without explanation" && git push || {
	# 	log_occurence "ERROR" "Failed to push changes to the external repository" "$error_log"
	# 	restore_files "$input_file" "$output_file" "$run_log" "$error_log" "$last_run"
	# 	exit 1
	# }

	log_occurence "INFO" "Execution sucessfully completed" "$run_log" # Store successfule executions

else
	log_occurence "ERROR" "Script has already executed. To force execution, clear $last_run or update its content" "$error_log"
fi

exit 0