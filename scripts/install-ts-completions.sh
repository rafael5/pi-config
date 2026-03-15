#!/bin/bash
# install-tailscale-completions.sh
# Installs Tailscale bash completions system-wide on Debian/Raspberry Pi

set -e

# Generate the bash completion script
echo "Generating Tailscale bash completions..."
sudo tailscale completion bash > /tmp/tailscale_completion.sh

# Target directory for system-wide completions
COMPLETION_DIR="/etc/bash_completion.d"

# Ensure directory exists
sudo mkdir -p "$COMPLETION_DIR"

# Move the completion script into place
sudo mv /tmp/tailscale_completion.sh "$COMPLETION_DIR/tailscale"
sudo chmod 644 "$COMPLETION_DIR/tailscale"

# Load completions immediately for current session
if [ -n "$BASH_VERSION" ]; then
    source "$COMPLETION_DIR/tailscale"
fi

echo "Tailscale bash completions installed in $COMPLETION_DIR."
echo "Restart your shell or run 'source ~/.bashrc' to enable completions permanently."
