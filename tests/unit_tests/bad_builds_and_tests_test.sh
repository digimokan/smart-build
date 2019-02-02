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

badCmakeConfigure() {
  sed -i '16s/main/bad_main/' .project_config
  cmd_output=$(./${EXEC_NAME} -dt 2>&1)
  exit_code=${?}
  assertContains 'badCmakeConfigure cmake error' "${cmd_output}" 'CMake Error at CMakeLists.txt'
  assertNotContains 'badCmakeConfigure linking exec' "${cmd_output}" 'Linking CXX executable my-exec'
  assertNotContains 'badCmakeConfigure building exec' "${cmd_output}" 'Built target my-exec'
  assertNotContains 'badCmakeConfigure unit tests' "${cmd_output}" '[doctest] Status'
  assertNotContains 'badCmakeConfigure ctest' "${cmd_output}" '% tests passed, '
  assertFalse 'badCmakeConfigure exec exists' '[ -e my-exec ]'
  assertFalse 'badCmakeConfigure test-driver exists' '[ -e my-test-driver ]'
  assertEquals 'badCmakeConfigure exit code' "${exit_code}" 2
}

badCmakeBuild() {
  sed -i '2s/Hello/Yello/' src/somea/Hello.cpp
  cmd_output=$(./${EXEC_NAME} -dt 2>&1)
  exit_code=${?}
  assertContains 'badCmakeBuild cmake error' "${cmd_output}" 'compilation terminated'
  assertNotContains 'badCmakeBuild linking exec' "${cmd_output}" 'Linking CXX executable my-exec'
  assertNotContains 'badCmakeBuild building exec' "${cmd_output}" 'Built target my-exec'
  assertNotContains 'badCmakeBuild unit tests' "${cmd_output}" '[doctest] Status'
  assertNotContains 'badCmakeBuild ctest' "${cmd_output}" '% tests passed, '
  assertFalse 'badCmakeBuild exec exists' '[ -e my-exec ]'
  assertFalse 'badCmakeBuild test-driver exists' '[ -e my-test-driver ]'
  assertEquals 'badCmakeBuild exit code' "${exit_code}" 2
}

badUnitTestResults() {
  sed -i '8s/CHECK_NE/CHECK_EQ/' tests/unit_tests/Goodbye_test.cpp
  cmd_output=$(./${EXEC_NAME} -dt 2>&1)
  exit_code=${?}
  assertContains 'badUnitTestResults linking exec' "${cmd_output}" 'Linking CXX executable my-exec'
  assertContains 'badUnitTestResults building exec' "${cmd_output}" 'Built target my-exec'
  assertContains 'badUnitTestResults unit tests' "${cmd_output}" '[doctest] Status: FAILURE!'
  assertNotContains 'badUnitTestResults ctest' "${cmd_output}" '% tests passed, '
  assertTrue 'badUnitTestResults exec exists' '[ -e my-exec ]'
  assertTrue 'badUnitTestResults test-driver exists' '[ -e my-test-driver ]'
  assertEquals 'badUnitTestResults exit code' "${exit_code}" 3
}

################################################################################
# TEST SUITE
################################################################################

suite() {
  # shellcheck disable=SC2154
  if [ "${unit_test_function}" != ''  ] && [ "$( type -t "${unit_test_function}" )" = "function" ]; then
    suite_addTest "${unit_test_function}"
  else
    suite_addTest badCmakeConfigure
    suite_addTest badCmakeBuild
    suite_addTest badUnitTestResults
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

