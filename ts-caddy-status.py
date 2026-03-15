#!/usr/bin/env python3
import subprocess
from http.server import HTTPServer, BaseHTTPRequestHandler
import ssl
import os

# ------------------------
# Configuration
# ------------------------
HOST = "0.0.0.0"
PORT = 8443
TAILSCALE_CERT = "/var/lib/tailscale/certs/pi5.warg-torino.ts.net.crt"
TAILSCALE_KEY = "/var/lib/tailscale/certs/pi5.warg-torino.ts.net.key"

CADDY_SERVICE = "caddy.service"
TAILSCALE_SERVICE = "tailscaled.service"

# ------------------------
# Helper functions
# ------------------------
def get_service_status(service_name):
    try:
        result = subprocess.run(
            ["systemctl", "is-active", service_name],
            capture_output=True, text=True
        )
        return result.stdout.strip()
    except Exception as e:
        return f"Error: {e}"

def get_service_info(service_name):
    try:
        result = subprocess.run(
            ["systemctl", "status", service_name, "--no-pager"],
            capture_output=True, text=True
        )
        return "<pre>" + result.stdout + "</pre>"
    except Exception as e:
        return f"<pre>Error: {e}</pre>"

# ------------------------
# HTTP Request Handler
# ------------------------
class StatusHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()

        html = f"""
        <html>
        <head>
            <title>Tailscale & Caddy Status</title>
            <style>
                body {{ font-family: monospace; background: #f4f4f4; padding: 20px; }}
                h1 {{ color: #2a7ae2; }}
                .service {{ margin-bottom: 20px; }}
            </style>
        </head>
        <body>
            <h1>Pi5 Status Page</h1>

            <div class="service">
                <h2>Caddy Service</h2>
                <p>Status: {get_service_status(CADDY_SERVICE)}</p>
                {get_service_info(CADDY_SERVICE)}
            </div>

            <div class="service">
                <h2>Tailscale Service</h2>
                <p>Status: {get_service_status(TAILSCALE_SERVICE)}</p>
                {get_service_info(TAILSCALE_SERVICE)}
            </div>

            <div class="service">
                <h2>Tailscale IPs</h2>
                <pre>{subprocess.getoutput("tailscale status")}</pre>
            </div>
        </body>
        </html>
        """
        self.wfile.write(html.encode("utf-8"))

# ------------------------
# Start HTTPS server
# ------------------------
httpd = HTTPServer((HOST, PORT), StatusHandler)

context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
context.load_cert_chain(certfile=TAILSCALE_CERT, keyfile=TAILSCALE_KEY)

httpd.socket = context.wrap_socket(httpd.socket, server_side=True)

print(f"Serving HTTPS on {HOST}:{PORT}")
httpd.serve_forever()
