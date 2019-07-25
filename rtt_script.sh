#!/bin/bash

# function to extract specific field from data
extract_data() {
  local FIELD="${1}"
  local DATA="${@}"
  echo ${DATA} | awk -v field="${FIELD}"  -F'"' '{print $field}'
}

SERVER_URL="http://USERNAME:KEY@hub-cloud.browserstack.com"
DESIRED_CAPABILITIES="@desiredCapabilitiesRemote.json"

# Start a new session by specifying the desired capabilities
SESSION_ID=$(curl -d "${DESIRED_CAPABILITIES}" -X POST -s ${SERVER_URL}/wd/hub/session | awk -F'"' '{print $6}')
echo "\n[${SESSION_ID}] Session started \n"

# Navigate the session to the URL
URL="https://www.myip.com/"
NAVIGATION_STATUS=$(curl -d '{"url": "https://www.myip.com/"}' -X POST -s ${SERVER_URL}/wd/hub/session/${SESSION_ID}/url | awk -F'"' '{print $4}')
echo "[${SESSION_ID}] Navigation to URL :${URL} : ${NAVIGATION_STATUS} \n"

# Fetch the id element
FETCH_STAT=$(curl -d '{"using": "id", "value": "ip"}' -X POST -s ${SERVER_URL}/wd/hub/session/${SESSION_ID}/element)
FETCH_STATUS=$(extract_data 4 ${FETCH_STAT})
if ! [[ "${FETCH_STATUS}" = "success" ]]; then
  echo "[${SESSION_ID}] Fetching id failure \n"
  echo "[${SESSION_ID}] Terminating the script...\n"
  exit 1
fi
FETCH_VALUE=$(extract_data 16 ${FETCH_STAT})
echo "[${SESSION_ID}] Fetch IPv4 by id : ${FETCH_STATUS} : Element : ${FETCH_VALUE} \n"

# Fetch the text value of the id
IP_VALUE=$(curl -s ${SERVER_URL}/wd/hub/session/${SESSION_ID}/element/${FETCH_VALUE}/text | awk -F':' '{print $5}' | cut -d '"' -f 2)
echo "[${SESSION_ID}] IP Address of Machine : ${IP_VALUE} \n"
IP_PATTERN='^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
if ! [[ "${IP_VALUE}" =~ ${IP_PATTERN} ]]; then
  echo "[${SESSION_ID}] IP Format invalid\n"
  echo "[${SESSION_ID}] Terminating the script...\n"
  exit 1
fi 

# Extract the RTT min ms 
RTT=$(ping -c 4 ${IP_VALUE} | grep round-trip | awk -F' ' '{print $4}' | cut -d '/' -f 1)
echo "[${SESSION_ID}] Round Trip Time : ${RTT} ms \n"

# Delete the session
SESSION_DELETE_STAT=$(curl -X DELETE -s ${SERVER_URL}/wd/hub/session/${SESSION_ID} &)
SESSION_DELETE_STATUS=$(extract_data 4 ${SESSION_DELETE_STAT})
if ! [[ "${SESSION_DELETE_STATUS}" = "success" ]]; then
  echo "[${SESSION_ID}] Session deletion failure\n"
  echo "[${SESSION_ID}] Terminating the script...\n"
  exit 1
fi
echo "[${SESSION_ID}] Session Delete : ${SESSION_DELETE_STATUS} \n"
exit 0
