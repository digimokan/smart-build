#!/bin/sh

################################################################################
# ENV VARS
#   unit_test_function  optional single test function to run in this file
################################################################################

################################################################################
# LOAD COMMON VARS
################################################################################

#shellcheck source=../unit_test_vars.sh
. ../unit_test_vars.sh

################################################################################
# SETUP / TEARDOWN
################################################################################

setUp() {
  #shellcheck source=../per_test_setup.sh
  . ../per_test_setup.sh
}

tearDown() {
  # shellcheck source=../per_test_teardown.sh
  . ../../per_test_teardown.sh
}

################################################################################
# HELPER FUNCTIONS
################################################################################

helpHelper() {
  cmd_output=$(${1})
  exit_code=${?}
  assertContains 'Basic print-usage help has output -->' "${cmd_output}" 'USAGE'
  assertContains 'Basic print-usage help has output -->' "${cmd_output}" 'OPTIONS'
  assertEquals 'Basic print-usage help has correct exit code -->' "${exit_code}" 0
}

################################################################################
# UNIT TESTS
################################################################################

helpShort() {
  helpHelper "./${EXEC_NAME} -h"
}

helpLong() {
  helpHelper "./${EXEC_NAME} --help"
}

################################################################################
# TEST SUITE
################################################################################

suite() {
  # shellcheck disable=SC2154
  if [ "${unit_test_function}" != ''  ] && [ "$( type -t "${unit_test_function}" )" = "function" ]; then
    suite_addTest "${unit_test_function}"
  else
    suite_addTest helpShort
    suite_addTest helpLong
  fi
}

################################################################################
# BAD INVOCATION
################################################################################

# testMissingAllOptions() {
#   cmd_output=$(./test_project/fd.sh)
#   assertContains 'no options provided -->' "${cmd_output}" "USAGE"
#   assertContains 'Basic print-usage help -->' "${cmd_output}" "OPTIONS"
# }

################################################################################
# LOAD TEST FRAMEWORK (MUST GO LAST)
################################################################################

# shellcheck disable=SC1091
. "${PATH_TO_SHUNIT}"

