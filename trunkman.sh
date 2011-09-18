#!/bin/bash
function _remove() {
	for i in $(pacman -Qql $1|grep /$ -v)
	do
		rm $(echo $i | sed 's/^\/usr\//\/home\/viranch\/kde\/install\//g')
	done

    for i in $(pacman -Qql $1|grep $1/$)
    do
        rm -rf $i
    done
}


function _install() {
    pkg_file=$(ls /var/cache/pacman/pkg/$1*|tail -n1)
	mkdir -p /tmp/trunkman.tmp
	cd /tmp/trunkman.tmp
	tar -xvf $pkg_file --exclude .PKGINFO --exclude .INSTALL --overwrite
	cp -R usr/* ~/kde/install/
	cd /tmp
	rm -rf /tmp/trunkman.tmp
}

if [ $# -lt 2 ]; then
	echo "Usage: $0 install|remove pkg"
	exit 0
fi

_$1 $2

