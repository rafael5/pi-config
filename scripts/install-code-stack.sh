#!/usr/bin/env bash
set -e

# ------------------------------
# 1. Stack root
# ------------------------------
STACK_ROOT=$HOME/code-stack
mkdir -p $STACK_ROOT/{containers/caddy,containers/vscode/{config,workspace},containers/gitea/{config,data},containers/filebrowser/{config,data},containers/jupyter/{config,notebooks},scripts}

# ------------------------------
# 2. Environment file
# ------------------------------
cat > $STACK_ROOT/.env <<'EOF'
STACK_ROOT=$HOME/code-stack
HOSTNAME=pi5.warg-torino.ts.net

VSCODE_PORT=8443
GITEA_PORT=3000
FILEBROWSER_PORT=8082
JUPYTER_PORT=8888
CADDY_PORT=8081

VSCODE_PASSWORD=admin

PUID=$(id -u)
PGID=$(id -g)
TZ=$(cat /etc/timezone)
EOF

# ------------------------------
# 3. Caddyfile (HTTP, 0.0.0.0)
# ------------------------------
cat > $STACK_ROOT/containers/caddy/Caddyfile <<EOF
http://0.0.0.0:{CADDY_PORT} {
    encode gzip

    handle_path /code* {
        reverse_proxy 127.0.0.1:8443
    }

    handle_path /git* {
        reverse_proxy 127.0.0.1:3000
    }

    handle_path /files* {
        reverse_proxy 127.0.0.1:8082
    }

    handle_path /jupyter* {
        reverse_proxy 127.0.0.1:8888
    }
}
EOF

# ------------------------------
# 4. Start Script
# ------------------------------
cat > $STACK_ROOT/scripts/start-stack.sh <<'EOF'
#!/usr/bin/env bash
set -e
source $HOME/code-stack/.env

echo "Starting code-stack..."

# Remove old containers
podman rm -f vscode gitea filebrowser jupyter 2>/dev/null || true

# VS Code
podman run -d \
  --name vscode \
  -p 0.0.0.0:${VSCODE_PORT}:8443 \
  -v ${STACK_ROOT}/containers/vscode/config:/config \
  -v ${STACK_ROOT}/containers/vscode/workspace:/config/workspace \
  -e PASSWORD=${VSCODE_PASSWORD} \
  -e PUID=${PUID} \
  -e PGID=${PGID} \
  docker.io/linuxserver/code-server:latest

# Gitea
podman run -d \
  --name gitea \
  -p 0.0.0.0:${GITEA_PORT}:3000 \
  -v ${STACK_ROOT}/containers/gitea/data:/data \
  docker.io/gitea/gitea:latest

# Filebrowser
podman run -d \
  --name filebrowser \
  -p 0.0.0.0:${FILEBROWSER_PORT}:8080 \
  -v ${STACK_ROOT}/containers/filebrowser/data:/srv \
  -v ${STACK_ROOT}/containers/filebrowser/config:/config \
  docker.io/filebrowser/filebrowser:latest

# Jupyter
podman run -d \
  --name jupyter \
  -p 0.0.0.0:${JUPYTER_PORT}:8888 \
  -v ${STACK_ROOT}/containers/jupyter/notebooks:/home/jovyan/work \
  docker.io/jupyter/base-notebook:latest

# Start Caddy
CADDYFILE=$STACK_ROOT/containers/caddy/Caddyfile
pkill -f "caddy run --config $CADDYFILE" 2>/dev/null || true
caddy run --config $CADDYFILE --adapter caddyfile &

sleep 2

echo "All containers started."
echo "Access via Tailscale MagicDNS (HTTP, port ${CADDY_PORT}):"
echo "http://${HOSTNAME}:${CADDY_PORT}/code"
echo "http://${HOSTNAME}:${CADDY_PORT}/git"
echo "http://${HOSTNAME}:${CADDY_PORT}/files"
echo "http://${HOSTNAME}:${CADDY_PORT}/jupyter"
EOF

# ------------------------------
# 5. Stop Script
# ------------------------------
cat > $STACK_ROOT/scripts/stop-stack.sh <<'EOF'
#!/usr/bin/env bash
source $HOME/code-stack/.env

echo "Stopping code-stack..."
podman stop vscode gitea filebrowser jupyter 2>/dev/null || true
pkill -f "caddy run --config $STACK_ROOT/containers/caddy/Caddyfile" || true
EOF

# ------------------------------
# 6. Update Script
# ------------------------------
cat > $STACK_ROOT/scripts/update-stack.sh <<'EOF'
#!/usr/bin/env bash
echo "Pulling latest container images..."
podman pull docker.io/linuxserver/code-server:latest
podman pull docker.io/gitea/gitea:latest
podman pull docker.io/filebrowser/filebrowser:latest
podman pull docker.io/jupyter/base-notebook:latest
EOF

# ------------------------------
# 7. Make scripts executable
# ------------------------------
chmod +x $STACK_ROOT/scripts/*.sh

# ------------------------------
# 8. Summary
# ------------------------------
echo "Setup complete. Scripts created in $STACK_ROOT/scripts"
echo "Start the stack:"
echo "$STACK_ROOT/scripts/start-stack.sh"
echo "Stop the stack:"
echo "$STACK_ROOT/scripts/stop-stack.sh"
echo "Update containers:"
echo "$STACK_ROOT/scripts/update-stack.sh"
