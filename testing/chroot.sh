#!/bin/sh

ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

hwclock --systohc

sed -i "s/^#en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/" /etc/locale.gen
locale-gen

printf "LANG=en_US.UTF-8" > /etc/locale.conf

printf "arch" > /etc/hostname

mkinitcpio -P

passwd

useradd -s /bin/bash -m mamiza
passwd mamiza

systemctl enable NetworkManager

grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
