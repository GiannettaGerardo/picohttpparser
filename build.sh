#!/bin/bash

compile_options=( 
  -g3
  -pedantic
  -Wall
  -Wfloat-conversion
  -Wextra
  -Wconversion
  -Wdouble-promotion
  -Wno-unused-parameter
  -Wno-unused-function
  -Wno-sign-conversion
  -fsanitize=undefined
  -fsanitize-trap 
)

clang++ "${compile_options[@]}" -std=c++20 picohttpparser.cpp bench.cpp -o bench

clang++ "${compile_options[@]}" -std=c++20 -o test \
  test.cpp \
  picotest/picotest.c \
  picohttpparser.cpp
