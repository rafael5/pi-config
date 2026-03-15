# -------------------------------------------------------------------------
# DESKTOPS - FLAVORS
# -------------------------------------------------------------------------
* https://bytexd.com/switch-desktop-environments-ubuntu-debian-commandline/
* https://tecadmin.net/how-to-install-and-switch-desktop-environments-in-ubuntu/
* https://forum.level1techs.com/t/how-to-guide-ubuntu-switching-desktop-environments/76509
* https://linuxconfig.org/how-to-install-minimal-gnome-on-ubuntu-20-04-focal-fossa-linux

sudo update-alternatives --config x-session-manager

# OPENBOX
sudo apt install openbox

# XFCE
sudo apt install xubuntu-desktop xfce-session 

# LXDE
sudo apt install lubuntu-desktop lxde lxde-session

# KDE
sudo apt install kubuntu-desktop

## CINNAMON
sudo apt install cinnamon




# -------------------------------------------------------------------------
# DESKTOPS - TASKSEL INSTALL
# -------------------------------------------------------------------------
https://itsfoss.com/best-linux-desktop-environments/
https://linuxhint.com/change-debian-desktop-environment/

# Officially supported desktops:
https://wiki.debian.org/DesktopEnvironment
GNOME
Plasma
Xfce
LXDE
MATE

# Tasksel
sudo apt install tasksel
sudo tasksel

task-gnome-desktop
task-xfce-desktop
task-kde-desktop
task-lxde-desktop
task-cinnamon-desktop
task-mate-desktop
task-lxqt-desktop


# Window Manager
Openbox
Fluxbox
Compiz

apt install openbox
apt install menu


# update
sudo apt update && sudo apt upgrade




# -------------------------------------------------------------------------
# DESKTOPS - APT INSTALL
# -------------------------------------------------------------------------
* https://bytexd.com/switch-desktop-environments-ubuntu-debian-commandline/
* https://tecadmin.net/how-to-install-and-switch-desktop-environments-in-ubuntu/
* https://forum.level1techs.com/t/how-to-guide-ubuntu-switching-desktop-environments/76509
* https://linuxconfig.org/how-to-install-minimal-gnome-on-ubuntu-20-04-focal-fossa-linux

sudo update-alternatives --config x-session-manager

# OPENBOX
sudo apt install openbox

# MATE
https://www.tecmint.com/install-mate-desktop-in-ubuntu-fedora/
sudo apt install ubuntu-mate-desktop
sudo apt dist-upgrade

# XFCE
sudo apt install xubuntu-desktop xfce-session 

# LXDE
sudo apt install lubuntu-desktop lxde lxde-session

# KDE
sudo apt install kubuntu-desktop

## CINNAMON
sudo apt install cinnamon

## GNOME (v3)
sudo apt install gnome-session gnome-terminal 

## GNOME-FLASHBACK (v2)
sudo apt install gnome-session-flashback




# -------------------------------------------------------------------------
# MATE
# -------------------------------------------------------------------------
https://www.tecmint.com/install-mate-desktop-in-ubuntu-fedora/
sudo apt install ubuntu-mate-desktop
sudo apt dist-upgrade

# MATE
=> must remove UNITY for MATE to work
sudo apt install mate-desktop-environment-core
sudo apt install mate-desktop-environment-extras
sudo apt build-dep mdm
sudo apt install mdm*

# UNITY: REMOVE
sudo apt-get remove unity unity-asset-pool unity-control-center unity-control-center-signon unity-gtk-module-common unity-lens* unity-services unity-settings-daemon unity-webapps* unity-voice-service

# UNITY: Re-install
sudo apt-get install unity*
sudo apt-get build-dep unity




