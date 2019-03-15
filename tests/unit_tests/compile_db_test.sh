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

################################################################################
# UNIT TESTS
################################################################################

buildOnly() {
  cmd_output=$(./${EXEC_NAME} -d 2>&1)
  exit_code=${?}
  assertContains 'buildOnly linking exec' "${cmd_output}" 'Linking CXX executable my-exec'
  assertContains 'buildOnly building exec' "${cmd_output}" 'Built target my-exec'
  assertTrue 'buildOnly compile db exists' '[ -e 'compile_commands.json' ]'
  assertTrue 'buildOnly exec exists' '[ -e my-exec ]'
  assertEquals 'buildOnly exit code' "${exit_code}" 0
}

buildAndTest() {
  cmd_output=$(./${EXEC_NAME} -dt 2>&1)
  exit_code=${?}
  assertContains 'buildAndTest linking exec' "${cmd_output}" 'Linking CXX executable my-exec'
  assertContains 'buildAndTest building exec' "${cmd_output}" 'Built target my-exec'
  assertContains 'buildAndTest unit tests' "${cmd_output}" '[doctest] Status: SUCCESS'
  assertTrue 'buildAndTest compile db exists' '[ -e compile_commands.json ]'
  assertTrue 'buildAndTest exec exists' '[ -e my-exec ]'
  assertTrue 'buildAndTest test-driver exists' '[ -e my-test-driver ]'
  assertEquals 'buildAndTest exit code' "${exit_code}" 0
}

################################################################################
# TEST SUITE
################################################################################

suite() {
  # shellcheck disable=SC2154
  if [ "${unit_test_function}" != ''  ] && [ "$( type -t "${unit_test_function}" )" = "function" ]; then
    suite_addTest "${unit_test_function}"
  else
    suite_addTest buildOnly
    suite_addTest buildAndTest
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

