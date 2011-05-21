#!/bin/bash
if [ $# -eq 0 ]; then
	echo "Specify a package file."
	exit 0
fi
cd ~/kde
tar -xvf $1 --exclude .PKGINFO --exclude .INSTALL --overwrite
cp -R usr/* install/
rm -rf usr

