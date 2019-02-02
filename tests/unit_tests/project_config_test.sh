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
}

tearDown() {
  # shellcheck source=../per_test_teardown.sh
  . ../../per_test_teardown.sh
}

################################################################################
# HELPER FUNCTIONS
################################################################################

alternateProjectConfigHelper() {
  writeConfigFiles
  cp .project_config .alt_project_config
  sed -i '18s/.*/alt-exec/' .alt_project_config
  sed -i '26s/.*/alt-test-driver/' .alt_project_config
  cmd_output=$(${1})
  exit_code=${?}
  assertFalse 'alternateProjectConfigHelper exec exists' '[ -e my-exec ]'
  assertFalse 'alternateProjectConfigHelper test-driver exists' '[ -e my-test-driver ]'
  assertTrue 'alternateProjectConfigHelper alt-exec exists' '[ -e alt-exec ]'
  assertTrue 'alternateProjectConfigHelper alt-test-driver exists' '[ -e alt-test-driver ]'
  assertContains 'alternateProjectConfigHelper unit tests' "${cmd_output}" '[doctest] Status: SUCCESS!'
  assertNotContains 'alternateProjectConfigHelper ctest' "${cmd_output}" '% tests passed, '
  assertEquals 'alternateProjectConfigHelper exit code' "${exit_code}" 0
}

writeConfigFiles() {
  ./${EXEC_NAME} --generate-project-config --generate-cmakelists
}

################################################################################
# UNIT TESTS
################################################################################

missingProjectConfig() {
  cmd_output=$(./${EXEC_NAME})
  exit_code=${?}
  assertContains 'missingProjectConfig output' "${cmd_output}" 'could not open project config file ".project_config"'
  assertEquals 'missingProjectConfig exit code' "${exit_code}" 1
}

basicProjectConfigBuildsAndTests() {
  writeConfigFiles
  cmd_output=$(./${EXEC_NAME} --build-type-debug --make-and-run-tests)
  exit_code=${?}
  assertTrue 'basicProjectConfigBuildsAndTests exec exists' '[ -e my-exec ]'
  assertTrue 'basicProjectConfigBuildsAndTests test driver exists' '[ -e my-test-driver ]'
  assertContains 'basicProjectConfigBuildsAndTests unit tests' "${cmd_output}" '[doctest] Status: SUCCESS!'
  assertNotContains 'basicProjectConfigBuildsAndTests ctest' "${cmd_output}" '% tests passed, '
  assertEquals 'basicProjectConfigBuildsAndTests exit code' "${exit_code}" 0
}

alternateProjectConfigShort() {
  alternateProjectConfigHelper "./${EXEC_NAME} -dt -p .alt_project_config"
}

alternateProjectConfigLong() {
  alternateProjectConfigHelper "./${EXEC_NAME} -dt --project-config-file=.alt_project_config"
}

################################################################################
# TEST SUITE
################################################################################

suite() {
  # shellcheck disable=SC2154
  if [ "${unit_test_function}" != ''  ] && [ "$( type -t "${unit_test_function}" )" = "function" ]; then
    suite_addTest "${unit_test_function}"
  else
    suite_addTest missingProjectConfig
    suite_addTest basicProjectConfigBuildsAndTests
    suite_addTest alternateProjectConfigShort
    suite_addTest alternateProjectConfigLong
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

