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
  writeConfigFiles
}

tearDown() {
  # shellcheck source=../per_test_teardown.sh
  . ../../per_test_teardown.sh
}

################################################################################
# HELPER FUNCTIONS
################################################################################

writeConfigFiles() {
  ./${EXEC_NAME} --generate-project-config --generate-cmakelists
}

quietModeHelper() {
  cmd_output=$(${1} -d)
  exit_code=${?}
  assertNull 'quiet mode stdout output' "${cmd_output}"
  assertTrue 'quiet mode exec' '[ -e my-exec ]'
  assertEquals 'quiet mode stdout exit code -->' "${exit_code}" 0
  cmd_output=$(${1} --non-existent-option)
  exit_code=${?}
  assertContains 'quiet mode stderr output' "${cmd_output}" 'unknown option "non-existent-option"'
  assertEquals 'quiet mode stderr exit code' "${exit_code}" 1
}

################################################################################
# UNIT TESTS
################################################################################

quietModeShort() {
  quietModeHelper "./${EXEC_NAME} -q"
}

quietModeLong() {
  quietModeHelper "./${EXEC_NAME} --quiet-mode"
}

################################################################################
# TEST SUITE
################################################################################

suite() {
  # shellcheck disable=SC2154
  if [ "${unit_test_function}" != ''  ] && [ "$( type -t "${unit_test_function}" )" = "function" ]; then
    suite_addTest "${unit_test_function}"
  else
    suite_addTest quietModeShort
    suite_addTest quietModeLong
  fi
}

################################################################################
# LOAD TEST FRAMEWORK (MUST GO LAST)
################################################################################

# zsh compatibility options
export SHUNIT_PARENT=$0
setopt shwordsplit 2> /dev/null
# shellcheck disable=SC1091
. "${PATH_TO_SHUNIT}"

