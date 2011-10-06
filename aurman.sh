#!/bin/bash

root="/home/viranch/Softwares/Arch/AUR"

function installpkg()
{
    pkg=$1

    echo ":: Downloading package file"
    cd /tmp
    wget -q http://aur.archlinux.org/packages/$pkg/$pkg.tar.gz -O - | tar zx
    source $pkg/PKGBUILD
    echo ":: Installing missing dependencies"
    for dep in $(pacman -T ${depends[@]} ${makedepends[@]}); do
        a=$(pacman -Ss "^$dep$")
        if [ -z "$a" ]; then
            $0 $dep
        fi
    done

    echo ":: Installing $pkg"
    pkgfile=$(ls $root/pkg/$pkgname-$pkgver-$pkgrel-* 2> /dev/null|tail -n1)
    if [ ! -z "$pkgfile" ]; then
        sudo pacman -U "$pkgfile" --noconfirm
    else
        cd $pkg
        makepkg -si --noconfirm
        ret=$?
        if [ $ret = "1" ]; then
            exit $ret
        else
            cp *pkg* $root/pkg/
        fi
    fi

    echo ":: Removing temporary dependencies"
    for makedep in ${makedepends[@]}; do
        a=$(pacman -Ss "^$makedep$")
        if [ -z "$a" ]; then
            removepkg $makedep
        fi
    done

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
            $0 $dep
        fi
    done

    echo ":: Removing $pkg"
    sudo pacman -Rs $pkg --noconfirm

    echo ":: $pkg removed"
}

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
