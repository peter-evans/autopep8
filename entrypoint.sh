#!/bin/sh -l
set -uo pipefail

autopep8 $*
echo ::set-output name=exit-code::$?
