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

useGnuCompilerHelper() {
  cmd_output=$(${1} 2>&1)
  exit_code=${?}
  assertContains 'useGnuCompilerHelper compiler id' "${cmd_output}" 'The CXX compiler identification is GNU'
  assertNotContains 'useGnuCompilerHelper unused var warn' "${cmd_output}" 'Manually-specified variables were not used by the project'
  assertTrue 'useGnuCompilerHelper exec exists' '[ -e my-exec ]'
  assertEquals 'useGnuCompilerHelper exit code' "${exit_code}" 0
}

useLlvmCompilerHelper() {
  cmd_output=$(${1} 2>&1)
  exit_code=${?}
  assertContains 'useLlvmCompilerHelper compiler id' "${cmd_output}" 'The CXX compiler identification is Clang'
  assertNotContains 'useLlvmCompilerHelper unused var warn' "${cmd_output}" 'Manually-specified variables were not used by the project'
  assertTrue 'useLlvmCompilerHelper exec exists' '[ -e my-exec ]'
  assertEquals 'useLlvmCompilerHelper exit code' "${exit_code}" 0
}

################################################################################
# UNIT TESTS
################################################################################

useGnuCompilerShort() {
  useGnuCompilerHelper "./${EXEC_NAME} -dg"
}

useGnuCompilerLong() {
  useGnuCompilerHelper "./${EXEC_NAME} -d --use-gnu-compiler"
}

useLlvmCompilerShort() {
  useLlvmCompilerHelper "./${EXEC_NAME} -dl"
}

useLlvmCompilerLong() {
  useLlvmCompilerHelper "./${EXEC_NAME} -d --use-llvm-compiler"
}

################################################################################
# TEST SUITE
################################################################################

suite() {
  # shellcheck disable=SC2154
  if [ "${unit_test_function}" != ''  ] && [ "$( type -t "${unit_test_function}" )" = "function" ]; then
    suite_addTest "${unit_test_function}"
  else
    suite_addTest useGnuCompilerShort
    suite_addTest useGnuCompilerLong
    suite_addTest useLlvmCompilerShort
    suite_addTest useLlvmCompilerLong
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

