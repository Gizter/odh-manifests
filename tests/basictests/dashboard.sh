#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

source ${MY_DIR}/../util

os::test::junit::declare_suite_start "$MY_SCRIPT"

function check_resources() {
    header "Testing dashboard installation"
    os::cmd::expect_success "oc project ${ODHPROJECT}"
    os::cmd::try_until_text "oc get odh-dashboard odh-dashboard" "odh-dashboard" $odhdefaulttimeout $odhdefaultinterval
    os::cmd::try_until_text "oc get crd odhdashboardconfigs " "odhdashboardconfigs" $odhdefaulttimeout $odhdefaultinterval
    os::cmd::try_until_text "oc get role odh-dashboard" "odh-dashboard" $odhdefaulttimeout $odhdefaultinterval
    os::cmd::try_until_text "oc get rolebinding odh-dashboard" "odh-dashboard" $odhdefaulttimeout $odhdefaultinterval
    os::cmd::try_until_text "oc get route odh-dashboard" "odh-dashboard" $odhdefaulttimeout $odhdefaultinterval
    os::cmd::try_until_text "oc get service odh-dashboard" "odh-dashboard" $odhdefaulttimeout $odhdefaultinterval
    os::cmd::try_until_text "oc get deployment odh-dashboard" "odh-dashboard" $odhdefaulttimeout $odhdefaultinterval
    os::cmd::try_until_text "oc get pods -l deployment=odh-dashboard --field-selector='status.phase=Running' -o jsonpath='{$.items[*].metadata.name}' | wc -w" "2" $odhdefaulttimeout $odhdefaultinterval
}

function check_ui() {
    header "Testing dashboard UI loads"
    os::cmd::expect_success "oc project ${ODHPROJECT}"
    local route="https://"$(oc get route odh-dashboard -o jsonpath='{.spec.host}')
    os::log::info "$route"
    os::cmd::try_until_text "curl -k -s -o /dev/null -w \"%{http_code}\" $route/api/components" "200" $odhdefaulttimeout $odhdefaultinterval
    os::cmd::try_until_text "curl -k $route/api/components | jq '.[].metadata.name'" "jupyterhub" $odhdefaulttimeout $odhdefaultinterval
    os::cmd::try_until_text "curl -k $route" "<title>Open Data Hub</title>" $odhdefaulttimeout $odhdefaultinterval
}

check_resources
check_ui

os::test::junit::declare_suite_end
