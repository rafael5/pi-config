Snapshot Directory + Commands

~/snapshots/
├─ YYYY-MM-DD-HH-MM/
│   ├─ packages/
│   │   ├─ dpkg-selections.txt   [1]
│   │   ├─ apt-manual.txt        [2]
│   │   ├─ apt-installed.txt     [3]
│   │   └─ apt-sources/          
│   │       ├─ sources.list      
│   │       └─ sources.list.d/   [4]
│   │
│   ├─ configs/
│   │   ├─ etc/                  [5]
│   │   ├─ usr-local-etc/        [6]
│   │   └─ home/                 [7]
│   │
│   └─ services/
│       ├─ active-services.txt   [8]
│       └─ enabled-services.txt  [9]


[1] dpkg --get-selections
[2] apt-mark showmanual 
[3] apt list --installed 
[4] cp -r /etc/apt/sources.list.d apt-sources/
[5] cp -r /etc configs/etc
[6] cp -r /usr/local/etc configs/usr-local-etc 2>/dev/null || true
[7] cp -r /home configs/home
[8] systemctl list-units --type=service --state=active > active-services.txt
[9] systemctl list-unit-files --type=service --state=enabled > enabled-services.txt


This structure provides:
* Reproducibility → dpkg-selections.txt + apt-sources/
* Intent tracking → apt-manual.txt
* Version auditing → apt-installed.txt
* System behavior visibility → configs + services
* Clean diffing model → minimal noise, high signal




File-by-File Definitions + Commands

# 📦 packages/

dpkg-selections.txt
Description: Canonical full package state (ground truth)
Command:
dpkg --get-selections > dpkg-selections.txt

apt-manual.txt
Description: Explicitly installed packages (user intent)
Command:
apt-mark showmanual > apt-manual.txt

apt-installed.txt
Description: Full package list with versions (audit + diff)
Command:
apt list --installed > apt-installed.txt

apt-sources/sources.list
Description: Primary APT repository definitions
Command:
cp /etc/apt/sources.list apt-sources/sources.list


apt-sources/sources.list.d/
Description: Additional repository definitions
Command:
cp -r /etc/apt/sources.list.d apt-sources/



# ⚙️ configs/
configs/etc/
Description: Core system configuration (/etc)
Command:
cp -r /etc configs/etc

configs/usr-local-etc/
Description: Local system configs (/usr/local/etc)
Command:
cp -r /usr/local/etc configs/usr-local-etc 2>/dev/null || true


configs/home/
Description: User configuration files (~/.config, shell profiles)
Command:
cp -r /home configs/home
(Optionally restrict to dotfiles for efficiency)

# services/
active-services.txt
Description: Currently running services
Command:
systemctl list-units --type=service --state=active > active-services.txt

enabled-services.txt
Description: Services enabled at boot
Command:
systemctl list-unit-files --type=service --state=enabled > enabled-services.txt


✅ Final Outcome
This structure provides:
Reproducibility → dpkg-selections.txt + apt-sources/
Intent tracking → apt-manual.txt
Version auditing → apt-installed.txt
System behavior visibility → configs + services
Clean diffing model → minimal noise, high signal
