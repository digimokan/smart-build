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

noBuildExecFromConfigFileWithTests() {
  sed -i '16s/.*/-/' .project_config
  sed -i '18s/.*/-/' .project_config
  cmd_output=$(./${EXEC_NAME} -dt)
  exit_code=${?}
  assertContains 'no-build-exec from config file with tests output' "${cmd_output}" '100% tests passed, 0 tests failed'
  assertTrue 'no-build-exec from config file with tests exec' '[ ! -e my-exec ]'
  assertTrue 'no-build-exec from config file with tests test driver' '[ -e my-test-driver ]'
  assertEquals 'no-build-exec from config file with tests exit code' "${exit_code}" 0
}

noBuildExecFromConfigFileWithoutTests() {
  sed -i '16s/.*/-/' .project_config
  sed -i '18s/.*/-/' .project_config
  cmd_output=$(./${EXEC_NAME} -d)
  exit_code=${?}
  assertContains 'no-build-exec from config file without tests output' "${cmd_output}" 'Built target user_lib'
  assertTrue 'no-build-exec from config file without tests exec' '[ ! -e my-exec ]'
  assertTrue 'no-build-exec from config file without tests test driver' '[ ! -e my-test-driver ]'
  assertEquals 'no-build-exec from config file without tests exit code' "${exit_code}" 0
}

noBuildExecFromConfigFileAndCmdOpt() {
  sed -i '16s/.*/-/' .project_config
  sed -i '18s/.*/-/' .project_config
  cmd_output=$(./${EXEC_NAME} -dE)
  exit_code=${?}
  assertContains 'no-build-exec from config file and cmd opt output' "${cmd_output}" 'Built target user_lib'
  assertTrue 'no-build-exec from config file and cmd opt exec' '[ ! -e my-exec ]'
  assertTrue 'no-build-exec from config file and cmd opt test driver' '[ ! -e my-test-driver ]'
  assertEquals 'no-build-exec from config file and cmd opt exit code' "${exit_code}" 0
}

noBuildExecFromConfigFileBadInput() {
  sed -i '18s/.*/-/' .project_config
  cmd_output=$(./${EXEC_NAME} -d)
  exit_code=${?}
  assertContains 'no-build-exec from config file bad input output' "${cmd_output}" 'main executable source file specified, but exec name missing'
  assertTrue 'no-build-exec from config file bad input exec' '[ ! -e my-exec ]'
  assertTrue 'no-build-exec from config file bad input test driver' '[ ! -e my-test-driver ]'
  assertEquals 'no-build-exec from config file bad input exit code' "${exit_code}" 2
}

noBuildExecFromCmdOptShort() {
  cmd_output=$(./${EXEC_NAME} -d -E)
  exit_code=${?}
  assertContains 'no-build-exec from cmd opt short output' "${cmd_output}" 'Built target user_lib'
  assertTrue 'no-build-exec from cmd opt short exec' '[ ! -e my-exec ]'
  assertTrue 'no-build-exec from cmd opt short test driver' '[ ! -e my-test-driver ]'
  assertEquals 'no-build-exec from cmd opt short exit code' "${exit_code}" 0
}

noBuildExecFromCmdOptLong() {
  cmd_output=$(./${EXEC_NAME} -d --no-build-executable)
  exit_code=${?}
  assertContains 'no-build-exec from cmd opt long output' "${cmd_output}" 'Built target user_lib'
  assertTrue 'no-build-exec from cmd opt long exec' '[ ! -e my-exec ]'
  assertTrue 'no-build-exec from cmd opt long test driver' '[ ! -e my-test-driver ]'
  assertEquals 'no-build-exec from cmd opt long exit code' "${exit_code}" 0
}

################################################################################
# TEST SUITE
################################################################################

suite() {
  # shellcheck disable=SC2154
  if [ "${unit_test_function}" != ''  ] && [ "$( type -t "${unit_test_function}" )" = "function" ]; then
    suite_addTest "${unit_test_function}"
  else
    suite_addTest noBuildExecFromConfigFileWithTests
    suite_addTest noBuildExecFromConfigFileWithoutTests
    suite_addTest noBuildExecFromConfigFileAndCmdOpt
    suite_addTest noBuildExecFromConfigFileBadInput
    suite_addTest noBuildExecFromCmdOptShort
    suite_addTest noBuildExecFromCmdOptLong
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

