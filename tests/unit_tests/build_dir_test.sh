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

setBuildDirOnFirstBuild() {
  cmd_output=$(${1})
  exit_code=${?}
  assertContains 'set build dir on first build output' "${cmd_output}" 'Built target my-exec'
  assertTrue 'set build dir on first build build dir' '[ -e alt_build ]'
  assertTrue 'set build dir on first build main exec' '[ -e my-exec ]'
  assertEquals 'set build dir on first build exit code' "${exit_code}" 0
}

buildWithDefaultBuildDir() {
  cmd_output=$(./${EXEC_NAME} -d)
  exit_code=${?}
  assertContains 'build with default build dir output' "${cmd_output}" 'Built target my-exec'
  assertTrue 'build with default build dir build dir' '[ -e build ]'
  assertTrue 'build with default build dir build dir' '[ -e alt_build ]'
  assertTrue 'build with default build dir main exec' '[ -e my-exec ]'
  assertEquals 'build with default build dir exit code' "${exit_code}" 0
}

setBuildDirOnRepeatBuild() {
  rm -r alt_build
  cmd_output=$(${1})
  exit_code=${?}
  assertContains 'set build dir on repeat build output' "${cmd_output}" 'Built target my-exec'
  assertTrue 'build with default build dir build dir' '[ -e build ]'
  assertTrue 'set build dir on repeat build build dir' '[ -e alt_build ]'
  assertTrue 'set build dir on repeat build main exec' '[ -e my-exec ]'
  assertEquals 'set build dir on repeat build exit code' "${exit_code}" 0
}

setBuildDirHelper() {
  setBuildDirOnFirstBuild "${1}"
  buildWithDefaultBuildDir "${1}"
  setBuildDirOnRepeatBuild "${1}"
}

################################################################################
# UNIT TESTS
################################################################################

setBuildDirShort() {
  setBuildDirHelper "./${EXEC_NAME} -d -b alt_build"
}

setBuildDirLong() {
  setBuildDirHelper "./${EXEC_NAME} -d --build-dir=alt_build"
}

################################################################################
# TEST SUITE
################################################################################

suite() {
  # shellcheck disable=SC2154
  if [ "${unit_test_function}" != ''  ] && [ "$( type -t "${unit_test_function}" )" = "function" ]; then
    suite_addTest "${unit_test_function}"
  else
    suite_addTest setBuildDirShort
    suite_addTest setBuildDirLong
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

