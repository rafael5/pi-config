#!/bin/bash
# Filename: restart-services.sh
# Purpose: Restart and reload Tailscale and Caddy services on Raspberry Pi

set -e

echo "=== Restarting Tailscale ==="
sudo systemctl restart tailscaled
sleep 2
sudo tailscale status

echo
echo "=== Restarting Caddy ==="
sudo systemctl restart caddy
sleep 2
sudo systemctl status caddy --no-pager

echo
echo "=== Reloading Caddy configuration ==="
sudo caddy reload --config /etc/caddy/Caddyfile

echo
echo "All services restarted and Caddy configuration reloaded successfully."
