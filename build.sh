#!/bin/bash

clang++ \
  -std=c++20 \
  -g3 \
  -pedantic\
  -Wall \
  -Wfloat-conversion \
  -Wextra \
  -Wconversion \
  -Wdouble-promotion \
  -Wno-unused-parameter \
  -Wno-unused-function \
  -Wno-sign-conversion \
  -fsanitize=undefined \
  -fsanitize-trap \
  picohttpparser.cpp \
  bench.cpp \
  -o bench