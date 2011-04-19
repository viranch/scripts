#!/bin/bash

root="/home/viranch/Softwares/Arch/AUR"

function install()
{
	link="http://aur.archlinux.org/packages/$1/$1.tar.gz"
	name="$1.tar.gz"
	dirname=$1
	cd $root/src/
	wget -nc $link
	if [ ! -f "$name" ]; then
		echo ":: Error downloading from AUR"
		return
	fi

	tar -zxvf $name
	source $dirname/PKGBUILD
	cd $dirname
	src=$pkgname-$pkgver-$pkgrel.src.tar.gz
	if [ ! -f $src ]; then
		echo ":: Downloading sources..."
		makepkg --allsource
	fi
	if [ ! -f "$src" ]; then
		return
	fi

	mv $src ../$name
	echo ":: Installing package..."
	for dep in $(pacman -T ${depends[@]} ${makedepends[@]}); do
		a=$(pacman -Ss "^$dep$")
		if [ -z "$a" ]; then
			aurman -S $dep
		fi
	done
	makepkg -si --noconfirm
	pkg=$pkgname-$pkgver-$pkgrel-i686.pkg.tar.xz
	if [ ! -f "$pkg" ]; then
		return
	fi

	mv $pkg $root/pkg/
	cd ..
	rm -rf $dirname
	echo ":: Install complete."
	if [ -z "$makedepends" ]; then
		return
	fi
}

function remove()
{
	rm -f ~/Softwares/Arch/AUR/{pkg,src}/$1*
	sudo pacman -Rs $1
	echo ":: Done."
}

while getopts "S:R:" OPTION
do
	case $OPTION in
		S)
			install $OPTARG
			exit 0
			;;
		R)
			remove $OPTARG
			exit 0
			;;
	esac
done

