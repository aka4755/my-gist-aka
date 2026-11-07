#!/usr/bin/env python3
import datetime
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

PORT = 8000
LOG_FILE = "received.log"
MAX_BODY = 1_000_000


class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers.get("Content-Length") or 0)
        if length > MAX_BODY:
            self.send_response(413)
            self.end_headers()
            return
        body = self.rfile.read(length).decode("utf-8", "replace")
        line = "[%s] %s" % (datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"), body)
        print(line, flush=True)
        with open(LOG_FILE, "a") as f:
            f.write(line + "\n")
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.end_headers()
        self.wfile.write(b"OK")

    def do_GET(self):
        try:
            with open(LOG_FILE) as f:
                data = f.read()
        except FileNotFoundError:
            data = "(nothing received yet)"
        self.send_response(200)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.end_headers()
        self.wfile.write(data.encode())

    def log_message(self, *args):
        pass


if __name__ == "__main__":
    print("Receiver on 0.0.0.0:%d  (POST data here; open http://<this-device-ip>:%d in a browser to view)" % (PORT, PORT))
    ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
