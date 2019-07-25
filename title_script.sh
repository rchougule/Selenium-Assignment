#!/bin/bash

extract_data() {
  local FIELD="${1}"
  local DATA="${@}"
  echo ${DATA} | awk -v field="${FIELD}"  -F'"' '{print $field}'
}

usage() {
  echo "Usage ${0} [--browserstack]"
  echo ' --browserstack         Runs the session on Browserstack'
  echo
  exit 1
}

while [[ "${#}" -gt 0 ]]
do
  case "${1}" in
    --browserstack)
      BROWSERSTACK="true"
      echo "\nSESSION WILL BEGIN ON BROWSERSTACK : ${BROWSERSTACK} \n"
      ;;
    *)
      usage
      ;;
  esac
  shift
done


if [[ "${BROWSERSTACK}" = "true" ]]
then
  SERVER_URL="http://USERNAME:KEY@hub-cloud.browserstack.com"
  DESIRED_CAPABILITIES="@desiredCapabilitiesRemote.json"
else
  SERVER_URL="http://127.0.0.1:4444"
  DESIRED_CAPABILITIES="@desiredCapabilitiesLocal.json"
fi

# Start a new session by specifying the desired capabilities
SESSION_STAT=$(curl -d "${DESIRED_CAPABILITIES}" -X POST -s ${SERVER_URL}/wd/hub/session &)
SESSION_ID=$(extract_data 6 ${SESSION_STAT})
echo "\n[${SESSION_ID}] Session started \n"

# Navigate the session to the URL
URL="https://www.google.com/search?q=rohan+chougule"
NAVIGATION_STAT=$(curl -d '{"url": "https://www.google.com/search?q=rohan+chougule"}' -X POST -s ${SERVER_URL}/wd/hub/session/${SESSION_ID}/url &)
NAVIGATION_STATUS=$(extract_data 4 ${NAVIGATION_STAT})
if ! [[ "${NAVIGATION_STATUS}" = "success" ]]; then
  echo "[${SESSION_ID}] Navigation failure : ${URL}\n"
  echo "[${SESSION_ID}] Terminating the script...\n"
  exit 1
fi
echo "[${SESSION_ID}] Navigation to URL :${URL} : ${NAVIGATION_STATUS} \n"

# Fetch the title of the page
PAGE_STAT=$(curl -X GET -s ${SERVER_URL}/wd/hub/session/${SESSION_ID}/title &)
PAGE_TITLE=$(extract_data 14 ${PAGE_STAT})
echo "[${SESSION_ID}] Page Title : ${PAGE_TITLE} \n"

# Delete the session
SESSION_DELETE_STAT=$(curl -X DELETE -s ${SERVER_URL}/wd/hub/session/${SESSION_ID} &)
SESSION_DELETE_STATUS=$(extract_data 4 ${SESSION_DELETE_STAT})
if ! [[ "${SESSION_DELETE_STATUS}" = "success" ]]; then
  echo "[${SESSION_ID}] Session deletion failure"
  echo "[${SESSION_ID}] Terminating the script...\n"
  exit 1
fi
echo "[${SESSION_ID}] Session Delete : ${SESSION_DELETE_STATUS} \n"
exit 0
