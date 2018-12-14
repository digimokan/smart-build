#!/bin/sh

#shellcheck source=../../src
PATH_TO_SRC_DIR='../../src'
#shellcheck source=../../tests
PATH_TO_TESTS_DIR='../../tests'
EXEC_NAME='fd.sh'

set_up() {
  mkdir test_project
  cp "${PATH_TO_SRC_DIR}/${EXEC_NAME}" ./test_project/
  cp -r ${PATH_TO_TESTS_DIR}/test_codebase/* ./test_project/
  cd test_project || exit 1
}

main() {
  set_up
}

main

