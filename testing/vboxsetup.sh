#!/bin/sh

timedatectl set-ntp true

cat <<EOF | fdisk /dev/sda
o
n
p



w
EOF
partprobe
yes | mkfs.ext4 /dev/sda1
mount /dev/sda1 /mnt

pacman -Sy --noconfirm archlinux-keyring

pacstrap /mnt base linux linux-firmware networkmanager grub sudo vim

genfstab -U /mnt >> /mnt/etc/fstab

curl https://raw.githubusercontent.com/mamizaxyz/mars/main/testing/chroot.sh > /mnt/chroot.sh && arch-chroot /mnt bash chroot.sh && rm /mnt/chroot.sh
