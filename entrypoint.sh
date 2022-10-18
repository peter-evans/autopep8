#!/bin/sh -l
set -uo pipefail

autopep8 $*
echo "exit-code=$?" >> $GITHUB_OUTPUT
