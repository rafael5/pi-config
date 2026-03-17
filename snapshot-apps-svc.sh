#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Snapshot Script: Application & Services Capture (APT + systemd)
#
# This script creates a timestamped snapshot of the system’s key application
# and service state under:
#   ~/pi-config/snapshots/YYYY-MM-DD-HH-MM/
#
# Purpose:
#   - Track and diff installed packages over time
#   - Monitor active and enabled services
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
#   └─ services/
#       ├─ active-services.txt     # Currently running services
#       └─ enabled-services.txt    # Services enabled at boot
#
# Notes:
#   - This version does **not** capture /etc or /usr/local/etc to avoid
#     permission errors from protected system files.
#   - Service listings use sudo to ensure all system-level units are included.
#   - Output is structured for easy comparison and diffing between snapshots.
# -----------------------------------------------------------------------------

set -euo pipefail

# Base directory
BASE_DIR="$HOME/pi-config/snapshots"
TIMESTAMP="$(date +'%Y-%m-%d-%H-%M')"
SNAP_DIR="$BASE_DIR/$TIMESTAMP"

# Create directory structure
mkdir -p "$SNAP_DIR/packages/apt-sources"
mkdir -p "$SNAP_DIR/services"

########################################
# PACKAGES
########################################

# dpkg selections (full package state)
dpkg --get-selections > "$SNAP_DIR/packages/dpkg-selections.txt"

# apt manual (user-installed packages)
apt-mark showmanual > "$SNAP_DIR/packages/apt-manual.txt"

# apt installed (versions)
apt list --installed > "$SNAP_DIR/packages/apt-installed.txt"

# apt sources (repositories)
cp /etc/apt/sources.list "$SNAP_DIR/packages/apt-sources/sources.list"
cp -r /etc/apt/sources.list.d "$SNAP_DIR/packages/apt-sources/"

########################################
# SERVICES (requires sudo)
########################################

# active services
sudo systemctl list-units --type=service --state=active > "$SNAP_DIR/services/active-services.txt"

# enabled services
sudo systemctl list-unit-files --type=service --state=enabled > "$SNAP_DIR/services/enabled-services.txt"

########################################
# DONE
########################################

echo "Application & service snapshot created at: $SNAP_DIR"
