#!/bin/bash

[[ -z "${DEGIRO_SESSION_ID}" ]] && echo "Error: DEGIRO_SESSION_ID must be defined" && exit 10
[[ -z "${DEGIRO_ACCOUNT_CONFIG}" ]] && echo "Error: DEGIRO_ACCOUNT_CONFIG must be defined" && exit 20
[[ -z "${DEGIRO_INT_ACCOUNT}" ]] && echo "Error: DEGIRO_INT_ACCOUNT must be defined" && exit 30

PA_URL=$(echo "${DEGIRO_ACCOUNT_CONFIG}" | jq --raw-output '.data.paUrl')
TRADING_URL=$(echo "${DEGIRO_ACCOUNT_CONFIG}" | jq --raw-output '.data.tradingUrl')
DICTIONARY_URL=$(echo "${DEGIRO_ACCOUNT_CONFIG}" | jq --raw-output '.data.dictionaryUrl')
REPORTING_URL=$(echo "${DEGIRO_ACCOUNT_CONFIG}" | jq --raw-output '.data.reportingUrl')

GET_ACCOUNT_INFO_ENDPOINT="v5/account/info/"
GET_ACCOUNT_REPORTS_ENDPOINT="document/list/report"
GET_GENERIC_DATA_ENDPOINT="v5/update/"
GET_ACCOUNT_STATE_ENDPOINT="v6/accountoverview"

PORTFOLIO=$(
  curl --silent \
    --request "GET" "${TRADING_URL}v5/update/${DEGIRO_INT_ACCOUNT};jsessionid=${DEGIRO_SESSION_ID}?&portfolio=0" | \
    jq --compact-output '.'
)
# echo "${PORTFOLIO}" | jq '.'

ACCOUNT_REPORTS=$(
  curl --silent \
    --request "GET" "${PA_URL}${GET_ACCOUNT_REPORTS_ENDPOINT}?intAccount=${DEGIRO_INT_ACCOUNT}&sessionId=${DEGIRO_SESSION_ID}" \
    --header "Cookie: JSESSIONID=${DEGIRO_SESSION_ID}" | \
    jq --compact-output '.'
)
# echo "${ACCOUNT_REPORTS}" | jq '.'

CASH_FUNDS=$(
  curl --silent \
    --request "GET" "${TRADING_URL}${GET_GENERIC_DATA_ENDPOINT}${DEGIRO_INT_ACCOUNT};jsessionid=${DEGIRO_SESSION_ID}?cashFunds=0&limit=100" \
    --header "Cookie: JSESSIONID=${DEGIRO_SESSION_ID}" | \
    jq --compact-output '.'
)
# echo "${CASH_FUNDS}" | jq '.'

CONFIG_DICTIONARY=$(
  curl --silent \
    --request "GET" "${DICTIONARY_URL}?intAccount=${DEGIRO_INT_ACCOUNT}&jsessionid=${DEGIRO_SESSION_ID}" \
    --header "Cookie: JSESSIONID=${DEGIRO_SESSION_ID}" | \
    jq --compact-output '.'
)
# echo "${CONFIG_DICTIONARY}" | jq '.'

ACCOUNT_INFO=$(
  curl --silent \
    --request "GET" "${TRADING_URL}${GET_ACCOUNT_INFO_ENDPOINT}${DEGIRO_INT_ACCOUNT};jsessionid=${DEGIRO_SESSION_ID}" \
    --header "Cookie: JSESSIONID=${DEGIRO_SESSION_ID}" | \
    jq --compact-output '.'
)
# echo "${ACCOUNT_INFO}" | jq '.'

# url-encoded DD/MM/YYYY dates
ACCOUNT_STATE_FROM="01%2F06%2F2022"
ACCOUNT_STATE_TO="21%2F06%2F2022"
ACCOUNT_STATE=$(
  curl --silent \
    --request "GET" "${REPORTING_URL}${GET_ACCOUNT_STATE_ENDPOINT}?fromDate=${ACCOUNT_STATE_FROM}&toDate=${ACCOUNT_STATE_TO}&intAccount=${DEGIRO_INT_ACCOUNT}&sessionId=${DEGIRO_SESSION_ID}" \
    --header "Cookie: JSESSIONID=${DEGIRO_SESSION_ID}" | \
    jq --compact-output '.'
)
# echo "${ACCOUNT_STATE}" | jq '.'
