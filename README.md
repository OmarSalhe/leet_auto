# leet_auto v1.0.0
leet_auto is an automation script designed to streamline the process of managing LeetCode solutions. It processes stored metadata and solutions (in any language), automatically organizing them into a structured file hierarchy within an external repository or directory (with minor tweaks).  

Developed after solving 100+ LeetCode problems, this script simplifies tasks like file creation, organization, and pushing solution to a remote repository. The goal is for users to compile a list of solutions and let the script handle the test, with minimal intervention required to ensure there are solutions to process.  

### **Disclaimer !!**  
This script was not tested thoroughly and this is my first script, so machine-specific bugs, errors, or edge-cases may exist. I do not have readily available access to different systems nor experience (yet) with containers, so I could only test and confirm it works on macOS.

## Challenges
The project itself is conceptually simple (its just file reading/writing), so as an added challenge I imposed little challenges to work on.  
1. **Scheduling**  
With there being a variety of scheduling softwares, I could have just said use cron-job or task-manager depending on the machine. To make this script more "all-encompassing" (or as close as I could manage), my solution was to save the most recent successful execution and check if the script already executed for the day. Albeit flimsy, it did give me the idea to include logging onto the script.

2. **Finding External Directory**  
Could I have "my way or the no way"-ed everyone and have them adopt the superior (my) file-structure? Of course. Did I? Of course *not*. The current solution is distasteful (in my opinion) and I would change it but that would exceed my self-imposed time limit. My current workaround was to have users input the absolute path to their directory or repository directly onto the `config.txt` file, but a much cleaner solution would be to take user input and append onto `config.txt`, but life happens.  

3. **Bugs**  
    - Because the script only overwrites tmp if 


	# Ensures temporary file contains data before overwriting input file
	if [[ -s "$tmp_file" ]]; then
		mv "$tmp_file" "$input_file"
		rm -f "${input_file}.bak" # Clean up backup file if overwriting is successful
	else
		echo "$TODAY - [ERROR] Overwriting failed, restoring backup." >> "$error_log"
		mv "${input_file}.bak" "$input_file" # Restores input file
		exit 1
	fi`
## What's Next
1. Switch to SQLite or some other database (maybe my own) for storing and retrieving solutions  
2. Improve portability (use more POSIX compliant syntax)  
3. Use API + scraping for retrieving user solutions and necessary metadata (up in the air for now, I'm not sure if it complies with LeetCode's ToS) --> would obv be my own API
4. Find a better way for scheduling (ideally non-invasive)

## Materials (ranked by usage)
Debugging: <a href=https://www.shellcheck.net>ShellCheck</a> (life saver), Yours Truly 😘, ChatGPT (some bugs were just shell check specific)  
Learning: <a href="https://www.gnu.org/software/bash/manual/bash.html">Bash Manual</a>, ChatGPT (for bash), <a href="https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#using-emojis">GH Docs: How-To-Markdown</a>