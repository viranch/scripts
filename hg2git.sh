#!/bin/sh

cd $1
git init
~/playground/fast-export/hg-fast-export.sh -r .
rm -rf *
git checkout HEAD
git filter-branch -f --env-filter '
    GIT_AUTHOR_NAME='Viranch Mehta'
    GIT_AUTHOR_EMAIL='viranch.mehta@gmail.com'
    GIT_COMMITTER_NAME='Viranch Mehta'
    GIT_COMMITTER_EMAIL='viranch.mehta@gmail.com'
' HEAD
rm -rf .hg/

