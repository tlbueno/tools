#!/usr/bin/env bash

set -o pipefail
set -e

SUPPORTED_FUNCTIONS="clean build mainTests extraTests integrationTests"
SRC_DIR="${AB_SRCDIR:-.}"

MVN_SETTINGS="${AB_MVN_SETTINGS}"
MVN_IGNORE_TEST_FAILURE="${AB_MVN_IGNORE_TEST_FAILURE:-false}"
MVN_TRIM_STACK_TRACE="${AB_MVN_TRIM_STACK_TRACE:-false}"
MVN_SUREFIRE_RERUN_FAILED_TESTS_COUNT="${AB_MVN_SUREFIRE_RERUN_FAILED_TESTS_COUNT:-0}"
MVN_BUILD_PROFILES="${AB_MVN_BUILD_PROFILES:-release,tests,extra-tests,examples,noRun,tests-CI,tests-retry}"
MVN_MAIN_TESTS_PROFILES="${AB_MVN_MAIN_TEST_PROFILES:-tests,tests-CI,tests-retry}"
MVN_EXTRA_TESTS_PROFILES="${AB_MVN_EXTRA_TESTS_PROFILES:-extra-tests,tests-CI,tests-retry}"
MVN_INTEGRATION_TESTS_PROFILES="${AB_MVN_INTEGRATION_TESTS_PROFILES:-tests,tests-CI,tests-retry}"
SKIP_LICENSE_CHECK="${AB_SKIP_LICENSE_CHECK:-true}"
BUILD_LOG="${AB_BUILD_LOG:-build.log}"
MAIN_TESTS_LOG="${AB_MAIN_TEST_LOG:-mainTests.log}"
EXTRA_TESTS_LOG="${AB_EXTRA_TESTS_LOG:-extraTests.log}"
INTEGRATION_TESTS_LOG="${AB_INTEGRATION_TESTS_LOG:-integrationTests.log}"

function clean {
    local pomFile="${SRC_DIR}/pom.xml"
    local skipTests="true"
    local skipExtraTests="true"
    local skipIntegrationTests="true"
    local projects=""
    local goals="clean"
    runMaven "${pomFile}" "${MVN_BUILD_PROFILES}" "${skipTests}" "${skipExtraTests}" "${skipIntegrationTests}" \
        "${projects}" "${goals}" "${BUILD_LOG}"
}

function build {
    local pomFile="${SRC_DIR}/pom.xml"
    local skipTests="true"
    local skipExtraTests="true"
    local skipIntegrationTests="true"
    local projects=""
    local goals="install"
    runMaven "${pomFile}" "${MVN_BUILD_PROFILES}" "${skipTests}" "${skipExtraTests}" "${skipIntegrationTests}" \
        "${projects}" "${goals}" "${BUILD_LOG}"
}

function mainTests {
    local pomFile="${SRC_DIR}/pom.xml"
    local skipTests="false"
    local skipExtraTests="true"
    local skipIntegrationTests="true"
    local projects=""
    local goals="surefire:test"
    runMaven "${pomFile}" "${MVN_MAIN_TESTS_PROFILES}" "${skipTests}" "${skipExtraTests}" "${skipIntegrationTests}" \
        "${projects}" "${goals}" "${MAIN_TESTS_LOG}"
}

function extraTests {
    local pomFile="${SRC_DIR}/tests/pom.xml"
    local skipTests="false"
    local skipExtraTests="false"
    local skipIntegrationTests="true"
    local projects=":extra-tests"
    local goals="surefire:test"
    runMaven "${pomFile}" "${MVN_EXTRA_TESTS_PROFILES}" "${skipTests}" "${skipExtraTests}" "${skipIntegrationTests}" \
        "${projects}" "${goals}" "${EXTRA_TESTS_LOG}"
}

function integrationTests {
    local pomFile="${SRC_DIR}/pom.xml"
    local skipTests="false"
    local skipExtraTests="true"
    local skipIntegrationTests="false"
    local projects=":integration-tests"
    local goals="surefire:test"
    runMaven "${pomFile}" "${MVN_INTEGRATION_TESTS_PROFILES}" "${skipTests}" "${skipExtraTests}" "${skipIntegrationTests}" \
        "${projects}" "${goals}" "${INTEGRATION_TESTS_LOG}"
}

function runMaven {
    local pomFile="${1}"
    local profiles="${2}"
    local skipTests="${3}"
    local skipExtraTests="${4}"
    local skipIntegrationTests="${5}"
    local projects="${6}"
    read -r -a goals <<< "${7}"
    local logFile="${8}"

    [ -n "${projects}" ] && read -r -a projectsArg <<< "--projects ${projects}"
    [ -n "${AB_TEST_LIST}" ] && read -r -a testListArgs <<< "-Dtest=${AB_TEST_LIST}"
    [ -n "${MVN_SETTINGS}" ] && mvnSettings="--settings ${MVN_SETTINGS}"
   
    set -x
    mvn ${mvnSettings} \
        --file "${pomFile}" \
        --show-version \
        --errors \
        --activate-profiles "${profiles}" \
        -DskipLicenseCheck="${SKIP_LICENSE_CHECK}" \
        -DskipTests="${skipTests}" \
        -Dmaven.test.skip.exec="${skipTests}" \
        -Dmaven.test.failure.ignore="${MVN_IGNORE_TEST_FAILURE}" \
        -DskipExtraTests="${skipExtraTests}" \
        -DskipIntegrationTests="${skipIntegrationTests}" \
        -DtrimStackTrace="${MVN_TRIM_STACK_TRACE}" \
        -Dsurefire.rerunFailingTestsCount="${MVN_SUREFIRE_RERUN_FAILED_TESTS_COUNT}" \
        "${projectsArg[@]}" \
        "${testListArgs[@]}" \
        "${goals[@]}" 2>&1 |tee -a "${logFile}"
}

command=${1}
if [[ ! "${SUPPORTED_FUNCTIONS}" =~ ${command} ]] ; then
    echo "error: function ${command} not supported"
    exit 1
fi
${command}
