#!/bin/bash

usage() {
  echo "Usage ${0} [--browserstack --ip-check] [--parallel-threads PARALLEL_THREADS]"
  echo ' --browserstack                         Runs the session on Browserstack'
  echo ' --ip-check                             IP Address of the machine where the Selenium session runs on BrowserStack'
  echo ' --parallel-threads PARALLEL_THREADS    Number of parallel sessions to run on BrowserStack. Default = 1'
  echo ''
  exit 1
}

BROWSERSTACK="false"
PARALLEL_THREADS=1
IP_CHECK="false"

while [[ "${#}" -gt 0 ]]
do
  case "${1}" in
    --browserstack)
      BROWSERSTACK="true"
      ;;
    --ip-check)
      IP_CHECK="true"
      ;;
    --parallel-threads)
      shift
      if ! [[ "${1}" =~ ^[0-9]+$ ]]; then
        usage
      fi
      if [[ "${1}" -gt 1 ]]; then
        PARALLEL_THREADS="${1}"
      else
        PARALLEL_THREADS=1
      fi
      ;;
    *)
      usage
      ;;
  esac
  shift
done

if [[ "${BROWSERSTACK}" = "true" ]]; then
  if [[ "${IP_CHECK}" = "true" ]]; then
    echo "Running script for RTT of browserstack machine in parallel threads : ${PARALLEL_THREADS} ..."
    while ! [[ "${PARALLEL_THREADS}" -eq 0 ]]; do
      echo -e $(./rtt_script.sh) &
      PARALLEL_THREADS=$((PARALLEL_THREADS-1))
    done
  else
    echo "Running script for page title fetch in browserstack selenium..."
    echo -e $(./title_script.sh --browserstack) &
  fi
else
  echo "Running script for page title fetch in local selenium..."
  echo -e $(./title_script.sh &)
fi
exit 0
