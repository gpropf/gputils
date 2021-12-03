#!/bin/bash

TARGET=target

if [[ -d "$TARGET" ]]; then
  echo "$TARGET exists on your filesystem."
  find ./$TARGET -iname "*.js" -type f | xargs ls -l | tr -s ' ' | cut --fields=5 -d " " | paste -sd+ | bc
fi

