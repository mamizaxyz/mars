#!/bin/sh
# License: GNU GPLv3
# Written by: themamiza
# dotfiles: https://github.com/mamizaxyz/dotfiles

# Exit on error (e):
set -e

### Variables:
email="themamiza@gmail.com"
dotfilesrepo="https://github.com/mamizaxyz/dotfiles"
slockrepo="https://github.com/mamizaxyz/slock.git"
doomrepo="https://github.com/hlissner/doom-emacs.git"

[ -z "$name" ] && name="mamiza"

### Function declarations:
help()
{
    printf "Optional arguments:\n"
    printf "    -h          - Display this message and exit\n"
    printf "    -u          - Accept the next argument as the username\n"
    printf "    -m          - Do a minimal install\n"
    printf "                    (recommended for slow internet connections)\n"
    printf "Written by mamiza: <%s>\n" "$email"
    printf "More help: <%s>\n" "$dotfilesrepo"
}

checkopts()
{
    while getopts ":hmu:" o; do
        case "${o}" in
            h) help && exit 0;;
            u) name=${OPTARG};;
            m) export progsfile="https://raw.githubusercontent.com/mamizaxyz/mars/main/progs/minimal.csv";;
            *) printf "ERROR: Invalid option: %s\n" "$OPTARG"
               printf "See \`./install.sh -h\` for help\n" && exit 1;;
        esac
    done

    [ -z "$progsfile" ] && export progsfile="https://raw.githubusercontent.com/mamizaxyz/mars/main/progs/progs.csv"

    while ! echo "$name"  | grep -q "^[a-z_][a-z0-9_-]*$"; do
        printf "ERROR: Username '%s' is not valid\n" "$name" && exit 1
    done
}

pacmansyu()
{
    pacman --noconfirm -Syu
}

installpkg()
{
    pacman --noconfirm --needed -S "$1"
}

putgitrepo()
{
    dir="/home/$name/.local/src/dotfiles"
    sudo -u "$name" git clone --depth 1 "$dotfilesrepo" "$dir" || {
        cd "$dir" || return 1
        sudo -u "$name" git pull --force origin main
    }
    sudo -u "$name" cp -rfT "$dir" "/home/$name"
}

installparu()
{
    pacman -Q paru >/dev/null 2>&1 && printf "NOTE: 'paru' is already installed\n" && return 0
    dir="/home/$name/.local/src/paru"
    sudo -u "$name" mkdir -p "$dir"
    sudo -u "$name" git clone --depth 1 "https://aur.archlinux.org/paru.git" "$dir" || {
        cd "$dir" || return 1
        sudo -u "$name" git pull --force origin master
    }
    cd "$dir"
    sudo -u "$name" -D "$dir" makepkg --noconfirm -si || return 1
}

aurinstall()
{
    sudo -u "$name" paru --noconfirm -S "$1"
}

gitmakeinstall()
{
    progname="$(basename "$1" .git)"
    dir="/home/$name/.local/src/$progname"
    sudo -u "$name" git clone --depth 1 "$1" "$dir" || {
        cd "$dir" || return 1
        sudo -u "$name" git pull --force origin master  ||
        sudo -u "$name" git pull --force origin main
    }
    cd "$dir" || exit 1
    make
    make install
    cd /tmp   || return 1
}

gitinstallslock()
{
    dir="/home/$name/.local/src/slock"
    sudo -u "$name" git clone --depth 1 "$slockrepo" "$dir" || {
        cd "$dir" || return 1
        sudo -u "$name" git pull --force origin master
    }
    sed -i "s/username/$name/; s/usergroup/$name" "$dir/config.h"
    cd "$dir" || exit 1
    make
    make install
    cd /tmp   || return 1
}

installationloop()
{
    curl -Ls "$progsfile" | sed '/^#/d; /^$/d' > /tmp/progs.csv

    while IFS=, read -r tag program; do
        case "$tag" in
            "A") aurinstall     "$program";;
            "G") gitmakeinstall "$program";;
            *)   installpkg     "$program";;
        esac
    done < /tmp/progs.csv
}

newperms()
{
    sed -i "/#MAMIZA/d" /etc/sudoers
    printf "%s #MAMIZA" "$*" >> /etc/sudoers
}

filecorrections()
{
    [ -f /etc/installation.date ] || date > /etc/installation.date

    newperms "mamiza ALL=(ALL) ALL
mamiza ALL=(ALL) NOPASSWD: /usr/bin/pacman -Syyu, /usr/bin/pacman -Syu"

    grep -q "ILoveCandy" /etc/pacman.conf || sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf
    sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 5/; s/^#Color$/Color/; s/^#VerbosePkgLists$/VerbosePkgLists/" /etc/pacman.conf
    sed -i "s/-j2/-j$(nproc)/; s/^#MAKEFLAGS$/MAKEFLAGS/" /etc/makepkg.conf

    sed -i "s/^#GRUB_DISABLE_SUBMENU=y$/GRUB_DISABLE_SUBMENU=y/; s/^#GRUB_SAVEDEFAULT=true$/GRUB_SAVEDEFAULT=true/;
            s/^GRUB_GFXMODE=auto$/GRUB_GFXMODE=1920x1080/; s/^#GRUB_CMDLINE_LINUX=\"\"$/GRUB_CMDLINE_LINUX=\"resume=/dev/nvme0n1p4\"/" /etc/default/grub

    sudo -u "$name" mkdir -p "/home/$name/.cache/zsh" "/home/$name/.cache/bash"
}

installdoom()
{
    while true; do
        printf "Do you want doom emacs installed? [y/N]"
        read -r answer
        case "${answer,,}" in
            y|yes) break;;
            n|no)  return 0;;
            *) printf "Invalid answer\n"
        esac
    done

    dir="/home/$name/.emacs.d"
    sudo -u "$name" git clone --depth 1 "$doomrepo" "$dir" || {
        cd "$dir" || return 1
        sudo -u "$name" git pull --force origin master
    }
    sudo -u "$name" mkdir -pv "/home/$name/.config/doom"
    sudo -u "$name" ln -sf "/home/$name/.emacs.d/bin/doom" "/home/$name/.local/bin/doom"
    sudo -u "$name" "/home/$name/.local/bin/doom" install
}

filemvs()
{
    rm -rf  "/home/$name/README.md" "/home/$name/LICENSE" "/home/$name/.git" \
            "/home/$name/install.sh" "/home/$name/progs" "/home/$name/testing" \
            "/home/$name/.bash_logout" "/home/$name/.bash_profile" \
            "/home/$name/.lesshst" "/home/$name/.viminfo"

    sudo -u "$name" "/home/$name/.local/bin/shortcuts"
}

### The actuall script:

checkopts "$@"

! { id -u "$name" >/dev/null 2>&1; } && useradd -s /bin/zsh -m "$name" && passwd "$name"

pacmansyu || { printf "ERROR: Could not update packages with \`pacman -Syu\`\n" && exit 1; }

for x in git zsh base-devel; do
    installpkg "$x"
done

putgitrepo || { printf "ERROR: Failed to install dotfiles\n" && exit 1; }

installparu || { printf "ERROR: paru installation failed.\n" && exit 1; }
installationloop || { printf "ERROR: Failed \`installationloop\`\n" && exit 1; }
gitinstallslock || { printf "ERROR: Failed to install slock\n" && exit 1; }
sudo -u "$name" paru -S libxft-bgra-git || { printf "ERROR: Failed to install \`libxft-bgra-git\`\n" && exit 1; }

pacman -Q vim >/dev/null 2>&1 && pacman -Rns vim
ln -sf /usr/bin/nvim /usr/bin/vim

filecorrections || { printf "ERROR: Failed \`filecorrections\`\n" && exit 1; }

installdoom || { printf "ERROR: Failed to install doom-emacs\n" && exit 1; }

chsh -s /bin/zsh "$name" || { printf "ERROR: Failed to change shell to zsh\n" && exit 1; }

filemvs

grub-mkconfig -o /boot/grub/grub.cfg

printf "%s: Hopefully, everything has gone perfectly!\n" "$0"
