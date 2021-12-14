#!/bin/bash

REGEX='s/(^$){2,}/NEWLINE, /'

sed -r -e "$REGEX" $1