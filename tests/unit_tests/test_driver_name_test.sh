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

setTestDriverNameOnFirstBuild() {
  cmd_output=$(${1})
  exit_code=${?}
  assertContains 'set test driver name on first build output' "${cmd_output}" 'Built target my-alt-test-driver'
  assertTrue 'set test driver name on first build test driver exec' '[ ! -e my-test-driver ]'
  assertTrue 'set test driver name on first build alt test driver exec' '[ -e my-alt-test-driver ]'
  assertEquals 'set test driver name on first build exit code' "${exit_code}" 0
}

buildWithDefaultTestDriverName() {
  cmd_output=$(./${EXEC_NAME} -dT)
  exit_code=${?}
  assertContains 'build with default test driver name output' "${cmd_output}" 'Built target my-test-driver'
  assertTrue 'build with default test driver test driver exec' '[ -e my-test-driver ]'
  assertTrue 'build with default test driver alt test driver exec' '[ -e my-alt-test-driver ]'
  assertEquals 'build with default test driver exit code' "${exit_code}" 0
}

setTestDriverNameOnRepeatBuild() {
  rm my-alt-test-driver
  cmd_output=$(${1})
  exit_code=${?}
  assertContains 'set test driver name on repeat build output' "${cmd_output}" 'Built target my-alt-test-driver'
  assertTrue 'set test driver name on repeat build test driver exec' '[ -e my-test-driver ]'
  assertTrue 'set test driver name on repeat build alt test driver exec' '[ -e my-alt-test-driver ]'
  assertEquals 'set test driver name on repeat build exit code' "${exit_code}" 0
}

setTestDriverNameWithoutMakingTests() {
  ./${EXEC_NAME} -c
  ./${EXEC_NAME} -c -x my-alt-test-driver
  cmd_output=$(./${EXEC_NAME} -d -x my-alt-test-driver)
  exit_code=${?}
  assertContains 'set test driver name without making tests build output' "${cmd_output}" 'Built target my-exec'
  assertTrue 'set test driver name without making tests main exec' '[ -e my-exec ]'
  assertTrue 'set test driver name without making tests test driver exec' '[ ! -e my-test-driver ]'
  assertTrue 'set test driver name without making tests alt test driver exec' '[ ! -e my-alt-test-driver ]'
  assertEquals 'set test driver name without making tests exit code' "${exit_code}" 0
}

testDriverNameHelper() {
  setTestDriverNameOnFirstBuild "${1}"
  buildWithDefaultTestDriverName "${1}"
  setTestDriverNameOnRepeatBuild "${1}"
  setTestDriverNameWithoutMakingTests "${1}"
}

################################################################################
# UNIT TESTS
################################################################################

testDriverNameShort() {
  testDriverNameHelper "./${EXEC_NAME} -dT -x my-alt-test-driver"
}

testDriverNameLong() {
  testDriverNameHelper "./${EXEC_NAME} -dT --test-driver-name=my-alt-test-driver"
}

################################################################################
# TEST SUITE
################################################################################

suite() {
  # shellcheck disable=SC2154
  if [ "${unit_test_function}" != ''  ] && [ "$( type -t "${unit_test_function}" )" = "function" ]; then
    suite_addTest "${unit_test_function}"
  else
    suite_addTest testDriverNameShort
    suite_addTest testDriverNameLong
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

