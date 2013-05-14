root_fs=$1
home_fs=$2
hostname="arch"
timezone="Asia/Kolkata"

echo "==> Formatting root partition $root_fs"
mkfs -t ext4 $root_fs
echo "==> Mounting root partition to /mnt"
mount $root_fs /mnt
echo "==> Mounting home partition to /mnt/home"
mkdir -p /mnt/home
mount $home_fs /mnt/home

echo "==> Installing base system"
pacstrap /mnt base base-devel

alias chroot='arch-chroot /mnt'

echo "==> Installing grub"
chroot pacman -S grub-bios
echo "==> Configuring grub"
chroot grub-mkconfig -o /boot/grub/grub.cfg

echo "==> Generating fstab"
genstab -p /mnt >> /mnt/etc/fstab
echo "==> Setting hostname"
echo $hostname > /mnt/etc/hostname
echo "==> Setting localtime"
chroot ln -s /usr/share/zoneinfo/$timezone /etc/localtime
echo "==> Setting locale and keyboard preferences"
echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf
echo "KEYMAP=us" > /mnt/etc/vconsole.conf
# uncomment the locale in /etc/locale.gen
chroot locale-gen

echo "==> Generating kernel image"
chroot mkinitcpio -p linux

echo "==> Set root password"
chroot passwd
