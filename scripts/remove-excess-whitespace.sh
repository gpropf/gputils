#!/bin/bash

REGEX="s/\(^\t*$*\)\+/NEWLINE\n/g"

sed -e $REGEX $1