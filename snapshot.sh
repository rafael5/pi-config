#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Snapshot Script: Application, Services, Config Files, Dotfiles, and System State
# (APT + systemd + /etc top-level files + allowlisted dotfiles + OS/kernel +
#  scheduler + Docker)
#
# This script creates a timestamped snapshot of the system’s key application,
# service, configuration, and runtime state under:
#   ~/pi-config/snapshots/YYYY-MM-DD-HH-MM/
#
# Purpose:
#   - Track and diff installed packages over time
#   - Monitor active and enabled services
#   - Capture top-level system configuration files from /etc
#   - Capture selected user-level configuration via safe dotfiles
#   - Capture kernel and OS metadata for reproducibility
#   - Capture scheduled jobs (cron + systemd timers)
#   - Capture Docker state (containers, images, volumes)
#   - Enable auditing, troubleshooting, and partial system reconstruction
#
# Snapshot filesystem:
#   ~/pi-config/snapshots/YYYY-MM-DD-HH-MM/
#   ├─ packages/
#   │   ├─ dpkg-selections.txt
#   │   ├─ apt-manual.txt
#   │   ├─ apt-installed.txt
#   │   └─ apt-sources/
#   │       ├─ sources.list
#   │       └─ sources.list.d/
#   │
#   ├─ config/
#   │   └─ etc/                   # Top-level files only (no subdirs)
#   │
#   ├─ home/
#   │   └─ dotfiles/              # Allowlisted user config files only
#   │
#   ├─ services/
#   │   ├─ active-services.txt
#   │   └─ enabled-services.txt
#   │
#   ├─ system/
#   │   ├─ uname.txt              # Kernel version and architecture
#   │   └─ os-release.txt         # OS distribution metadata
#   │
#   ├─ scheduler/
#   │   ├─ user-cron.txt          # User crontab
#   │   ├─ root-cron.txt          # Root crontab
#   │   └─ systemd-timers.txt     # systemd timers
#   │
#   └─ docker/
#       ├─ containers.txt         # docker ps -a
#       ├─ images.txt             # docker images
#       └─ volumes.txt            # docker volume ls
#
# Security Model:
#   - Dotfiles use an explicit allowlist (no wildcards)
#   - Prevents inclusion of sensitive files (.bash_history, .ssh, tokens, etc.)
#   - /etc capture limited to top-level files only
#   - No secrets, credentials, or private keys intentionally captured
#   - Unreadable or restricted files are skipped safely
#   - Docker and scheduler outputs are metadata-only (no secrets expected)
#
# Notes:
#   - This is a “state snapshot” tool, not a full backup solution
#   - Designed for diffing, auditing, and reproducibility
# -----------------------------------------------------------------------------

set -euo pipefail

# Base directory
BASE_DIR="$HOME/pi-config/snapshots"
TIMESTAMP="$(date +'%Y-%m-%d-%H-%M')"
SNAP_DIR="$BASE_DIR/$TIMESTAMP"

# Create directory structure
mkdir -p "$SNAP_DIR/packages/apt-sources"
mkdir -p "$SNAP_DIR/services"
mkdir -p "$SNAP_DIR/config/etc"
mkdir -p "$SNAP_DIR/home/dotfiles"
mkdir -p "$SNAP_DIR/system"
mkdir -p "$SNAP_DIR/scheduler"
mkdir -p "$SNAP_DIR/docker"

########################################
# PACKAGES
########################################

dpkg --get-selections > "$SNAP_DIR/packages/dpkg-selections.txt"
apt-mark showmanual > "$SNAP_DIR/packages/apt-manual.txt"
apt list --installed > "$SNAP_DIR/packages/apt-installed.txt"

cp /etc/apt/sources.list "$SNAP_DIR/packages/apt-sources/sources.list"
cp -r /etc/apt/sources.list.d "$SNAP_DIR/packages/apt-sources/"

########################################
# CONFIG FILES (TOP-LEVEL /etc FILES ONLY)
########################################

find /etc -maxdepth 1 -type f | while read -r file; do
  cp "$file" "$SNAP_DIR/config/etc/" 2>/dev/null || true
done

########################################
# HOME DOTFILES (ALLOWLIST ONLY)
########################################

DOTFILES=(
  ".bashrc"
  ".profile"
  ".bash_aliases"
  ".gitconfig"
  ".gitignore"
  ".vimrc"
  ".nanorc"
  ".tmux.conf"
  ".inputrc"
)

for file in "${DOTFILES[@]}"; do
  if [[ -f "$HOME/$file" ]]; then
    cp "$HOME/$file" "$SNAP_DIR/home/dotfiles/"
  fi
done

# Optional safe sub-config
if [[ -f "$HOME/.config/starship.toml" ]]; then
  mkdir -p "$SNAP_DIR/home/dotfiles/.config"
  cp "$HOME/.config/starship.toml" "$SNAP_DIR/home/dotfiles/.config/"
fi

########################################
# SERVICES
########################################

sudo systemctl list-units --type=service --state=active > "$SNAP_DIR/services/active-services.txt"
sudo systemctl list-unit-files --type=service --state=enabled > "$SNAP_DIR/services/enabled-services.txt"

########################################
# SYSTEM (KERNEL + OS)
########################################

uname -a > "$SNAP_DIR/system/uname.txt"
cat /etc/os-release > "$SNAP_DIR/system/os-release.txt"

########################################
# SCHEDULER (CRON + SYSTEMD TIMERS)
########################################

crontab -l > "$SNAP_DIR/scheduler/user-cron.txt" 2>/dev/null || true
sudo crontab -l > "$SNAP_DIR/scheduler/root-cron.txt" 2>/dev/null || true
sudo systemctl list-timers > "$SNAP_DIR/scheduler/systemd-timers.txt"

########################################
# DOCKER (IF INSTALLED)
########################################

docker ps -a > "$SNAP_DIR/docker/containers.txt" 2>/dev/null || true
docker images > "$SNAP_DIR/docker/images.txt" 2>/dev/null || true
docker volume ls > "$SNAP_DIR/docker/volumes.txt" 2>/dev/null || true

########################################
# DONE
########################################

echo "Snapshot created at: $SNAP_DIR"
