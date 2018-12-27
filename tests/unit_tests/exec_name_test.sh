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

setExecNameOnFirstBuild() {
  cmd_output=$(${1})
  exit_code=${?}
  assertContains 'set exec name on first build output' "${cmd_output}" 'Built target my-alt-exec'
  assertTrue 'set exec name on first build main exec' '[ ! -e my-exec ]'
  assertTrue 'set exec name on first build alt exec' '[ -e my-alt-exec ]'
  assertEquals 'set exec name on first build exit code' "${exit_code}" 0
}

buildWithDefaultExecName() {
  cmd_output=$(./${EXEC_NAME} -d)
  exit_code=${?}
  assertContains 'build with default exec name output' "${cmd_output}" 'Built target my-exec'
  assertTrue 'set exec name on first build main exec' '[ -e my-exec ]'
  assertTrue 'set exec name on first build alt exec' '[ -e my-alt-exec ]'
  assertEquals 'build with default exec name exit code' "${exit_code}" 0
}

setExecNameOnRepeatBuild() {
  rm my-alt-exec
  cmd_output=$(${1})
  exit_code=${?}
  assertContains 'set exec name on repeat build output' "${cmd_output}" 'Built target my-alt-exec'
  assertTrue 'set exec name on repeat build main exec' '[ -e my-exec ]'
  assertTrue 'set exec name on repeat build alt exec' '[ -e my-alt-exec ]'
  assertEquals 'set exec name on repeat build exit code' "${exit_code}" 0
}

execNameHelper() {
  setExecNameOnFirstBuild "${1}"
  buildWithDefaultExecName "${1}"
  setExecNameOnRepeatBuild "${1}"
}

################################################################################
# UNIT TESTS
################################################################################

execNameShort() {
  execNameHelper "./${EXEC_NAME} -d -e my-alt-exec"
}

execNameLong() {
  execNameHelper "./${EXEC_NAME} -d --executable-name=my-alt-exec"
}

################################################################################
# TEST SUITE
################################################################################

suite() {
  # shellcheck disable=SC2154
  if [ "${unit_test_function}" != ''  ] && [ "$( type -t "${unit_test_function}" )" = "function" ]; then
    suite_addTest "${unit_test_function}"
  else
    suite_addTest execNameShort
    suite_addTest execNameLong
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

