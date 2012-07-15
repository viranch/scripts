#!/bin/bash

root="/home/viranch/Softwares/Arch/AUR"

function installpkg()
{
    pkg=$1

    echo ":: Downloading package file for $pkg"
    cd /tmp
    wget -q http://aur.archlinux.org/packages/$pkg/$pkg.tar.gz -O - | tar zx
    source $pkg/PKGBUILD
    echo ":: Installing missing dependencies"
    echo "==> Build deps: " ${makedepends[@]}
    echo "==> Runtime deps: " ${depends[@]}
    for dep in $(pacman -T ${depends[@]} ${makedepends[@]}); do
        dep=$(echo $dep|sed 's/>.*//g')
        a=$(pacman -Ss "^$dep$")
        if [ -z "$a" ]; then
            $0 -S $dep
        fi
    done

    echo ":: Installing $pkg"
    pkgfile=$(ls $root/$pkgname-$pkgver-$pkgrel-{$(uname -m),any}.pkg.tar.xz 2> /dev/null|tail -n1)
    if [ ! -z "$pkgfile" ]; then
        sudo pacman -U "$pkgfile"
    else
        cd $pkg
        makepkg -si
        ret=$?
        if [ $ret = "1" ]; then
            exit $ret
        else
            cp $pkgname-$pkgver-$pkgrel-*pkg.tar.xz $root/
        fi
    fi

    echo ":: $pkg installed"
}

function removepkg()
{
    pkg=$1

    echo ":: Getting dependency list"
    cd /tmp
    wget -q http://aur.archlinux.org/packages/$pkg/$pkg.tar.gz -O - | tar zx
    source $pkg/PKGBUILD

    echo ":: Removing dependencies"
    for dep in ${depends[@]} ${makedepends[@]}; do
        a=$(pacman -Ss "^$dep$")
        if [ -z "$a" ]; then
            $0 -R $dep
        fi
    done

    echo ":: Removing $pkg"
    sudo pacman -Rs $pkg --noconfirm

    echo ":: $pkg removed"
}

source /etc/makepkg.conf
while getopts "SR" OPTION
do
	case $OPTION in
		S)
			shift $((OPTIND-1))
            for pkg in "$@"; do
                installpkg $pkg
            done
			exit 0
			;;
		R)
			shift $((OPTIND-1))
            for pkg in "$@"; do
                removepkg $pkg
            done
			exit 0
			;;
	esac
done
