#!/bin/sh

build_type='uninitialized'            # release, debug, etc.
build_testing='uninitialized'         # build tests (on/off)
executable_name='uninitialized'       # name of program main executable
main_executable_src='uninitialized'   # name of src file with main exec code
test_driver_name='uninitialized'      # name of test driver executable
compiler_type='default'               # compiler to use (default/gnu/llvm/etc)
compiler_c='none'                     # c compiler (non-default compiler_type)
compiler_cpp='none'                   # cpp compiler (non-default compiler_type)
project_config_file='.project_config' # read build-dir, executable names
build_dir='build'                     # out-of-source cmake build dir
clean='none'                          # clean executables and/or cmake cache
tests='none'                          # make and/or run test driver
quiet_mode='off'                      # silence all output except errors
generate_new_project_config='false'   # gen new .project_config file
generate_new_cmakelists='false'       # gen new CMakeLists.txt file
generate_new_vimrc='false'            # gen new .vimrc file

print_usage() {
  echo 'USAGE:'
  echo "  $(basename "${0}")  -h"
  echo "  $(basename "${0}")  -c|-C  [-b <dir>]  [-p <file>]  [-e <file>]"
  echo '            [-x <file>]  [-q]'
  echo "  $(basename "${0}")  -d|-r|-w|-m  [-c|-C]  [-g|-l]  [-t|-T]"
  echo '            [-b <dir>]  [-p <file>]  [-e <file>|-E]  [-x <file>]  [-q]'
  echo "  $(basename "${0}")  -P  [-L]  [-V]"
  echo "  $(basename "${0}")  -L  [-P]  [-V]"
  echo "  $(basename "${0}")  -V  [-P]  [-L]"
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
  echo '  -g, --use-gnu-compiler'
  echo '      use GNU gcc/g++ compiler and linker'
  echo '  -l, --use-llvm-compiler'
  echo '      use LLVM clang/clang++ compiler and linker'
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
  echo '  -L, --generate-cmakelists'
  echo '      generate template CMakeLists.txt file'
  echo '  -V, --generate-vimrc'
  echo '      generate template .vimrc file'
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
  while getopts ':hdrwmcCgltTb:p:e:Ex:PLVq-:' option; do
    case "${option}" in
      h)  handle_help ;;
      d)  handle_build_type_debug ;;
      r)  handle_build_type_release ;;
      w)  handle_build_type_release_with_debug ;;
      m)  handle_build_type_release_min_max ;;
      c)  handle_clean_all ;;
      C)  handle_clean_execs ;;
      g)  handle_use_gnu_compiler ;;
      l)  handle_use_llvm_compiler ;;
      t)  handle_make_and_run_tests ;;
      T)  handle_make_tests ;;
      b)  handle_build_dir "${OPTARG}" ;;
      p)  handle_project_config_file "${OPTARG}" ;;
      e)  handle_executable_name "${OPTARG}" ;;
      E)  handle_no_build_executable ;;
      x)  handle_test_driver_name "${OPTARG}" ;;
      P)  handle_generate_project_config ;;
      L)  handle_generate_cmakelists ;;
      V)  handle_generate_vimrc ;;
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
            use-gnu-compiler)       handle_use_gnu_compiler ;;
            use-gnu-compiler=*)     handle_illegal_option_arg "${OPTARG}" ;;
            use-llvm-compiler)      handle_use_llvm_compiler ;;
            use-llvm-compiler=*)    handle_illegal_option_arg "${OPTARG}" ;;
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
            generate-cmakelists)    handle_generate_cmakelists ;;
            generate-cmakelists=*)  handle_illegal_option_arg "${OPTARG}" ;;
            generate-vimrc)         handle_generate_vimrc ;;
            generate-vimrc=*)       handle_illegal_option_arg "${OPTARG}" ;;
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

handle_use_gnu_compiler() {
  compiler_type='gnu'
  compiler_c='gcc'
  compiler_cpp='g++'
}

handle_use_llvm_compiler() {
  compiler_type='llvm'
  compiler_c='clang'
  compiler_cpp='clang++'
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

handle_generate_cmakelists() {
  generate_new_cmakelists='true'
}

handle_generate_vimrc() {
  generate_new_vimrc='true'
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
3.0.2
# language type:"C" or "CPP"
CPP
# language standard
17
# defs and system-include standards: space-separated, "-" if empty
-DGNU_SOURCE -D_LARGEFILE64_SOURCE
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
tests
# test-driver executable to build (N/A if building without -t/-T)
my-test-driver
# EOF: FILE MUST END WITH THIS LAST LINE
EOF
}

generate_cmakelists() {
  if [ -e 'CMakeLists.txt' ]; then
    err_msg="CMakeLists.txt file already exists"
    print_error_msg "${err_msg}" 1
  fi
  cat <<- 'EOF' > CMakeLists.txt
################################################################################
# REQUIRED COMMAND-LINE INPUTS
#   1) -DBUILD_TESTING=[ON/OFF]
#   2) -DCMAKE_BUILD_TYPE=[Debug/Release/RelWithDebInfo/MinSizeRel]
#   3) -Dproject_config_file=[relative/path/to/config_settings_file]
#   4) -Dproject_source_main_exec=[source_file_name]
# OPTIONAL COMMAND-LINE INPUTS
#   1) -Dproject_main_exec_to_build=[executable_name]
#   2) -Dtesting_exec_to_build=[executable_name]
################################################################################

################################################################################
# MACROS / FUNCTIONS
################################################################################

function(include_dir_and_recurse_subdirs)
  foreach(arg IN LISTS ARGN)
    include_directories("${arg}")
    file(GLOB_RECURSE subdir_list LIST_DIRECTORIES true RELATIVE "${PROJECT_SOURCE_DIR}/" CONFIGURE_DEPENDS "${arg}/*")
    foreach(sdir ${subdir_list})
      if(IS_DIRECTORY "${PROJECT_SOURCE_DIR}/${sdir}")
        include_directories("${sdir}")
      endif()
    endforeach()
  endforeach()
endfunction()

function(collect_source_files_recursively out_sources)
  set(collected_sources "")
  foreach(arg IN LISTS ARGN)
    file(GLOB_RECURSE src CONFIGURE_DEPENDS "${arg}/*.c" "${arg}/*.cpp" "${arg}/*.hxx")
    list(APPEND collected_sources ${src})
  endforeach()
  set(${out_sources} ${collected_sources} PARENT_SCOPE)
endfunction()

function(convert_lang_type_field out_lang_type)
  if(${${out_lang_type}} STREQUAL "C")
    set(out_lang_type "C" PARENT_SCOPE)
  elseif(${${out_lang_type}} STREQUAL "CPP")
    set(${out_lang_type} "CXX" PARENT_SCOPE)
  else()
    message(FATAL_ERROR "Reading from project config file: unable to read/convert project_language_type")
  endif()
endfunction()

function(read_config_list_field out_field out_config_list)
  list(REMOVE_AT ${out_config_list} 0)
  list(GET ${out_config_list} 0 line)
  list(FIND ARGN "field_is_list" index)
  if(${index} GREATER -1)
    string(REPLACE ":" ";" line "${line}")
  endif()
  list(FIND ARGN "field_is_optional" index)
  if((${index} GREATER -1) AND ("${line}" STREQUAL "-"))
    set(line "")
  endif()
  list(FIND ARGN "field_is_lang_type" index)
  if(${index} GREATER -1)
    convert_lang_type_field(line)
  endif()
  set(${out_field} "${line}" PARENT_SCOPE)
  list(REMOVE_AT ${out_config_list} 0)
  set(${out_config_list} ${${out_config_list}} PARENT_SCOPE)
endfunction()

function(skip_config_list_field out_config_list)
  list(REMOVE_AT ${out_config_list} 0)
  list(REMOVE_AT ${out_config_list} 0)
  set(${out_config_list} ${${out_config_list}} PARENT_SCOPE)
endfunction()

################################################################################
# READ SETTINGS FROM PROJECT CONFIG FILE
################################################################################

set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${project_config_file}")
file(STRINGS "${project_config_file}" project_config_list)
read_config_list_field(project_cmake_title project_config_list)
read_config_list_field(project_cmake_version_req project_config_list)
read_config_list_field(project_language_type project_config_list "field_is_lang_type")
read_config_list_field(project_language_standard project_config_list)
read_config_list_field(project_include_standards project_config_list "field_is_optional")
read_config_list_field(project_warning_levels project_config_list "field_is_optional")
read_config_list_field(project_source_dirs project_config_list "field_is_list")
skip_config_list_field(project_config_list)
skip_config_list_field(project_config_list)
read_config_list_field(testing_language_type project_config_list "field_is_lang_type")
read_config_list_field(testing_language_standard project_config_list)
read_config_list_field(testing_source_dirs project_config_list "field_is_list")
skip_config_list_field(project_config_list)

################################################################################
# CMAKE VERSION REQUIRED
################################################################################

cmake_minimum_required(VERSION "${project_cmake_version_req}")

################################################################################
# MAIN PROJECT DEF
################################################################################

project("${project_cmake_title}" NONE)

################################################################################
# CMAKE LANGUAGE SUPPORT CHECK
################################################################################

enable_language("${project_language_type}")

################################################################################
# SOURCE FILE GROUPS
################################################################################

# project sources
set(project_sources "")
collect_source_files_recursively(project_sources ${project_source_dirs})

################################################################################
# EXECUTABLES TO BUILD
################################################################################

if(NOT "${project_source_main_exec}" STREQUAL "-")
  # project main entry point source
  set(project_main_source "${project_source_main_exec}")

  # executable file to produce for main source
  add_executable("${project_main_exec_to_build}" "${project_source_main_exec}")

  # remove main source from project_sources
  list(REMOVE_ITEM project_sources "${CMAKE_CURRENT_SOURCE_DIR}/${project_source_main_exec}")
endif()

################################################################################
# USER LIB (ALL NON-MAIN SOURCES COLLECTED INTO ONE LIB)
################################################################################

add_library(user_lib ${project_sources})

################################################################################
# LINK LIBS --> EXECUTABLES
################################################################################

if(NOT "${project_source_main_exec}" STREQUAL "-")
  target_link_libraries("${project_main_exec_to_build}" PRIVATE user_lib)
endif()

################################################################################
# COMPILER OPTIONS
################################################################################

# warnings: enable most warnings
add_definitions("${project_warning_levels}")

################################################################################
# SOURCE CONFIG
################################################################################

# set project-wide language standards
if(NOT "${project_source_main_exec}" STREQUAL "-")
  set_target_properties("${project_main_exec_to_build}" PROPERTIES ${project_language_type}_STANDARD ${project_language_standard} ${project_language_type}_STANDARD_REQUIRED ON)
endif()
set_target_properties(user_lib PROPERTIES ${project_language_type}_STANDARD ${project_language_standard} ${project_language_type}_STANDARD_REQUIRED ON)

# set project-wide system-include standards
add_definitions("${project_include_standards}")

# set project-wide include dirs
include_directories("${CMAKE_SOURCE_DIR}")
include_directories("${CMAKE_CURRENT_BINARY_DIR}")
include_dir_and_recurse_subdirs(${project_source_dirs})

################################################################################
# TESTING (OPTIONAL ADD-ON TO BUILD)
################################################################################

# note BUILD_TESTING=ON must be passed to cmake (auto-calls enable_testing())
if(BUILD_TESTING)

  # load CTest suite build tests
  include(CTest)

  # cmake language support check
  enable_language("${testing_language_type}")

  # source file lists
  set(testing_sources "")
  collect_source_files_recursively(testing_sources ${testing_source_dirs})

  # test harness executable
  add_executable("${testing_exec_to_build}" ${testing_sources})
  # cmake ctests to run / linked libs
  add_test(NAME "${testing_exec_to_build}" COMMAND "${testing_exec_to_build}")
  # link libs --> executables
  target_link_libraries("${testing_exec_to_build}" PRIVATE user_lib)

  # source config

  # testing language standards
  set_target_properties("${testing_exec_to_build}" PROPERTIES
    ${testing_language_type}_STANDARD "${testing_language_standard}"
    ${testing_language_type}_STANDARD_REQUIRED ON)

  # testing include dirs
  include_dir_and_recurse_subdirs(${testing_source_dirs})

endif()

EOF
}

generate_vimrc() {
  if [ -e '.vimrc' ]; then
    err_msg=".vimrc file already exists"
    print_error_msg "${err_msg}" 1
  fi
  cat <<- 'EOF' > .vimrc
"*******************************************************************************
" NOTE: MUST START VIM IN PROJECT ROOT!
"*******************************************************************************

let b:config_file_name     = '.project_config'
let b:completion_file_name = '.clang_complete'
let b:config_lines = {
  \ 'lang_type'         : 5,
  \ 'lang_std'          : 7,
  \ 'testing_lang_type' : 19,
  \ 'testing_lang_std'  : 21,
  \ 'defs'              : 9,
  \ 'warnings'          : 11,
  \ 'src_dirs'          : 13,
  \ 'testing_src_dirs'  : 23
\ }
let b:cpp_fallback_std = "11"
let b:c_fallback_std   = "99"

function! s:GetConfigCompileDefs(project_config, config_lines)
  return (a:project_config[a:config_lines.defs] == "-")
    \ ? ''
    \ : a:project_config[a:config_lines.defs]
endfunction

function! s:GetConfigCompileWarnings(project_config, config_lines)
  return (a:project_config[a:config_lines.warnings] == "-")
    \ ? ''
    \ : a:project_config[a:config_lines.warnings]
endfunction

function! s:GetConfigCPPCompileStd(project_config, config_lines)
  let l:lang_type         = a:project_config[a:config_lines.lang_type]
  let l:lang_std          = a:project_config[a:config_lines.lang_std]
  let l:testing_lang_type = a:project_config[a:config_lines.testing_lang_type]
  let l:testing_lang_std  = a:project_config[a:config_lines.testing_lang_std]
  let l:std = (l:lang_type == "CPP")
    \ ? l:lang_std
    \ : (l:testing_lang_type == "CPP" ? l:testing_lang_std : b:cpp_fallback_std)
  return '-std=c++' . l:std
endfunction

function! s:GetConfigCCompileStd(project_config, config_lines)
  let l:lang_type         = a:project_config[a:config_lines.lang_type]
  let l:lang_std          = a:project_config[a:config_lines.lang_std]
  let l:testing_lang_type = a:project_config[a:config_lines.testing_lang_type]
  let l:testing_lang_std  = a:project_config[a:config_lines.testing_lang_std]
  let l:std = (l:lang_type == "C")
    \ ? l:lang_std
    \ : (l:testing_lang_type == "C" ? l:testing_lang_std : b:c_fallback_std)
  return '-std=c' . l:std
endfunction

function! s:GetConfigTopLevelSrcDirs(project_config, config_lines)
  let l:src_dirs     = split(a:project_config[a:config_lines.src_dirs], ":", 1)
  let l:testing_dirs = split(a:project_config[a:config_lines.testing_src_dirs], ":", 1)
  if (a:project_config[a:config_lines.testing_src_dirs] == "-")
    return l:src_dirs
  else
    return (l:src_dirs + l:testing_dirs)
  endif
endfunction

function! s:GetRecursedRelativeIncludePaths(project_config, config_lines)
  let l:top_level_src_dirs = s:GetConfigTopLevelSrcDirs(a:project_config, a:config_lines)
  let l:paths = []
  for l:dir in l:top_level_src_dirs
    let l:paths = l:paths + systemlist('find ' . l:dir . ' -type d | sed s/^//')
  endfor
  return l:paths
endfunction

function! s:SetVimIncludePaths(project_config, config_lines)
  let l:include_paths = s:GetRecursedRelativeIncludePaths(a:project_config, a:config_lines)
  let $CPATH = ""
  let $C_INCLUDE_PATH = ""
  let $CPLUS_INCLUDE_PATH = ""
  for l:path in l:include_paths
    let $CPATH .= getcwd() . '/' . l:path . ":"
    let $C_INCLUDE_PATH .= getcwd() . '/' . l:path . ":"
    let $CPLUS_INCLUDE_PATH .= getcwd() . '/' . l:path . ":"
  endfor
endfunction

function! s:SetLinterSettings(project_config, config_lines)
  let l:cpp_std = s:GetConfigCPPCompileStd(a:project_config, a:config_lines)
  let l:defs = s:GetConfigCompileDefs(a:project_config, a:config_lines)
  let l:warnings = s:GetConfigCompileWarnings(a:project_config, a:config_lines)
  let g:ale_cpp_gcc_options          = l:cpp_std . ' ' . l:defs . ' ' . l:warnings
  let g:ale_cpp_clang_options        = l:cpp_std . ' ' . l:defs . ' ' . l:warnings
  let g:ale_cpp_clangcheck_options   = l:cpp_std . ' ' . l:defs . ' ' . l:warnings
  let g:ale_cpp_clang_format_options = l:cpp_std . ' ' . l:defs . ' ' . l:warnings
  let g:ale_cpp_clangtidy_options    = l:cpp_std . ' ' . l:defs . ' ' . l:warnings
  let l:c_std = s:GetConfigCCompileStd(a:project_config, a:config_lines)
  let g:ale_c_gcc_options            = l:c_std . ' ' . l:defs . ' ' . l:warnings
  let g:ale_c_clang_options          = l:c_std . ' ' . l:defs . ' ' . l:warnings
  let g:ale_c_clangcheck_options     = l:c_std . ' ' . l:defs . ' ' . l:warnings
  let g:ale_c_clang_format_options   = l:c_std . ' ' . l:defs . ' ' . l:warnings
  let g:ale_c_clangtidy_options      = l:c_std . ' ' . l:defs . ' ' . l:warnings
endfunction

function! s:WriteSettingsToCompletionFile(completion_file_name, project_config, config_lines)
  let l:lang_type = a:project_config[a:config_lines.lang_type]
  let l:cpp_compile_standard = s:GetConfigCPPCompileStd(a:project_config, a:config_lines)
  let l:c_compile_standard = s:GetConfigCCompileStd(a:project_config, a:config_lines)
  let l:project_compile_std = (l:lang_type == "CPP")
    \ ? l:cpp_compile_standard
    \ : l:c_compile_standard
  call writefile([l:project_compile_std], a:completion_file_name)
  let l:defs = s:GetConfigCompileDefs(a:project_config, a:config_lines)
  call writefile(split(l:defs, " ", 0), a:completion_file_name, "a")
  let l:warnings = s:GetConfigCompileWarnings(a:project_config, a:config_lines)
  call writefile(split(l:warnings, " ", 0), a:completion_file_name, "a")
  let l:include_paths = s:GetRecursedRelativeIncludePaths(a:project_config, a:config_lines)
  for path in l:include_paths
    call writefile(["-I" . path], a:completion_file_name, "a")
  endfor
endfunction

function! s:Main()
  let l:project_config = readfile(b:config_file_name)
  call s:SetLinterSettings(l:project_config, b:config_lines)
  call s:WriteSettingsToCompletionFile(b:completion_file_name, l:project_config, b:config_lines)
  call s:SetVimIncludePaths(l:project_config, b:config_lines)
endfunction

call s:Main()

EOF
}

generate_new_setup_files() {
  setup_file_generated='false'
  if [ "${generate_new_project_config}" = 'true' ]; then
    generate_project_config
    setup_file_generated='true'
  fi
  if [ "${generate_new_cmakelists}" = 'true' ]; then
    generate_cmakelists
    setup_file_generated='true'
  fi
  if [ "${generate_new_vimrc}" = 'true' ]; then
    generate_vimrc
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
  cmake --no-warn-unused-cli \
    -DCMAKE_BUILD_TYPE="${build_type}" \
    -DBUILD_TESTING="${build_testing}" \
    -Dproject_config_file="${project_config_file}" \
    -Dproject_source_main_exec="${main_executable_src}" \
    "$([ "${main_executable_src}" != '-' ] && printf "%s%s" "-Dproject_main_exec_to_build=" "${executable_name}" || echo '')" \
    "$([ "${build_testing}" = 'ON' ] && printf "%s%s" "-Dtesting_exec_to_build=" "${test_driver_name}" || echo '')" \
    "$([ "${compiler_type}" != 'default' ] && printf "%s%s" "-DCMAKE_C_COMPILER=" "${compiler_c}" || echo '')" \
    "$([ "${compiler_type}" != 'default' ] && printf "%s%s" "-DCMAKE_CXX_COMPILER=" "${compiler_cpp}" || echo '')" \
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

copy_execs() {
  [ -e "${executable_name}" ] && cp "${executable_name}" ..
  [ -e "${test_driver_name}" ] && cp "${test_driver_name}" ..
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
  copy_execs
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

