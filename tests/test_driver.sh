#!/bin/sh

################################################################################
# SETUP / TEARDOWN
################################################################################

setUp() {
  mkdir test_project
  cp ../src/fd.sh ./test_project/
  cp -r ./test_codebase/* ./test_project/
  cd test_project || exit 1
}

tearDown() {
  cd ..
  rm -rf test_project
}

################################################################################
# HELP
################################################################################

helpHelper() {
  cmd_output=$(${1})
  exit_code=${?}
  assertContains 'Basic print-usage help has output -->' "${cmd_output}" 'USAGE'
  assertContains 'Basic print-usage help has output -->' "${cmd_output}" 'OPTIONS'
  assertEquals 'Basic print-usage help has correct exit code -->' "${exit_code}" 0
}

testHelpShort() {
  helpHelper './fd.sh -h'
}

testHelpLong() {
  helpHelper './fd.sh --help'
}

################################################################################
# TEMPLATE GENERATION
################################################################################

projectConfigGenHelper() {
  cmd_output=$(${1})
  assertNull 'Generate .project_config is silent -->' "${cmd_output}"
  assertTrue 'Generate .project_config does generate it' '[ -e .project_config ]'
  assertContains '.project_config has correct contents -->' "$(cat .project_config)" '# cmake project title'
  assertContains '.project_config has correct contents -->' "$(cat .project_config)" '# EOF: FILE MUST END WITH THIS LAST LINE'
  cmd_output=$(${1})
  exit_code=${?}
  assertContains 'Illegal overwrite .project_config has correct output -->' "${cmd_output}" '.project_config file already exists'
  assertEquals 'Illegal overwrite .project_config has correct exit code -->' "${exit_code}" 1
}

testProjectConfigGen() {
  projectConfigGenHelper './fd.sh -P'
}

testProjectConfigGenLong() {
  projectConfigGenHelper './fd.sh --generate-project-config'
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

. ../third_party/shunit2/shunit2

