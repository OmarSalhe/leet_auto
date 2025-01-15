# leet_auto v1.0.0
leet_auto is an automation script designed to streamline the process of managing LeetCode solutions. It processes stored metadata and solutions (in any language), automatically organizing them into a structured file hierarchy within an external repository or (with minor tweaks) directory. Developed after solving 100+ LeetCode problems, this script simplifies tasks like file creation, organization, and pushing solution to a remote repository. The goal is for users to compile a list of solutions and let the script handle the rest, with minimal intervention required on the user's end (asides from supplying the solutions).

Fun Fact: The main reasoning behind daily pushes was to give me enough time to accumulate enough solutions so I can then begin writing out explanations for said solutions, without running out of solutions.

### **Disclaimer !!**  
This script was not tested thoroughly and this is my first script, so machine-specific bugs, errors, or edge-cases may exist. I do not have readily available access to different systems nor experience (yet) with containers, so I could only test and confirm it works on macOS.

## How to Use

## Challenges
The project itself is conceptually simple (its just file reading/writing), so as an added challenge I imposed certain *goals* to work on, being machine-ambiguity, efficiency, scalability. These are some of the challenges faced when working towards those goals:
1. **Scheduling**  
With there being a variety of scheduling softwares, I could have just said use cron-job or task-manager, depending on the machine, to schedule and execute the script. Instead, I wanted to try and handle this myself and make the script as close to "all-encompassing" as I could manage. My workaround/solution was to save all execution dates and use the most recent to determine whether or not the script should execute and have this script be a startup task. (simple i know)

2. **Finding The External Directory**  
Could I have "my way or the no way"-ed everyone and have them adopt the superior (my) file-structure? Of course. Did I? Of course *not*. The current solution is distasteful (in my opinion) and I would change it but that would exceed my self-imposed time limit. My current workaround was to have users input the absolute path to their directory and or repository directly onto the `config.txt` file, but a much cleaner solution would be to take user input and append onto `config.txt` or something that wouldn't give users such... *direct* access to the inner-workings, but life happens.  


## Features? (bugs)
- Because the script only proceeds if `unprocessed.txt` is successfully overwritten by a temporary file and a prerequisite for overwriting is the temporary file containing remaining solutions, if only one solution is in `unprocessed.txt` before executing then the script will not properly execute.
> The fix to this is to always have a designated `EOS` marker at the bottom of the file.
- Backup files are not properly cleaned up upon successful exection.
> Ran out of time, and backup files was a recent addiction so I did not get to it. Doesn't interfere with later excutions though, so its annoying if anything.

## What's Next
This is just a list of things to add to keep this project "alive"
1. Switch to SQLite or some other database (maybe my own) for storing and retrieving solutions
2. Improve portability (use more POSIX compliant syntax)  
3. Use API + scraping for retrieving user solutions and necessary metadata (up in the air for now, I'm not sure if it complies with LeetCode's ToS) --> would obv be my own API
4. Find a better way for scheduling (ideally non-invasive)


## Materials (ranked by usage)
Debugging: <a href=https://www.shellcheck.net>ShellCheck</a> (life saver), Yours Truly 😘, ChatGPT (some bugs were just shell check specific)  
Learning: <a href="https://www.gnu.org/software/bash/manual/bash.html">Bash Manual</a>, ChatGPT (for bash), <a href="https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#using-emojis">GH Docs: How-To-Markdown</a>