#!/bin/sh -l
set -uo pipefail

cd $GITHUB_WORKSPACE

readarray -t FILES < <( git --no-pager diff --name-only `git merge-base origin/master HEAD` )
#autopep8 $*
SUCCESS=1
for file in "${FILES[@]}"; do
  autopep8 $file
  let "SUCCESS*=$?"
done

echo ::set-output name=exit-code::$SUCCESS
