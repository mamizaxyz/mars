# mars
Mamiza's ArchLinux Installation Script. MARS

# Installation
The installation script may have bugs but it currently works(ish).
**USE IT AT YOUR OWN RISK.**
Make sure you edit 'install.sh' to your username (the 'name' variable).
The script uses my username by default.
``` shell
git clone https://github.com/mamizaxyz/mars
cd mars
sudo sh install.sh -u username -p base
```
You can substitute `sh` in the last command to your preferred shell like zsh or bash (not fish).
The script is written to be executed by `dash` so It's posix compliant and all posix shells should be able to run it.
