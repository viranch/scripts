#!/bin/bash

# Usage: --help
if [ $# -gt 0 ]; then
	if [ $1 = "--help" ]; then
		cat << EOF
usage: $0 [packages_backup_directory]
EOF
	exit 0
	fi
fi

# Backup pacman cache
alias pacman='pacman --noconfirm --needed'
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
if [ $# -eq 1 ]; then
	echo "Server = $1" > /etc/pacman.d/mirrorlist
fi
echo "Server = http://mirror.cse.iitk.ac.in/archlinux/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist

# Initially force pacman to refresh the package lists
echo ":: Updating base system first"
dhcpcd
pacman -Syyu
pacman -Su
echo ":: Update complete."
echo

# Users
echo ":: Configure users"
echo
echo -n "Enter new username: "
read username
useradd -m -g users -G audio,lp,optical,storage,video,wheel,games,power -s /bin/bash $username
passwd $username
pacman -S vim sudo
export EDITOR=vim
sed "s/^root/$username/g" /etc/sudoers -i
chmod 0440 /etc/sudoers
echo ":: Configuring users complete."
echo

# Drivers
echo ":: Installing drivers"
pkg="xf86-video-intel"
echo "Graphic card: " `lspci | grep -i display`
echo -n "Intel/NVIDIA/ATI? [1/2/3] "
read opt
if [ "$opt" = "2" ]; then
	pkg="nvidia"
elif [ "$opt" = "3" ]; then
	pkg="xf86-video-ati"
fi
pacman -S pulseaudio libgl xorg-server mesa $pkg xf86-input-{keyboard,mouse,evdev,synaptics} dbus
if [ "$opt" = "2" ]; then
	nvidia-xconfig
else
	Xorg -configure
	mv /root/xorg.conf.new /etc/X11/xorg.conf
fi
echo ":: Drivers installed"

# KDE
echo ":: Installing KDE"
pacman -S ttf-bitstream-vera ttf-dejavu ttf-liberation kdebase-workspace kdebase-dolphin kdebase-kwrite libreoffice kdegraphics-{gwenview,okular} kdemultimedia-kmix kdeplasma-applets-networkmanagement kdebase-plasma kdeartwork-kscreensaver
pacman -S zip unzip unrar kdeutils-ark flashplugin youtube-dl
pacman -S ntfs-3g dosfstools
pacman -S gtk-theme-swtich2 oxygen-gtk

echo -n "Install quake-like terminal (Yakuake)? [Y/n] "
read opt
if [ -z "$opt" ] || [ "$opt" = "y" ] || [ "$opt" = "Y" ]
then
    pacman -S yakuake zsh
fi
echo ""

echo -n "Install video player (VLC Media Player)? [Y/n] "
read opt
if [ -z "$opt" ] || [ "$opt" = "y" ] || [ "$opt" = "Y" ]
then
    pacman -S vlc
fi
echo ""

echo -n "Install music player (Amarok)? [Y/n] "
read opt
if [ -z "$opt" ] || [ "$opt" = "y" ] || [ "$opt" = "Y" ]
then
    pacman -S amarok
fi
echo ""

echo -n "Install twitter client (Choqok)? [Y/n] "
read opt
if [ -z "$opt" ] || [ "$opt" = "y" ] || [ "$opt" = "Y" ]
then
    pacman -S choqok
fi
echo ""

echo -n "Install chat client for GMail, MSN, Y!, Facebook, etc (Kopete)? [Y/n] "
read opt
if [ -z "$opt" ] || [ "$opt" = "y" ] || [ "$opt" = "Y" ]
then
    pacman -S kdenetwork-kopete
fi
echo ""

echo -n "Install IRC client (Konversation)? [Y/n] "
read opt
if [ -z "$opt" ] || [ "$opt" = "y" ] || [ "$opt" = "Y" ]
then
    pacman -S konversation
fi
echo ""

echo -n "Install screenshot snapper (KSnapshot)? [Y/n] "
read opt
if [ -z "$opt" ] || [ "$opt" = "y" ] || [ "$opt" = "Y" ]
then
    pacman -S kdegraphics-ksnapshot
fi
echo ""

echo -n "Install internet browser, Chromium/Firefox? [1/2] "
read opt
if [ "$opt" = "1" ]
then
    pacman -S chromium
elif [ "$opt" = "2" ]
then
    pacman -S firefox
fi
echo ""

echo -n "Install notes desktop applet? [Y/n] "
read opt
if [ -z "$opt" ] || [ "$opt" = "y" ] || [ "$opt" = "Y" ]
then
    pacman -S kdeplasma-addons-applets-notes
fi
echo ""

echo -n "Install RSS feeds desktop applet? [Y/n] "
read opt
if [ -z "$opt" ] || [ "$opt" = "y" ] || [ "$opt" = "Y" ]
then
    pacman -S kdeplasma-addons-applets-rssnow
fi
echo ""

echo -n "Install users manager (KUser)? [Y/n] "
read opt
if [ -z "$opt" ] || [ "$opt" = "y" ] || [ "$opt" = "Y" ]
then
    pacman -S kdeadmin-kuser
fi
echo ""

echo -n "Install task scheduler (KCron)? [Y/n] "
read opt
if [ -z "$opt" ] || [ "$opt" = "y" ] || [ "$opt" = "Y" ]
then
    pacman -S kdeadmin-kcron
fi
echo ""

echo -n "Install paint application (KolourPaint)? [Y/n] "
read opt
if [ -z "$opt" ] || [ "$opt" = "y" ] || [ "$opt" = "Y" ]
then
    pacman -S kdegraphics-kolourpaint
fi
echo ""

echo -n "Install minesewwper-like game (KMines)? [Y/n] "
read opt
if [ -z "$opt" ] || [ "$opt" = "y" ] || [ "$opt" = "Y" ]
then
    pacman -S kdegames-kmines
fi
echo ""

echo -n "Install VCS (Git/Mercurial/SVN/All/None)? [1/2/3/A/n] "
read opt
if [ "$opt" = "1" ]
then
    pacman -S git openssh
elif [ "$opt" = "2" ]
then
    pacman -S mercurial openssh
elif [ "$opt" = "3" ]
then
    pacman -S subversion openssh
elif [ "$opt" = "A" ] || [ "$opt" = "a" ]
then
    pacman -S git mercurial subversion openssh
fi
echo ""

echo -n "Install python? [Y/n] "
read opt
if [ -z "$opt" ] || [ "$opt" = "y" ] || [ "$opt" = "Y" ]
then
    pacman -S python2 python
fi
echo ""

echo -n "Install Qt SDK? [Y/n] "
read opt
if [ -z "$opt" ] || [ "$opt" = "y" ] || [ "$opt" = "Y" ]
then
    pacman -S qt-doc qtcreator
fi
echo ""

#pacman -S mp3splt
#pacman -S wireshark php-apache
#pacman -S cmake python2-qt
#aurman -S ttf-ms-fonts ttf-vista-fonts ttf-google-webfonts ttf-tahoma partitionmanager-svn
echo ":: Install complete."
echo

# Add to the DAEMONS array in /etc/rc.conf to start them at every boot.
echo -n ":: Setting up daemons... "
sed -i 's/^DAEMONS=.*/DAEMONS=\(syslog-ng dbus networkmanager crond kdm\)/g' /etc/rc.conf
echo "Done"

# Setup pacman mirrorlist
echo -n ":: Setting up pacman mirrorlist... "
mv /etc/pacman.d/mirrorlist.backup /etc/pacman.d/mirrorlist
echo "Server = ftp://mirror.cse.iitk.ac.in/archlinux/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist
echo "Done"

# Reboot
echo
echo "You can now reboot your system and enjoy ArchLinux+KDE!"

echo -n "Reboot? [Y/n] "
read ch
if [ -z "$ch" -o "$ch" = "y" -o "$ch" = "Y" ]; then
	reboot
fi

