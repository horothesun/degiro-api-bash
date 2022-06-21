#!/bin/bash

DEGIRO_OTP="$1"

[[ -z "${DEGIRO_USERNAME}" ]] && echo "Error: DEGIRO_USERNAME must be defined" && return 10
[[ -z "${DEGIRO_PASSWORD}" ]] && echo "Error: DEGIRO_PASSWORD must be defined" && return 20

[[ -z "${DEGIRO_OTP}" ]] && echo "Error: DEGIRO_OTP must be passed as first argument" && return 11

DEGIRO_BASE_URL="https://trader.degiro.nl/"
LOGIN_ENDPOINT="login/secure/login/totp"
GET_ACCOUNT_CONFIG_ENDPOINT="login/secure/config"

LOGIN_BODY="{
    \"isPassCodeReset\": false,
    \"isRedirectToMobile\": false,
    \"username\": \"${DEGIRO_USERNAME}\",
    \"password\": \"${DEGIRO_PASSWORD}\",
    \"oneTimePassword\": \"${DEGIRO_OTP}\",
    \"queryParams\": {
      \"reason\": \"session_expired\"
    }
  }
"

DEGIRO_SESSION_ID=$(
  curl --silent \
    --request "POST" "${DEGIRO_BASE_URL}${LOGIN_ENDPOINT}" \
    --header "Content-Type: application/json" \
    --data-raw "${LOGIN_BODY}" | \
    jq --raw-output '.sessionId'
)

DEGIRO_ACCOUNT_CONFIG=$(
  curl --silent \
    --request "GET" "${DEGIRO_BASE_URL}${GET_ACCOUNT_CONFIG_ENDPOINT}" \
    --header "Cookie: JSESSIONID=${DEGIRO_SESSION_ID}" | \
    jq --compact-output '.'
)

PA_URL=$(echo "${DEGIRO_ACCOUNT_CONFIG}" | jq --raw-output '.data.paUrl')

ACCOUNT_DATA=$(
  curl --silent \
    --request "GET" "${PA_URL}client?sessionId=${DEGIRO_SESSION_ID}" \
    --header "Cookie: JSESSIONID=${DEGIRO_SESSION_ID}" | \
    jq --compact-output '.'
)

DEGIRO_INT_ACCOUNT=$(echo "${ACCOUNT_DATA}" | jq --raw-output '.data.intAccount')

export DEGIRO_SESSION_ID
export DEGIRO_ACCOUNT_CONFIG
export DEGIRO_INT_ACCOUNT
