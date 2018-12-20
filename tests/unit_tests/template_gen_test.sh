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

projectConfigGenHelper() {
  cmd_output=$(${1})
  assertNull 'Generate .project_config is silent -->' "${cmd_output}"
  assertTrue 'Generate .project_config does generate it' '[ -e .project_config ]'
  assertContains '.project_config has correct contents -->' "$(head -n 1 .project_config)" '# cmake project title'
  assertContains '.project_config has correct contents -->' "$(tail -n 1 .project_config)" '# EOF: FILE MUST END WITH THIS LAST LINE'
  cmd_output=$(${1})
  exit_code=${?}
  assertContains 'Illegal overwrite .project_config has correct output -->' "${cmd_output}" '.project_config file already exists'
  assertEquals 'Illegal overwrite .project_config has correct exit code -->' "${exit_code}" 1
}

cmakeListsGenHelper() {
  cmd_output=$(${1})
  assertNull 'Generate CMakeLists.txt is silent -->' "${cmd_output}"
  assertTrue 'Generate CMakeLists.txt does generate it' '[ -e CMakeLists.txt ]'
  assertContains 'CMakeLists.txt has correct contents -->' "$(sed -n '2p' CMakeLists.txt)" '# REQUIRED COMMAND-LINE INPUTS'
  assertContains 'CMakeLists.txt has correct contents -->' "$(tail -n 4 CMakeLists.txt)" "include_dir_and_recurse_subdirs(\${testing_source_dirs})"
  assertContains 'CMakeLists.txt has correct contents -->' "$(tail -n 2 CMakeLists.txt)" "endif()"
  cmd_output=$(${1})
  exit_code=${?}
  assertContains 'Illegal overwrite CMakeLists.txt has correct output -->' "${cmd_output}" 'CMakeLists.txt file already exists'
  assertEquals 'Illegal overwrite CMakeLists.txt has correct exit code -->' "${exit_code}" 1
}

################################################################################
# UNIT TESTS
################################################################################

projectConfigGenShort() {
  projectConfigGenHelper "./${EXEC_NAME} -P"
}

projectConfigGenLong() {
  projectConfigGenHelper "./${EXEC_NAME} --generate-project-config"
}

cmakeListsGenShort() {
  cmakeListsGenHelper "./${EXEC_NAME} -L"
}

cmakeListsGenLong() {
  cmakeListsGenHelper "./${EXEC_NAME} --generate-cmakelists"
}

################################################################################
# TEST SUITE
################################################################################

suite() {
  # shellcheck disable=SC2154
  if [ "${unit_test_function}" != ''  ] && [ "$( type -t "${unit_test_function}" )" = "function" ]; then
    suite_addTest "${unit_test_function}"
  else
    suite_addTest projectConfigGenShort
    suite_addTest projectConfigGenLong
    suite_addTest cmakeListsGenShort
    suite_addTest cmakeListsGenLong
  fi
}

################################################################################
# BAD INVOCATION
################################################################################

# testMissingAllOptions() {
#   cmd_output=$(./test_project/fd.sh)
#   assertContains 'no options provided -->' "${cmd_output}" "USAGE"
#   assertContains 'Basic print-usage help -->' "${cmd_output}" "OPTIONS"
# }

################################################################################
# LOAD TEST FRAMEWORK (MUST GO LAST)
################################################################################

# zsh compatibility options
export SHUNIT_PARENT=$0
setopt shwordsplit
# shellcheck disable=SC1091
. "${PATH_TO_SHUNIT}"

