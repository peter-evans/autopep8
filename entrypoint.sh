#!/bin/sh -l
set -uo pipefail

cd $GITHUB_WORKSPACE

MERGE_BASE=$(git merge-base origin/master HEAD)
readarray -t FILES <  <(git diff --name-status HEAD $MERGE_BASE)

SUCCESS=0

for file in "${FILES[@]}"; do
  autopep8 $file
  (( SUCCESS+=$? ))
done

if [ SUCCESS -ne 0 ]; then
  SUCCESS=1
fi

echo ::set-output name=exit-code::$SUCCESS
