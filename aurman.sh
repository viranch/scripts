#!/bin/bash

root="/home/viranch/Softwares/Arch/AUR"

function install()
{
	link="http://aur.archlinux.org/packages/$1/$1.tar.gz"
	srcname="$1.tar.gz"
	dirname=$1
	cd $root/src/
	wget -nc $link
	if [ ! -f "$srcname" ]; then
		echo ":: Error downloading from AUR"
		return
	fi

	tar -zxvf $srcname
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

	mv $src ../$srcname
	echo ":: Compiling package..."
	for dep in $(pacman -T ${depends[@]} ${makedepends[@]}); do
		a=$(pacman -Ss "^$dep$")
		if [ -z "$a" ]; then
			aurman -S $dep
		fi
	done
	makepkg -si --noconfirm
    if [ ! -f *.pkg.tar.xz ]; then
		return
	fi

	mv *.pkg.tar.xz $root/pkg/
	cd ..
	rm -rf $dirname
	echo ":: Install complete."
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

