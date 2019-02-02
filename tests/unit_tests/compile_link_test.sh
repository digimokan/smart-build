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

buildWithoutTests() {
  cmd_output=$(./${EXEC_NAME} -d)
  exit_code=${?}
  assertContains 'buildWithoutTests linking exec' "${cmd_output}" 'Linking CXX executable my-exec'
  assertContains 'buildWithoutTests building exec' "${cmd_output}" 'Built target my-exec'
  assertNotContains 'buildWithoutTests linking test-driver' "${cmd_output}" 'Linking CXX executable my-test-driver'
  assertNotContains 'buildWithoutTests building test-driver' "${cmd_output}" 'Built target my-test-driver'
  assertNotContains 'buildWithoutTests unit tests' "${cmd_output}" '[doctest] Status: SUCCESS!'
  assertNotContains 'buildWithoutTests ctest' "${cmd_output}" '% tests passed, '
  assertTrue 'buildWithoutTests exec exists' '[ -e my-exec ]'
  assertFalse 'buildWithoutTests test-driver exists' '[ -e my-test-driver ]'
  assertEquals 'buildWithoutTests exit code' "${exit_code}" 0
}

repeatBuildWithoutTests() {
  cmd_output=$(./${EXEC_NAME} -d)
  cmd_output=$(./${EXEC_NAME} -d)
  exit_code=${?}
  assertNotContains 'repeatBuildWithoutTests linking exec' "${cmd_output}" 'Linking CXX executable my-exec'
  assertContains 'repeatBuildWithoutTests building exec' "${cmd_output}" 'Built target my-exec'
  assertNotContains 'repeatBuildWithoutTests linking test-driver' "${cmd_output}" 'Linking CXX executable my-test-driver'
  assertNotContains 'repeatBuildWithoutTests building test-driver' "${cmd_output}" 'Built target my-test-driver'
  assertNotContains 'repeatBuildWithoutTests unit tests' "${cmd_output}" '[doctest] Status: SUCCESS!'
  assertNotContains 'repeatBuildWithoutTests ctest' "${cmd_output}" '% tests passed, '
  assertTrue 'repeatBuildWithoutTests exec exists' '[ -e my-exec ]'
  assertFalse 'repeatBuildWithoutTests test-driver exists' '[ -e my-test-driver ]'
  assertEquals 'repeatBuildWithoutTests exit code' "${exit_code}" 0
}

buildWithTests() {
  cmd_output=$(./${EXEC_NAME} -dt)
  exit_code=${?}
  assertContains 'buildWithTests linking exec' "${cmd_output}" 'Linking CXX executable my-exec'
  assertContains 'buildWithTests building exec' "${cmd_output}" 'Built target my-exec'
  assertContains 'buildWithTests linking test-driver' "${cmd_output}" 'Linking CXX executable my-test-driver'
  assertContains 'buildWithTests building test-driver' "${cmd_output}" 'Built target my-test-driver'
  assertContains 'buildWithTests unit tests' "${cmd_output}" '[doctest] Status: SUCCESS!'
  assertNotContains 'buildWithTests ctest' "${cmd_output}" '% tests passed, '
  assertTrue 'buildWithTests exec exists' '[ -e my-exec ]'
  assertTrue 'buildWithTests test-driver exists' '[ -e my-test-driver ]'
  assertEquals 'buildWithTests exit code' "${exit_code}" 0
}

repeatBuildWithTests() {
  cmd_output=$(./${EXEC_NAME} -dt)
  cmd_output=$(./${EXEC_NAME} -dt)
  exit_code=${?}
  assertNotContains 'repeatBuildWithTests linking exec' "${cmd_output}" 'Linking CXX executable my-exec'
  assertContains 'repeatBuildWithTests building exec' "${cmd_output}" 'Built target my-exec'
  assertNotContains 'repeatBuildWithTests linking test-driver' "${cmd_output}" 'Linking CXX executable my-test-driver'
  assertContains 'repeatBuildWithTests building test-driver' "${cmd_output}" 'Built target my-test-driver'
  assertContains 'repeatBuildWithTests unit tests' "${cmd_output}" '[doctest] Status: SUCCESS!'
  assertNotContains 'repeatBuildWithTests ctest' "${cmd_output}" '% tests passed, '
  assertTrue 'repeatBuildWithTests exec exists' '[ -e my-exec ]'
  assertTrue 'repeatBuildWithTests test-driver exists' '[ -e my-test-driver ]'
  assertEquals 'repeatBuildWithTests exit code' "${exit_code}" 0
}

buildTestsOnly() {
  cmd_output=$(./${EXEC_NAME} -dtE)
  exit_code=${?}
  assertNotContains 'buildTestsOnly linking exec' "${cmd_output}" 'Linking CXX executable my-exec'
  assertNotContains 'buildTestsOnly building exec' "${cmd_output}" 'Built target my-exec'
  assertContains 'buildTestsOnly linking test-driver' "${cmd_output}" 'Linking CXX executable my-test-driver'
  assertContains 'buildTestsOnly building test-driver' "${cmd_output}" 'Built target my-test-driver'
  assertContains 'buildTestsOnly unit tests' "${cmd_output}" '[doctest] Status: SUCCESS!'
  assertNotContains 'buildTestsOnly ctest' "${cmd_output}" '% tests passed, '
  assertFalse 'buildTestsOnly exec exists' '[ -e my-exec ]'
  assertTrue 'buildTestsOnly test-driver exists' '[ -e my-test-driver ]'
  assertEquals 'buildTestsOnly exit code' "${exit_code}" 0
}

repeatBuildTestsOnly() {
  cmd_output=$(./${EXEC_NAME} -dtE)
  cmd_output=$(./${EXEC_NAME} -dtE)
  exit_code=${?}
  assertNotContains 'repeatBuildTestsOnly linking exec' "${cmd_output}" 'Linking CXX executable my-exec'
  assertNotContains 'repeatBuildTestsOnly building exec' "${cmd_output}" 'Built target my-exec'
  assertNotContains 'repeatBuildTestsOnly linking test-driver' "${cmd_output}" 'Linking CXX executable my-test-driver'
  assertContains 'repeatBuildTestsOnly building test-driver' "${cmd_output}" 'Built target my-test-driver'
  assertContains 'repeatBuildTestsOnly unit tests' "${cmd_output}" '[doctest] Status: SUCCESS!'
  assertNotContains 'repeatBuildTestsOnly ctest' "${cmd_output}" '% tests passed, '
  assertFalse 'repeatBuildTestsOnly exec exists' '[ -e my-exec ]'
  assertTrue 'repeatBuildTestsOnly test-driver exists' '[ -e my-test-driver ]'
  assertEquals 'repeatBuildTestsOnly exit code' "${exit_code}" 0
}

################################################################################
# TEST SUITE
################################################################################

suite() {
  # shellcheck disable=SC2154
  if [ "${unit_test_function}" != ''  ] && [ "$( type -t "${unit_test_function}" )" = "function" ]; then
    suite_addTest "${unit_test_function}"
  else
    suite_addTest buildWithoutTests
    suite_addTest repeatBuildWithoutTests
    suite_addTest buildWithTests
    suite_addTest repeatBuildWithTests
    suite_addTest buildTestsOnly
    suite_addTest repeatBuildTestsOnly
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

