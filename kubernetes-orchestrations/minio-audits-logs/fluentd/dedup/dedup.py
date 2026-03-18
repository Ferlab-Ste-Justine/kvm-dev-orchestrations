#!/usr/bin/env python3

import json
import logging
import os
import sys
import threading
import time
import urllib.request
import urllib.error
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

LISTEN_HOST = "127.0.0.1"
LISTEN_PORT = 8181

FORWARD_HOST = "127.0.0.1"
FORWARD_PORT = 8080

CACHE_TTL = int(os.environ.get("CACHE_TTL", "300"))

class DedupCache:
    def __init__(self, ttl: int, logger):
        self.ttl = ttl
        self._data = {}
        self._logger = logger
        self._lock = threading.Lock()
    
    def proceed(self, key: str) -> bool:
        with self._lock:
            now = int(time.time())
            if key not in self._data.keys() or self._data[key] < now:
                self._data[key] = now + self.ttl
                self._logger.debug(f"Caching key {key} for until {self._data[key]} seconds after epoch")
                return True
            return False

class DedupProxyHandler(BaseHTTPRequestHandler):
    forward_url = f"http://{FORWARD_HOST}:{FORWARD_PORT}"

    def do_POST(self) -> None:
        self._handle_request()

    def _handle_request(self) -> None:
        content_length_header = self.headers.get("Content-Length")
        if content_length_header is None:
            self._send_json(400, {"error": "Missing Content-Length header"})
            return

        try:
            content_length = int(content_length_header)
        except ValueError:
            self._send_json(400, {"error": "Invalid Content-Length header"})
            return

        content_type = self.headers.get('Content-Type', '')
        if content_type != 'application/json':
            self._send_json(400, {"error": "Content-Type header should be application/json"})
            return
        
        raw_body = self.rfile.read(content_length)
        self.server.logger.debug(f"Got request with body: {raw_body}")
        
        try:
            body = json.loads(raw_body)
        except json.JSONDecodeError:
            self._send_json(400, {"error": "Request body is not valid JSON"})
            return

        cache = self.server.cache

        tag = self.headers.get("X-Fluentd-Tag", "")

        for event in body:
            if not isinstance(event, dict):
                self._send_json(400, {"error": "JSON body must be an object"})
                return
            
            dedup_key = event.get("dedup_key")  
            if dedup_key and not cache.proceed(str(dedup_key)):
                self.server.logger.debug(f"Dedub key \"{dedup_key}\" in cache and not expired. Request will not be forwarded.")
                self._send_json(204, None)
                return

            event_str = json.dumps(event).encode("utf-8")
            self.server.logger.debug(f"Forwarding event {event_str}")
            done = self._forward_event(event_str, tag)

            if done:
                return
        
        self._send_json(200, None)

    def _forward_event(self, event_str: bytes, tag: str) -> bool:
        headers = {}
        for key, value in self.headers.items():
            key_lower = key.lower()
            if key_lower in {"host", "connection"}:
                continue
            headers[key] = value

        headers["content-length"] = len(event_str)

        req = urllib.request.Request(
            url=f"{DedupProxyHandler.forward_url}/{tag}",
            data=event_str,
            headers=headers,
            method=self.command,
        )

        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                resp_body = resp.read()
                self.server.logger.debug(f"Got response status '{resp.status}' and body '{resp_body}'")

        except urllib.error.HTTPError as err:
            resp_body = err.read()
            self.send_response(err.code)

            for key, value in err.headers.items():
                key_lower = key.lower()
                if key_lower in {"transfer-encoding", "connection", "content-length"}:
                    continue
                self.send_header(key, value)

            self.send_header("Content-Length", str(len(resp_body)))
            self.end_headers()
            self.wfile.write(resp_body)
            return True

        except Exception as err:
            self._send_json(502, {"error": "Failed to forward request", "details": str(err)})
            return True

    def _send_json(self, status_code: int, payload) -> None:
        self.send_response(status_code)

        if payload is None:
            self.send_header("Content-Length", "0")
            self.end_headers()
            return

        data = json.dumps(payload).encode("utf-8")
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

class DedupHTTPServer(ThreadingHTTPServer):
    def __init__(self, server_address, handler_class, cache: Cache, logger):
        super().__init__(server_address, handler_class)
        self.cache = cache
        self.logger = logger

def main() -> None:
    logging.basicConfig(
        stream=sys.stdout,
        level=logging.DEBUG,
        format='%(asctime)s [%(levelname)s] %(message)s'
    )
    logger = logging.getLogger(__name__)

    server = DedupHTTPServer((LISTEN_HOST, LISTEN_PORT), DedupProxyHandler, DedupCache(CACHE_TTL, logger), logger)
    logger.info(f"Started server listening on \"http://{LISTEN_HOST}:{LISTEN_PORT}\", forwarding to: \"http://{FORWARD_HOST}:{FORWARD_PORT}\" with TTL of {CACHE_TTL}")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()