## HOW TO RUN

1. Run run_assignment.sh to execute page title fetch script on local selenium session
2. Flags:
	1. --browserstack : page title fetch script will execute on remote selenium session on browserstack
	2. --ip-check	: Round Trip Time script will fetch the RTT ms to browserstack machine
	3. --parallel-threads PARALLEL_THREADS : specifies the parallel threads to run on browserstack
3. For --ip-check and --parallel-threads flags, --browserstack flag is mandatory

## NOTE
Replace USERNAME & KEY in 'title_script.sh' and 'rtt_script.sh' with the actual credentials for the script to execute on BrowserStack
