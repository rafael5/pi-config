#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Snapshot Script: Comprehensive System State (Packages, Services, Configs, 
# Dotfiles, OS/Kernel, Scheduler, Docker, Podman, Tailscale)
#
# This script creates a timestamped snapshot of the system’s state under:
#   ~/pi-config/snapshots/YYYY-MM-DD-HH-MM/
#
# Purpose:
#   - Track and diff installed packages over time
#   - Monitor active and enabled services
#   - Capture top-level system configuration files from /etc
#   - Capture selected user-level configuration via allowlisted dotfiles
#   - Record kernel and OS metadata
#   - Record scheduled jobs (cron + systemd timers)
#   - Record container runtime state (Docker + Podman)
#   - Record Tailscale configuration for reproducibility
#   - Enable auditing, troubleshooting, rollback, and partial system reconstruction
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
#   │   └─ etc/                   # Top-level files from /etc only
#   │
#   ├─ home/
#   │   └─ dotfiles/              # Allowlisted user dotfiles
#   │
#   ├─ services/
#   │   ├─ active-services.txt
#   │   └─ enabled-services.txt
#   │
#   ├─ system/
#   │   ├─ uname.txt              # Kernel and architecture
#   │   └─ os-release.txt         # OS distribution metadata
#   │
#   ├─ scheduler/
#   │   ├─ user-cron.txt
#   │   ├─ root-cron.txt
#   │   └─ systemd-timers.txt
#   │
#   ├─ docker/
#   │   ├─ containers.txt
#   │   ├─ images.txt
#   │   └─ volumes.txt
#   │
#   ├─ podman/
#   │   ├─ containers.txt
#   │   ├─ images.txt
#   │   └─ volumes.txt
#   │
#   └─ tailscale/
#       └─ status.txt
#
# Security Model:
#   - Only allowlisted dotfiles are captured (no wildcards)
#   - /etc capture limited to top-level files to reduce risk
#   - Docker, Podman, and Tailscale captures are metadata/config only
#   - Secrets (tokens, private keys) are excluded by default
#   - Unreadable files are skipped safely
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
mkdir -p "$SNAP_DIR/podman"
mkdir -p "$SNAP_DIR/tailscale"

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
  [[ -f "$HOME/$file" ]] && cp "$HOME/$file" "$SNAP_DIR/home/dotfiles/"
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
# DOCKER
########################################

docker ps -a > "$SNAP_DIR/docker/containers.txt" 2>/dev/null || true
docker images > "$SNAP_DIR/docker/images.txt" 2>/dev/null || true
docker volume ls > "$SNAP_DIR/docker/volumes.txt" 2>/dev/null || true

########################################
# PODMAN
########################################

podman ps -a > "$SNAP_DIR/podman/containers.txt" 2>/dev/null || true
podman images > "$SNAP_DIR/podman/images.txt" 2>/dev/null || true
podman volume ls > "$SNAP_DIR/podman/volumes.txt" 2>/dev/null || true

########################################
# TAILSCALE
########################################

tailscale status > "$SNAP_DIR/tailscale/status.txt" 2>/dev/null || true

########################################
# DONE
########################################

echo "Comprehensive snapshot created at: $SNAP_DIR"
