#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Snapshot Script: Application, Services, Config Files, and User Dotfiles
# (APT + systemd + /etc top-level files + allowlisted $HOME dotfiles)
#
# This script creates a timestamped snapshot of the system’s key application,
# service, and configuration state under:
#   ~/pi-config/snapshots/YYYY-MM-DD-HH-MM/
#
# Purpose:
#   - Track and diff installed packages over time
#   - Monitor active and enabled services
#   - Capture top-level system configuration files from /etc
#   - Capture selected user-level configuration via safe dotfiles
#   - Enable auditing, troubleshooting, and reproducibility of system state
#
# Snapshot filesystem:
#   ~/pi-config/snapshots/YYYY-MM-DD-HH-MM/
#   ├─ packages/
#   │   ├─ dpkg-selections.txt     # Complete package selection state
#   │   ├─ apt-manual.txt          # User-installed packages
#   │   ├─ apt-installed.txt       # Installed packages with versions
#   │   └─ apt-sources/            # Repositories
#   │       ├─ sources.list
#   │       └─ sources.list.d/
#   │
#   ├─ config/
#   │   └─ etc/                   # ONLY top-level files from /etc (no subdirs)
#   │       ├─ hosts
#   │       ├─ hostname
#   │       ├─ fstab
#   │       └─ ...
#   │
#   ├─ home/
#   │   └─ dotfiles/              # SAFE allowlisted dotfiles only
#   │       ├─ .bashrc
#   │       ├─ .profile
#   │       ├─ .gitconfig
#   │       └─ ...
#   │
#   └─ services/
#       ├─ active-services.txt     # Currently running services
#       └─ enabled-services.txt    # Services enabled at boot
#
# Security Model:
#   - Dotfiles are captured using an explicit allowlist (not wildcard matching).
#   - Prevents accidental inclusion of sensitive files such as:
#       .bash_history, .zsh_history, .ssh/, .gnupg/, tokens, credentials
#   - Only known-safe configuration files are included.
#   - /etc capture is limited to top-level files to reduce exposure and size.
#   - Unreadable files are skipped without failing the script.
#   - This minimizes risk of leaking secrets into version control.
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
)

for file in "${DOTFILES[@]}"; do
  if [[ -f "$HOME/$file" ]]; then
    cp "$HOME/$file" "$SNAP_DIR/home/dotfiles/"
  fi
done

# Optional: safe sub-config example
if [[ -f "$HOME/.config/starship.toml" ]]; then
  mkdir -p "$SNAP_DIR/home/dotfiles/.config"
  cp "$HOME/.config/starship.toml" "$SNAP_DIR/home/dotfiles/.config/"
fi

########################################
# SERVICES (requires sudo)
########################################

sudo systemctl list-units --type=service --state=active > "$SNAP_DIR/services/active-services.txt"
sudo systemctl list-unit-files --type=service --state=enabled > "$SNAP_DIR/services/enabled-services.txt"

########################################
# DONE
########################################

echo "Snapshot created at: $SNAP_DIR"
