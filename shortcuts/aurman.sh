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
    curl -s --compressed https://aur.archlinux.org/packages/`echo $pkg|cut -c1-2`/$pkg/$pkg.tar.gz | tar zx
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
            cp $pkgname-*pkg.tar.xz $root/
        fi
    fi

    echo ":: $pkg installed"
}

function upgradeaur()
{
    echo ":: Looking for updates"
    cd $temp
    pkgs=""
    for pkg in `pacman -Qqm`; do
        current_ver=`pacman -Q $pkg | cut -d' ' -f2`
        epoch=""
        curl -s --compressed https://aur.archlinux.org/packages/`echo $pkg|cut -c1-2`/$pkg/$pkg.tar.gz | tar zx
        source $pkg/PKGBUILD
        new_ver="$pkgver-$pkgrel"
        test -n "$epoch" && new_ver="$epoch:$new_ver"
        if [[ "$new_ver" != "$current_ver" ]]; then
            echo ":: Upgrading $pkgname from $current_ver to $new_ver"
            installpkg $pkgname
        fi
    done
}

function removepkg()
{
    pkg=$1

    echo ":: Getting dependency list"
    cd $temp
    curl -s --compressed https://aur.archlinux.org/packages/`echo $pkg|cut -c1-2`/$pkg/$pkg.tar.gz | tar zx
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
