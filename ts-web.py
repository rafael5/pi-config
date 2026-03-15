#!/usr/bin/env python3
from http.server import HTTPServer, BaseHTTPRequestHandler

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"Tailscale node is up!\n")

HOST = "127.0.0.1"
PORT = 8080

httpd = HTTPServer((HOST, PORT), Handler)
print(f"Serving on {HOST}:{PORT}")
httpd.serve_forever()
