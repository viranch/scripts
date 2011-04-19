#!/bin/sh

cd $1
git init
~/playground/fast-export/hg-fast-export.sh -r .
dir=$(basename $1)
mkdir /tmp/$dir
mv * /tmp/$dir
git checkout HEAD
git remote add origin https://viranch@github.com/viranch/$2.git
git push origin master
rm -rf /tmp/$dir .hg/

