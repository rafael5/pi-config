# Generate completion script
caddy completion bash > /tmp/caddy_completion.sh

 COMPLETION_DIR="/etc/bash_completion.d"

# Move the script and set permissions
sudo mv /tmp/caddy_completion.sh "$COMPLETION_DIR/caddy"
sudo chmod 644 "$COMPLETION_DIR/caddy"

# Load completions immediately
source "$COMPLETION_DIR/caddy"

# Verify
echo "Caddy Bash completions installed. Try: caddy <TAB>"
