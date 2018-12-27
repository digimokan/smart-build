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

cleanAllBeforeBuild() {
  cmd_output=$(${1})
  exit_code=${?}
  assertNull 'clean-all before-build output' "${cmd_output}"
  assertEquals 'clean-all before-build exit code' "${exit_code}" 0
}

cleanAllWithFirstBuild() {
  cmd_output=$(${1} -d)
  exit_code=${?}
  assertContains 'clean-all with first build output' "${cmd_output}" 'Built target my-exec'
  assertTrue 'clean-all with first build main exec' '[ -e my-exec ]'
  assertEquals 'clean-all with first build exit code' "${exit_code}" 0
}

cleanAllWithRepeatBuild() {
  cmd_output=$(${1} -d)
  exit_code=${?}
  assertContains 'clean-all with repeat build output' "${cmd_output}" 'Built target my-exec'
  assertTrue 'clean-all with repeat build main exec' '[ -e my-exec ]'
  assertEquals 'clean-all with repeat build exit code' "${exit_code}" 0
}

cleanAllAfterBuild() {
  cmd_output=$(${1})
  exit_code=${?}
  assertNull 'clean-all after build output' "${cmd_output}"
  assertTrue 'clean-all after build main exec' '[ ! -e my-exec ]'
  assertTrue 'clean-all after build testing exec' '[ ! -e my-test-driver ]'
  assertTrue 'clean-all after build testing exec' '[ ! -e build ]'
  assertEquals 'clean-all after build exit code' "${exit_code}" 0
}

cleanAllHelper() {
  cleanAllBeforeBuild "${1}"
  cleanAllWithFirstBuild "${1}"
  cleanAllWithRepeatBuild "${1}"
  cleanAllAfterBuild "${1}"
}

cleanExecsBeforeBuild() {
  cmd_output=$(${1})
  exit_code=${?}
  assertNull 'clean-execs before-build output' "${cmd_output}"
  assertEquals 'clean-execs before-build exit code' "${exit_code}" 0
}

cleanExecsWithFirstBuild() {
  cmd_output=$(${1} -d)
  exit_code=${?}
  assertContains 'clean-execs with first build output' "${cmd_output}" 'Built target my-exec'
  assertTrue 'clean-execs with first build main exec' '[ -e my-exec ]'
  assertEquals 'clean-execs with first build exit code' "${exit_code}" 0
}

cleanExecsWithRepeatBuild() {
  cmd_output=$(${1} -d)
  exit_code=${?}
  assertContains 'clean-execs with repeat build output' "${cmd_output}" 'Built target my-exec'
  assertTrue 'clean-execs with repeat build main exec' '[ -e my-exec ]'
  assertEquals 'clean-execs with repeat build exit code' "${exit_code}" 0
}

cleanExecsAfterBuild() {
  cmd_output=$(${1})
  exit_code=${?}
  assertNull 'clean-execs after build output' "${cmd_output}"
  assertTrue 'clean-execs after build main exec' '[ ! -e my-exec ]'
  assertTrue 'clean-execs after build testing exec' '[ ! -e my-test-driver ]'
  assertTrue 'clean-execs after build testing exec' '[ -e build ]'
  assertEquals 'clean-execs after build exit code' "${exit_code}" 0
}

cleanExecsHelper() {
  cleanExecsBeforeBuild "${1}"
  cleanExecsWithFirstBuild "${1}"
  cleanExecsWithRepeatBuild "${1}"
  cleanExecsAfterBuild "${1}"
}

################################################################################
# UNIT TESTS
################################################################################

cleanAllShort() {
  cleanAllHelper "./${EXEC_NAME} -c"
}

cleanAllLong() {
  cleanAllHelper "./${EXEC_NAME} --clean-all"
}

cleanExecsShort() {
  cleanExecsHelper "./${EXEC_NAME} -C"
}

cleanExecsLong() {
  cleanExecsHelper "./${EXEC_NAME} --clean-executables"
}

################################################################################
# TEST SUITE
################################################################################

suite() {
  # shellcheck disable=SC2154
  if [ "${unit_test_function}" != ''  ] && [ "$( type -t "${unit_test_function}" )" = "function" ]; then
    suite_addTest "${unit_test_function}"
  else
    suite_addTest cleanAllShort
    suite_addTest cleanAllLong
    suite_addTest cleanExecsShort
    suite_addTest cleanExecsLong
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

