import os
import socket
from datetime import datetime, timezone

from flask import Flask, jsonify

app = Flask(__name__)

VERSION = os.getenv("APP_VERSION", "dev")
ENVIRONMENT = os.getenv("APP_ENV", "dev")
TEAM = os.getenv("APP_TEAM", "SPIDERMAN")


@app.get("/")
def index():
    return f"""<!doctype html>
<html lang="es"><head><meta charset="utf-8"><title>Taller 2 - Infraestructura para TI</title>
<style>body{{font-family:system-ui;margin:3rem auto;max-width:640px;line-height:1.6}}
code{{background:#eee;padding:2px 6px;border-radius:4px}}</style></head>
<body>
<h1>Taller 2: Docker + Ansible en AWS</h1>
<p>Equipo: <b>{TEAM}</b></p>
<p>Ambiente: <code>{ENVIRONMENT}</code></p>
<p>Versión desplegada: <code>{VERSION[:12]}</code></p>
<p>Contenedor: <code>{socket.gethostname()}</code></p>
<p><a href="/health">/health</a> | <a href="/api/info">/api/info</a></p>
</body></html>"""


@app.get("/health")
def health():
    return jsonify(status="ok"), 200


@app.get("/api/info")
def info():
    return jsonify(
        team=TEAM,
        environment=ENVIRONMENT,
        version=VERSION,
        container=socket.gethostname(),
        time=datetime.now(timezone.utc).isoformat(),
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
