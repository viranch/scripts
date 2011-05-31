#!/bin/bash
function _remove() {
	for i in $(tar tf $1)
	do
		rm $(echo $i | sed 's/^usr\//\/home\/viranch\/kde\/install\//g')
	done
}


function _install() {
	mkdir -p /tmp/trunkman.tmp
	cd /tmp/trunkman.tmp
	tar -xvf $1 --exclude .PKGINFO --exclude .INSTALL --overwrite
	cp -R usr/* ~/kde/install/
	cd /tmp
	rm -rf /tmp/trunkman.tmp
}

if [ $# -lt 2 ]; then
	echo "Usage: $0 install|remove path_to_pkg"
	exit 0
fi

_$1 $2

