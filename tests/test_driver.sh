#!/bin/sh

../third_party/shunit-test-handler/shunit_test_handler.sh \
  --test-shells="/bin/bash /bin/mksh /bin/dash /bin/zsh" \
  ../third_party/shlib ./unit_tests

