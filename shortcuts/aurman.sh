#!/bin/bash

root="$HOME/Softwares/Arch/AUR"
mkdir -p $root
temp="/tmp/aurman"
mkdir -p $temp

function installpkg()
{
    pkg=$1

    fakeroot=$(which fakeroot)
    if [ -z "$fakeroot" ]; then
        echo ":: Installing fakeroot"
        sudo pacman -S fakeroot
    fi

    echo ":: Downloading package file for $pkg"
    cd $temp
    wget -q http://aur.archlinux.org/packages/`echo $pkg|cut -c1-2`/$pkg/$pkg.tar.gz -O - | tar zx
    source $pkg/PKGBUILD
    echo ":: Installing missing dependencies"
    echo "==> Build deps: " ${makedepends[@]}
    echo "==> Runtime deps: " ${depends[@]}
    for dep in $(pacman -T ${depends[@]} ${makedepends[@]}); do
        dep=$(echo $dep|sed 's/>.*//g')
        a=$(pacman -Ss "^$dep$")
        if [ -z "$a" ]; then
            bash $0 -S $dep
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

function upgradeaur()
{
    cd $temp
    pkgs=""
    for pkg in `pacman -Qqm`; do
        current_ver=`pacman -Q $pkg | cut -d' ' -f2`
        wget -q http://aur.archlinux.org/packages/`echo $pkg|cut -c1-2`/$pkg/$pkg.tar.gz -O - | tar zx
        source $pkg/PKGBUILD
        if [[ "$pkgver-$pkgrel" != $current_ver ]]; then
            echo ":: Upgrading $pkgname from $current_ver to $pkgver-$pkgrel"
            installpkg $pkgname
        fi
    done
}

function removepkg()
{
    pkg=$1

    echo ":: Getting dependency list"
    cd $temp
    wget -q http://aur.archlinux.org/packages/`echo $pkg|cut -c1-2`/$pkg/$pkg.tar.gz -O - | tar zx
    source $pkg/PKGBUILD

    echo ":: Removing dependencies"
    for dep in ${depends[@]} ${makedepends[@]}; do
        a=$(pacman -Ss "^$dep$")
        if [ -z "$a" ]; then
            sh $0 -R $dep
        fi
    done

    echo ":: Removing $pkg"
    sudo pacman -Rs $pkg --noconfirm

    echo ":: $pkg removed"
}

source /etc/makepkg.conf
while getopts "SUR" OPTION
do
    case $OPTION in
        S)
            shift $((OPTIND-1))
            for pkg in "$@"; do
                installpkg $pkg
            done
            ;;
        U)
            upgradeaur
            ;;
        R)
            shift $((OPTIND-1))
            for pkg in "$@"; do
                removepkg $pkg
            done
            ;;
    esac
done
