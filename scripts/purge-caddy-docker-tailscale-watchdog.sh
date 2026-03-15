

#!/bin/bash
# =========================================
# DEEP CLEAN SCRIPT - DOCKER, CADDY, TAILSCALE, WATCHDOG
# WARNING: Destructive. Backup before running.
# =========================================

set -euo pipefail

echo "=== Starting deep clean of Docker, Caddy, Tailscale, Watchdog ==="

# --- Stop services if running ---
services=(docker docker.socket containerd caddy tailscale tailscaled watchdog)
for svc in "${services[@]}"; do
    echo "[*] Stopping $svc if active..."
    sudo systemctl stop "$svc" 2>/dev/null || true
    sudo systemctl disable "$svc" 2>/dev/null || true
    sudo systemctl mask "$svc" 2>/dev/null || true
done

# --- Remove systemd units ---
unit_paths=(/etc/systemd/system /lib/systemd/system ~/.config/systemd/user)
for path in "${unit_paths[@]}"; do
    echo "[*] Removing unit files in $path ..."
    sudo find "$path" -type f \( -iname "*docker*" -o -iname "*caddy*" -o -iname "*tailscale*" -o -iname "*watchdog*" \) -exec rm -f {} \;
done
sudo systemctl daemon-reload

# --- Remove packages ---
packages=(docker docker.io docker-compose docker-ce docker-ce-cli containerd runc caddy tailscale watchdog)
for pkg in "${packages[@]}"; do
    echo "[*] Purging package: $pkg"
    sudo apt-get purge -y "$pkg" || true
done

# --- Remove snaps ---
snaps=(docker caddy)
for snap in "${snaps[@]}"; do
    echo "[*] Removing snap: $snap"
    sudo snap remove "$snap" || true
done

# --- Remove binaries and scripts ---
paths=(/usr/local/bin /usr/bin /usr/sbin /usr/local/sbin)
for p in "${paths[@]}"; do
    sudo find "$p" -type f \( -iname "*docker*" -o -iname "*caddy*" -o -iname "*tailscale*" -o -iname "*watchdog*" \) -exec rm -f {} \;
done

# --- Remove configs, logs, and data ---
dirs=(/etc/docker /var/lib/docker /var/run/docker /var/log/docker \
      /etc/caddy /var/lib/caddy /var/log/caddy \
      /etc/tailscale /var/lib/tailscale /var/log/tailscale \
      /etc/watchdog /var/lib/watchdog /var/log/watchdog)
for d in "${dirs[@]}"; do
    echo "[*] Removing $d"
    sudo rm -rf "$d" || true
done

# --- Remove aliases and environment entries ---
bashrc_files=(~/.bashrc ~/.profile ~/.bash_aliases)
for f in "${bashrc_files[@]}"; do
    if [ -f "$f" ]; then
        echo "[*] Cleaning aliases in $f"
        sudo sed -i '/docker/d;/caddy/d;/tailscale/d;/watchdog/d' "$f"
    fi
done

# --- Remove cron jobs ---
echo "[*] Removing cron jobs related to Docker, Caddy, Tailscale, Watchdog"
crontab -l | grep -v -E "docker|caddy|tailscale|watchdog" | crontab -

# --- Remove remaining symlinks ---
echo "[*] Removing symlinks in /etc/systemd/system pointing to these services"
sudo find /etc/systemd/system -type l \( -iname "*docker*" -o -iname "*caddy*" -o -iname "*tailscale*" -o -iname "*watchdog*" \) -exec rm -f {} \;

# --- Clean package cache ---
sudo apt-get autoremove -y
sudo apt-get autoclean -y

echo "=== Deep clean completed. Reboot recommended ==="
