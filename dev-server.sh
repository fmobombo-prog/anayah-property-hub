#!/bin/sh
# Static dev server for the single-file Anayah Gestim app.
# Extra CLI args appended by the platform (e.g. --port) are ignored.
exec python3 -m http.server 8080 --bind 0.0.0.0
