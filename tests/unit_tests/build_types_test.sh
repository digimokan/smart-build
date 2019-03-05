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

buildTypesHelper() {
  cmd_output=$(${1} 2>&1)
  exit_code=${?}
  assertContains 'build-type output' "${cmd_output}" 'Built target my-exec'
  assertNotContains 'build type unused var warn' "${cmd_output}" 'Manually-specified variables were not used by the project'
  assertTrue 'build-type main exec' '[ -e my-exec ]'
  assertEquals 'build-type exit code' "${exit_code}" 0
  cmd_output=$(${1})
  exit_code=${?}
  assertContains 'repeat build-type output' "${cmd_output}" 'Built target my-exec'
  assertNotContains 'repeat build type unused var warn' "${cmd_output}" 'Manually-specified variables were not used by the project'
  assertTrue 'repeat build-type main exec' '[ -e my-exec ]'
  assertEquals 'repeat build-type exit code' "${exit_code}" 0
}

################################################################################
# UNIT TESTS
################################################################################

buildTypeDebugShort() {
  buildTypesHelper "./${EXEC_NAME} -d"
}

buildTypeDebugLong() {
  buildTypesHelper "./${EXEC_NAME} --build-type-debug"
}

buildTypeReleaseShort() {
  buildTypesHelper "./${EXEC_NAME} -r"
}

buildTypeReleaseLong() {
  buildTypesHelper "./${EXEC_NAME} --build-type-release"
}

buildTypeReleaseWithDebugShort() {
  buildTypesHelper "./${EXEC_NAME} -w"
}

buildTypeReleaseWithDebugLong() {
  buildTypesHelper "./${EXEC_NAME} --build-type-release-with-debug"
}

buildTypeReleaseMinMaxShort() {
  buildTypesHelper "./${EXEC_NAME} -m"
}

buildTypeReleaseMinMaxLong() {
  buildTypesHelper "./${EXEC_NAME} --build-type-release-min-max"
}

################################################################################
# TEST SUITE
################################################################################

suite() {
  # shellcheck disable=SC2154
  if [ "${unit_test_function}" != ''  ] && [ "$( type -t "${unit_test_function}" )" = "function" ]; then
    suite_addTest "${unit_test_function}"
  else
    suite_addTest buildTypeDebugShort
    suite_addTest buildTypeDebugLong
    suite_addTest buildTypeReleaseShort
    suite_addTest buildTypeReleaseLong
    suite_addTest buildTypeReleaseWithDebugShort
    suite_addTest buildTypeReleaseWithDebugLong
    suite_addTest buildTypeReleaseMinMaxShort
    suite_addTest buildTypeReleaseMinMaxLong
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

