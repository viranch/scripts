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
	echo "Server = $1" >> /etc/pacman.d/mirrorlist
fi
echo "Server = ftp://mirror.cse.iitk.ac.in/archlinux/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist

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
EDITOR=vim
sed 's/^root/$username/g' /etc/sudoers > /tmp/sudoers; mv /tmp/sudoers /etc/sudoers
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
pacman -S alsa-utils libgl xorg mesa $pkg xf86-input-{keyboard,mouse,evdev,synaptics} dbus
if [ "$opt" = "2" ]; then
	nvidia-xconfig
else
	Xorg -configure
	mv /root/xorg.conf.new /etc/X11/xorg.conf
fi
echo ":: Drivers installed"

# KDE
echo ":: Installing KDE"
pacman -S ttf-bitstream-vera ttf-dejavu
pacman -S kdebase-workspace yakuake kdebase-dolphin kdesdk-kate phonon-xine amarok choqok kdenetwork-kopete konversation libreoffice kdeutils-ark kdegraphics-{gwenview,okular,ksnapshot} kdemultimedia-kmix kdeplasma-applets-networkmanagement kdebase-plasma kdeartwork-kscreensaver chromium firefox vlc
pacman -S zip unzip unrar wine flashplugin axel youtube-dl
pacman -S ntfs-3g dosfstools gparted
pacman -S gtk-theme-swtich2 oxygen-gtk
pacman -S kdeplasma-addons-applets-{notes,rssnow}
#pacman -S kdegraphics-kolourpaint
#pacman -S kdegames-ksquares kdegames-kmines
#pacman -S mp3splt
#pacman -S wireshark php-apache
#pacman -S cmake python2-qt qtcreator qt-doc subversion git mercurial
#aurman -S ttf-ms-fonts ttf-vista-fonts ttf-google-webfonts ttf-tahoma
echo ":: Install complete."
echo

# Add to the DAEMONS array in /etc/rc.conf to start them at every boot.
echo -n ":: Setting up daemons... "
sed 's/^DAEMONS=.*/DAEMONS=\(syslog-ng dbus networkmanager crond kdm\)/g' /etc/rc.conf > /tmp/rc.conf; mv /tmp/rc.conf /etc/rc.conf
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

