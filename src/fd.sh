#!/bin/sh

################################################################################
# script:   build.sh
# author:   digimokan
# date:     10 AUG 2017 (created)
# purpose:  automate simple CMake out-of-source builds
# inputs:   specially-formatted .project_config file
# usage:    see below usage() function
################################################################################

build_type='uninitialized'            # release, debug, etc.
build_testing='uninitialized'         # build tests (on/off)
executable_name='uninitialized'       # name of program main executable
main_executable_src='uninitialized'   # name of src file with main exec code
test_driver_name='uninitialized'      # name of test driver executable
project_config_file='.project_config' # read build-dir, executable names
build_dir='build'                     # out-of-source cmake build dir
clean='none'                          # clean executables and/or cmake cache
tests='none'                          # make and/or run test driver
quiet_mode='off'                      # silence all output except errors
generate_new_project_config='false'   # gen new .project_config file

print_usage() {
  echo 'USAGE:'
  echo "  $(basename "${0}")  -h"
  echo "  $(basename "${0}")  -c|-C  [-b <dir>]  [-p <file>]  [-e <file>]"
  echo '            [-x <file>]  [-q]'
  echo "  $(basename "${0}")  -d|-r|-w|-m  [-c|-C]  [-t|-T]  [-b <dir>]"
  echo '            [-p <file>]  [-e <file>|-E]  [-x <file>]  [-q]'
  echo "  $(basename "${0}")  -P  [-L|-V]"
  echo 'OPTIONS:'
  echo '  -h, --help'
  echo '      print this help message'
  echo '  -d, --build-type-debug'
  echo '      compile and link with debug symbols'
  echo '  -r, --build-type-release'
  echo '      compile and link release'
  echo '  -w, --build-type-release-with-debug'
  echo '      compile and link release with debug symbols'
  echo '  -m, --build-type-release-min-max'
  echo '      compile and link release for min-size, max-speed'
  echo '  -c, --clean-all'
  echo '      remove built program/testing executables and build dir'
  echo '  -C, --clean-executables'
  echo '      remove built program/testing executables'
  echo '  -t, --make-and-run-tests'
  echo '      make and run tests'
  echo '  -T, --make-tests'
  echo '      make tests'
  echo '  -b <dir>, --build-dir=<dir>'
  echo '      specify build dir (default is "build")'
  echo '  -p <file>, --project-config-file=<file>'
  echo '      specify project config file (default is ".project_config")'
  echo '  -e <file>, --executable-name=<file>'
  echo '      specify program executable to build (override config file)'
  echo '  -E, --no-build-executable'
  echo '      do not build program executable (override config file)'
  echo '  -x <file>, --test-driver-name=<file>'
  echo '      specify test-driver executable to build (override config file)'
  echo '  -P, --generate-project-config'
  echo '      generate template .project_config file'
  echo '  -q, --quiet-mode'
  echo '      quiet mode'
  exit "${1}"
}

print_error_msg() {
  echo 'ERROR:'
  printf "$(basename "${0}"): %s\\n\\n" "${1}"
  print_usage "${2}"
}

get_cmd_opts_and_args() {
  while getopts ':hdrwmcCtTb:p:e:Ex:Pq-:' option; do
    case "${option}" in
      h)  handle_help ;;
      d)  handle_build_type_debug ;;
      r)  handle_build_type_release ;;
      w)  handle_build_type_release_with_debug ;;
      m)  handle_build_type_release_min_max ;;
      c)  handle_clean_all ;;
      C)  handle_clean_execs ;;
      t)  handle_make_and_run_tests ;;
      T)  handle_make_tests ;;
      b)  handle_build_dir "${OPTARG}" ;;
      p)  handle_project_config_file "${OPTARG}" ;;
      e)  handle_executable_name "${OPTARG}" ;;
      E)  handle_no_build_executable ;;
      x)  handle_test_driver_name "${OPTARG}" ;;
      P)  handle_generate_project_config ;;
      q)  handle_quiet_mode ;;
      -)  LONG_OPTARG="${OPTARG#*=}"
          case ${OPTARG} in
            help)                   handle_help ;;
            help=*)                 handle_illegal_option_arg "${OPTARG}" ;;
            build-type-debug)       handle_build_type_debug ;;
            build-type-debug=*)     handle_illegal_option_arg "${OPTARG}" ;;
            build-type-release)     handle_build_type_release ;;
            build-type-release=*)   handle_illegal_option_arg "${OPTARG}" ;;
            build-type-release-with-debug)    handle_build_type_release_with_debug ;;
            build-type-release-with-debug=*)  handle_illegal_option_arg "${OPTARG}" ;;
            build-type-release-min-max)       handle_build_type_release_min_max ;;
            build-type-release-min-max=*)     handle_illegal_option_arg "${OPTARG}" ;;
            clean-all)              handle_clean_all ;;
            clean-all=*)            handle_illegal_option_arg "${OPTARG}" ;;
            clean-executables)      handle_clean_execs ;;
            clean-executables=*)    handle_illegal_option_arg "${OPTARG}" ;;
            make-and-run-tests)     handle_make_and_run_tests ;;
            make-and-run-tests=*)   handle_illegal_option_arg "${OPTARG}" ;;
            make-tests)             handle_make_tests ;;
            make-tests=*)           handle_illegal_option_arg "${OPTARG}" ;;
            build-dir=?*)           handle_build_dir "${LONG_OPTARG}" ;;
            build-dir*)             handle_missing_option_arg "${OPTARG}" ;;
            project-config-file=?*) handle_project_config_file "${LONG_OPTARG}" ;;
            project-config-file*)   handle_missing_option_arg "${OPTARG}" ;;
            executable-name=?*)     handle_executable_name "${LONG_OPTARG}" ;;
            executable-name*)       handle_missing_option_arg "${OPTARG}" ;;
            no-build-executable)    handle_no_build_executable ;;
            no-build-executable=*)  handle_illegal_option_arg "${OPTARG}" ;;
            test-driver-name=?*)    handle_test_driver_name "${LONG_OPTARG}" ;;
            test-driver-name*)      handle_missing_option_arg "${OPTARG}" ;;
            generate-project-config)          handle_generate_project_config ;;
            generate-project-config=*)        handle_illegal_option_arg "${OPTARG}" ;;
            quiet-mode)             handle_quiet_mode ;;
            quiet-mode=*)           handle_illegal_option_arg "${OPTARG}" ;;
            '')                     break ;; # non-option arg starting with '-'
            *)                      handle_unknown_option "${OPTARG}" ;;
          esac ;;
      \?) handle_unknown_option "${OPTARG}" ;;
    esac
  done
}

handle_help() {
  print_usage 0
}

handle_build_type_debug() {
  build_type='Debug'
}

handle_build_type_release() {
  build_type='Release'
}

handle_build_type_release_with_debug() {
  build_type='RelWithDebInfo'
}

handle_build_type_release_min_max() {
  build_type='MinSizeRel'
}

handle_make_and_run_tests() {
  tests='make_and_run_tests'
}

handle_make_tests() {
  tests='make_tests'
}

handle_clean_all() {
  clean='execs_and_build_dir'
}

handle_clean_execs() {
  clean='execs'
}

handle_build_dir() {
  build_dir="${1}"
}

handle_project_config_file() {
  project_config_file="${1}"
}

handle_executable_name() {
  if [ "${executable_name}" != 'uninitialized' ]; then
    err_msg="options \"-e\" and \"-E\" are mutually exclusive"
    print_error_msg "${err_msg}" 1
  fi
  executable_name="${1}"
}

handle_no_build_executable() {
  if [ "${executable_name}" != 'uninitialized' ]; then
    err_msg="options \"-e\" and \"-E\" are mutually exclusive"
    print_error_msg "${err_msg}" 1
  fi
  main_executable_src='-'
  executable_name='-'
}

handle_test_driver_name() {
  test_driver_name="${1}"
}

handle_quiet_mode() {
  quiet_mode='on'
}

handle_generate_project_config() {
  generate_new_project_config='true'
}

handle_unknown_option() {
  err_msg="unknown option \"${1}\""
  print_error_msg "${err_msg}" 1
}

handle_illegal_option_arg() {
  err_msg="illegal argument in \"${1}\""
  print_error_msg "${err_msg}" 1
}

handle_missing_option_arg() {
  err_msg="missing argument for option \"${1}\""
  print_error_msg "${err_msg}" 1
}

generate_project_config() {
  if [ -e '.project_config' ]; then
    err_msg=".project_config file already exists"
    print_error_msg "${err_msg}" 1
  fi
  cat <<- 'EOF' > .project_config
# cmake project title
my-project
# cmake min version required
3.12
# language type:"C" or "CPP"
CPP
# language standard
17
# defs and system-include standards: space-separated, "-" if empty
-DGNU_SOURCE -_LARGEFILE64_SOURCE
# warning levels: space-separated, "-" if empty
-Wall -Wno-unused
# top-level src dirs: colon-separated
src:third_party
# src file with main-executable code: "-" if none, i.e. test only
src/main.cpp
# main executable file to build: "-" if none, i.e. test only
my-exec
# testing language type: "C" or "CPP" (N/A if building without -t/-T)
CPP
# testing language standard (N/A if building without -t/-T)
17
# testing top-level src dirs: colon-separated, "-" if none
unit-tests:more-unit-tests
# test-driver executable to build (N/A if building without -t/-T)
my-test-driver
# EOF: FILE MUST END WITH THIS LAST LINE
EOF
}

generate_new_setup_files() {
  setup_file_generated='false'
  if [ "${generate_new_project_config}" = 'true' ]; then
    generate_project_config
    setup_file_generated='true'
  fi
  if [ "${setup_file_generated}" = 'true' ]; then
    exit 0
  fi
}

load_settings_from_project_config() {
  if [ ! -e "${project_config_file}" ]; then
    err_msg="could not open project config file \"${project_config_file}\""
    print_error_msg "${err_msg}" 1
  fi
  if [ "${executable_name}" = 'uninitialized' ]; then
    executable_name=$(sed -n '18p' "${project_config_file}")
  fi
  if [ "${main_executable_src}" = 'uninitialized' ]; then
    main_executable_src=$(sed -n '16p' "${project_config_file}")
  fi
  if [ "${test_driver_name}" = 'uninitialized' ]; then
    test_driver_name=$(sed -n '26p' "${project_config_file}")
  fi
}

clean_execs() {
  [ -e "${executable_name}" ] && rm -rf "${executable_name}"
  [ -e "${test_driver_name}" ] && rm -rf "${test_driver_name}"
}

clean_cache() {
  [ -d "${build_dir}" ] && rm -rf "${build_dir}"
}

clean_project() {
  if [ "${clean}" = 'execs' ]; then
    clean_execs
  elif [ "${clean}" = 'execs_and_build_dir' ]; then
    clean_execs
    clean_cache
  fi
}

check_build_type() {
  if [ "${build_type}" = 'uninitialized' ] && [ "${clean}" = 'none' ]; then
    print_error_msg "no build type set with -d|-r|-w|-m" 2
  elif [ "${build_type}" = 'uninitialized' ] && [ "${clean}" != 'none' ]; then
    exit 0
  fi
}

create_and_switch_to_build_dir() {
  mkdir -p "${build_dir}"
  cd "${build_dir}" || exit
}

build_project() {
  cmake \
    -DCMAKE_BUILD_TYPE="${build_type}" \
    -DBUILD_TESTING="${build_testing}" \
    -Dproject_config_file="${project_config_file}" \
    -Dproject_source_main_exec="${main_executable_src}" \
    "$([ "${main_executable_src}" != '-' ] && printf "%s%s" "-Dproject_main_exec_to_build=" "${executable_name}" || echo '')" \
    "$([ "${build_testing}" = 'ON' ] && printf "%s%s" "-Dtesting_exec_to_build=" "${test_driver_name}" || echo '')" \
    ..
  cmake --build .
}

check_main_exec() {
  if [ "${executable_name}" = '-' ] && [ "${main_executable_src}" != '-' ]; then
    print_error_msg "main executable source file specified, but exec name missing" 2
  fi
}

check_tests() {
  if [ "${tests}" = 'none' ]; then
    build_testing='OFF'
  else
    build_testing='ON'
  fi
}

run_tests() {
  if [ "${tests}" = 'make_and_run_tests' ]; then
    ctest
  fi
}

move_execs() {
  [ -e "${executable_name}" ] && mv "${executable_name}" ..
  [ -e "${test_driver_name}" ] && mv "${test_driver_name}" ..
}

build_and_test() {
  generate_new_setup_files
  load_settings_from_project_config
  clean_project
  check_build_type
  check_main_exec
  check_tests
  create_and_switch_to_build_dir
  build_project
  run_tests
  move_execs
}

main() {
  get_cmd_opts_and_args "$@"
  if [ "${quiet_mode}" = 'on' ]; then
    build_and_test "$@" > /dev/null
  else
    build_and_test "$@"
  fi
  exit 0
}

main "$@"

