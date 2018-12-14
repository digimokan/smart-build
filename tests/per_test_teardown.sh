#!/bin/sh

tear_down() {
  cd ..
  rm -rf test_project
}

main() {
  tear_down
}

main

