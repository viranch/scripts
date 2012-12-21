#!/bin/bash

# Setup pacman mirrorlist
echo -n ":: Setting up pacman mirrorlist... "
alias pacman='pacman --noconfirm --needed'
cp /etc/pacman.d/mirrorlist /tmp/mrl
echo "Server = http://mirror.cse.iitk.ac.in/archlinux/\$repo/os/\$arch" | cat - /tmp/mrl > /etc/pacman.d/mirrorlist

# Users
echo ":: Installing zsh"
pacman -S zsh
echo ":: Configure users"
echo
echo -n "Enter new username: "
read username
useradd -m -g users -s /bin/zsh $username
passwd $username
pacman -S vim sudo
export EDITOR=vim
sed -i "s/^root/$username/g" /etc/sudoers
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
pacman -S alsa-utils xorg-{server,xinit,server-utils} mesa $pkg xf86-input-{evdev,synaptics}
if [ "$opt" = "2" ]; then
	nvidia-xconfig
fi
echo ":: Drivers installed"

# KDE
echo ":: Installing Fonts"
pacman -S ttf-{bitstream-vera,dejavu,liberation}
echo ":: Installing KDE"
kdebase-{workspace,dolphin,kwrite,plasma} kdegraphics-{gwenview,okular,ksnapshot} kdemultimedia-kmix kdeplasma-applets-networkmanagement kdeartwork-kscreensaver kdeutils-ark oxygen-gtk{2,3}
echo "::Installing misc tools"
pacman -S zip unzip unrar flashplugin youtube-dl gtk-theme-swtich2
pacman -S ntfs-3g dosfstools ntfsprogs
pacman -S git openssh cmake python2-qt
pacman -S usb_modeswitch modemmanager
pacman -S libreoffice-{en-US,calc,impress,writer,kde4,extension-pdfimport}

echo -n "Install quake-like terminal (Yakuake)? [Y/n] "
read opt
if [ -z "$opt" ] || [ "$opt" = "y" ] || [ "$opt" = "Y" ]
then
    pacman -S yakuake
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
    pacman -S kde-telepathy telepathy
fi
echo ""

echo -n "Install IRC client (Konversation)? [Y/n] "
read opt
if [ -z "$opt" ] || [ "$opt" = "y" ] || [ "$opt" = "Y" ]
then
    pacman -S konversation
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

echo -n "Install games (KMines, KBreakout, KSquares)? [Y/n] "
read opt
if [ -z "$opt" ] || [ "$opt" = "y" ] || [ "$opt" = "Y" ]
then
    pacman -S kdegames-k{mines,breakout,squares}
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
#aurman -S ttf-ms-fonts ttf-vista-fonts ttf-google-webfonts ttf-tahoma partitionmanager-svn
echo ":: Install complete."
echo

echo -n ":: Setting up services... "
systemctl enable kdm.service
systemctl enable NetworkManager.service
echo

# Reboot
echo
echo "You can now reboot your system and enjoy ArchLinux+KDE!"

echo -n "Reboot? [Y/n] "
read ch
if [ -z "$ch" -o "$ch" = "y" -o "$ch" = "Y" ]; then
	reboot
fi
