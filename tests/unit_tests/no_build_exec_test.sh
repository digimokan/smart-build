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
  assertContains 'noBuildExecFromConfigFileWithTests unit tests' "${cmd_output}" '[doctest] Status: SUCCESS!'
  assertNotContains 'noBuildExecFromConfigFileWithTests ctest' "${cmd_output}" '% tests passed, '
  assertTrue 'noBuildExecFromConfigFileWithTests exec' '[ ! -e my-exec ]'
  assertTrue 'noBuildExecFromConfigFileWithTests test driver' '[ -e my-test-driver ]'
  assertEquals 'noBuildExecFromConfigFileWithTests exit code' "${exit_code}" 0
}

noBuildExecFromConfigFileWithoutTests() {
  sed -i '16s/.*/-/' .project_config
  sed -i '18s/.*/-/' .project_config
  cmd_output=$(./${EXEC_NAME} -d)
  exit_code=${?}
  assertContains 'noBuildExecFromConfigFileWithoutTests output' "${cmd_output}" 'Built target user_lib'
  assertTrue 'noBuildExecFromConfigFileWithoutTests exec' '[ ! -e my-exec ]'
  assertTrue 'noBuildExecFromConfigFileWithoutTests test driver' '[ ! -e my-test-driver ]'
  assertEquals 'noBuildExecFromConfigFileWithoutTests exit code' "${exit_code}" 0
}

noBuildExecFromConfigFileAndCmdOpt() {
  sed -i '16s/.*/-/' .project_config
  sed -i '18s/.*/-/' .project_config
  cmd_output=$(./${EXEC_NAME} -dE)
  exit_code=${?}
  assertContains 'noBuildExecFromConfigFileAndCmdOpt output' "${cmd_output}" 'Built target user_lib'
  assertTrue 'noBuildExecFromConfigFileAndCmdOpt exec' '[ ! -e my-exec ]'
  assertTrue 'noBuildExecFromConfigFileAndCmdOpt test driver' '[ ! -e my-test-driver ]'
  assertEquals 'noBuildExecFromConfigFileAndCmdOpt exit code' "${exit_code}" 0
}

noBuildExecFromConfigFileBadInput() {
  sed -i '18s/.*/-/' .project_config
  cmd_output=$(./${EXEC_NAME} -d)
  exit_code=${?}
  assertContains 'noBuildExecFromConfigFileBadInput output' "${cmd_output}" 'main executable source file specified, but exec name missing'
  assertTrue 'noBuildExecFromConfigFileBadInput exec' '[ ! -e my-exec ]'
  assertTrue 'noBuildExecFromConfigFileBadInput test driver' '[ ! -e my-test-driver ]'
  assertEquals 'noBuildExecFromConfigFileBadInput exit code' "${exit_code}" 1
}

noBuildExecFromCmdOptShort() {
  cmd_output=$(./${EXEC_NAME} -d -E)
  exit_code=${?}
  assertContains 'noBuildExecFromCmdOptShort output' "${cmd_output}" 'Built target user_lib'
  assertTrue 'noBuildExecFromCmdOptShort exec' '[ ! -e my-exec ]'
  assertTrue 'noBuildExecFromCmdOptShort test driver' '[ ! -e my-test-driver ]'
  assertEquals 'noBuildExecFromCmdOptShort exit code' "${exit_code}" 0
}

noBuildExecFromCmdOptLong() {
  cmd_output=$(./${EXEC_NAME} -d --no-build-executable)
  exit_code=${?}
  assertContains 'noBuildExecFromCmdOptLong output' "${cmd_output}" 'Built target user_lib'
  assertTrue 'noBuildExecFromCmdOptLong exec' '[ ! -e my-exec ]'
  assertTrue 'noBuildExecFromCmdOptLong test driver' '[ ! -e my-test-driver ]'
  assertEquals 'noBuildExecFromCmdOptLong exit code' "${exit_code}" 0
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

