#!/usr/bin/env bash

OPERATOR_IMAGE="registry.redhat.io/amq7/amq-broker-rhel7-operator:0.19"
CURRENT_BROKER_IMAGE="registry.redhat.io/amq7/amq-broker:7.8"
PREVIOUS_BROKER_IMAGE="registry.redhat.io/amq7/amq-broker:7.7"
INSTALL_EXAMPLES="/home/tbueno/apps/amq-broker/released/7.8.1/OPR.2/amq-broker-operator-7.8.1-ocp-install-examples/deploy"
REPORT_DIR="${HOME}/tmp/reports.$$"

cd ~/dev/golang/src/github.com/artemiscloud/activemq-artemis-operator-test-suite || exit 1
ginkgo \
    -r \
    -keepGoing \
    ./test/... -- \
    -operator-image "${OPERATOR_IMAGE}" \
    -broker-image "${CURRENT_BROKER_IMAGE}" \
    -broker-image-second "${PREVIOUS_BROKER_IMAGE}" \
    -repository "${INSTALL_EXAMPLES}" \
    -report-dir "${REPORT_DIR}" \
    -broker-name amq-broker \
    -v2