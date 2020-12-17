#!/bin/bash
set -euxo pipefail

readonly ARCHIVE="$1"

mkdir -p /app/build
cd /app
zip -r9 --exclude="*test*" "${ARCHIVE}" bin
cd .venv/lib/python3.7/site-packages
zip -r9 "${ARCHIVE}" *
cd /src
zip -r9 --exclude="*test*" "${ARCHIVE}" *.py
