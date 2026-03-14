### Pi5 Server


Core:  
Tailscale  
Podman  
Caddy  




Filesystem: Key files

```text
/ (root)
├─ bin/                 # Essential binaries
├─ boot/                # Raspberry Pi bootloader & kernel files
├─ dev/                 # Device files
├─ etc/                 # Configuration files
│   ├─ caddy/           # Caddy configuration
│   │   └─ Caddyfile
│   ├─ docker/          # Docker daemon config
│   │   └─ daemon.json
│   ├─ containers/      # Podman configuration
│   │   ├─ containers.conf
│   │   └─ registries.conf
│   └─ tailscale/       # Tailscale config (optional)
├─ home/                # User home directories
│   └─ pi/
├─ lib/                 # Libraries
├─ media/               # Auto-mounted removable media
├─ mnt/                 # Temporary mounts
├─ opt/                 # Optional 3rd-party apps
├─ proc/                # Kernel and process info
├─ root/                # Root user home
├─ run/                 # Runtime variable files
├─ sbin/                # System binaries
├─ srv/                 # Service data & website files
│   └─ websites/
│       ├─ nav/             # Navbar & shared JS/CSS
│       │   ├─ navbar.yaml
│       │   ├─ navbar.js
│       │   └─ navbar.css
│       ├─ shared/          # Shared CSS/assets
│       ├─ docs/            # MkDocs site
│       ├─ wiki/            # Wiki site
│       ├─ blog/            # Hugo/blog site
│       └─ products/        # Marketing / landing pages
├─ sys/                 # Kernel interface
├─ tmp/                 # Temporary files
├─ usr/                 # User binaries, libraries
└─ var/                 # Variable data
    ├─ lib/             # Daemon runtime data
    │   ├─ caddy/       # Certificates, cache
    │   ├─ docker/      # Images, containers, volumes
    │   ├─ containers/  # Podman system-wide containers
    │   └─ tailscale/   # State files & auth keys
    └─ log/             # Logs
        ├─ caddy/
        ├─ docker/
        └─ tailscale/
```
