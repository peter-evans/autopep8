#!/bin/sh -l
set -uo pipefail

black . $*
echo ::set-output name=exit-code::$?
