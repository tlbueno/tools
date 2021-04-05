#!/usr/bin/env bash

set -e

TO="${SEND_WEEKLY_STATUS_TO}"
LAST_WEEK_NUMBER=$(date --date="1 week ago" +"%W")
SUBJECT="Status week ${LAST_WEEK_NUMBER}"
EMAIL="To: ${TO}
From: ${SEND_WEEKLY_STATUS_FROM}
Subject: ${SUBJECT}

This is my status for week ${LAST_WEEK_NUMBER}

$(did last week | tail --lines=+7)

Thank you,
Tiago Bueno
"

echo "${EMAIL}"
echo ""
read -p "Send mail? " -r
echo  ""
if [[ $REPLY =~ ^[Yy]$ ]] ; then
    msmtp "${TO}" <<< "${EMAIL}"
fi
