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

makeAndRunTests() {
  cmd_output=$(${1})
  exit_code=${?}
  assertContains 'make-and-run-tests output' "${cmd_output}" '100% tests passed, 0 tests failed'
  assertTrue 'make-and-run-tests exec' '[ -e my-exec ]'
  assertTrue 'make-and-run-tests test driver' '[ -e my-test-driver ]'
  assertEquals 'make-and-run-tests exit code' "${exit_code}" 0
}

makeTests() {
  cmd_output=$(${1})
  exit_code=${?}
  assertNotContains 'make-and-run-tests output' "${cmd_output}" '100% tests passed, 0 tests failed'
  assertTrue 'make-and-run-tests exec' '[ -e my-exec ]'
  assertTrue 'make-and-run-tests test driver' '[ -e my-test-driver ]'
  assertEquals 'make-and-run-tests exit code' "${exit_code}" 0
}

################################################################################
# UNIT TESTS
################################################################################

makeAndRunTestsShort() {
  makeAndRunTests "./${EXEC_NAME} -d -t"
}

makeAndRunTestsLong() {
  makeAndRunTests "./${EXEC_NAME} -d --make-and-run-tests"
}

makeTestsShort() {
  makeTests "./${EXEC_NAME} -d -T"
}

makeTestsLong() {
  makeTests "./${EXEC_NAME} -d --make-tests"
}

################################################################################
# TEST SUITE
################################################################################

suite() {
  # shellcheck disable=SC2154
  if [ "${unit_test_function}" != ''  ] && [ "$( type -t "${unit_test_function}" )" = "function" ]; then
    suite_addTest "${unit_test_function}"
  else
    suite_addTest makeAndRunTestsShort
    suite_addTest makeAndRunTestsLong
    suite_addTest makeTestsShort
    suite_addTest makeTestsLong
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

