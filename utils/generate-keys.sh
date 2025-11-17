#!/usr/bin/env bash

set -xeu

vendor="Placeholder"
mkdir -p files/boot-keys/

# FIXME: sync the keys needed with the gnome-build-meta changes

for f in extra-db extra-kek modules; do
    [ ! -d "files/boot-keys/${f}" ] && mkdir -p "files/boot-keys/${f}"
done

for f in PK KEK DB VENDOR linux-module-cert; do
    [ ! -f "files/boot-keys/${f}.key" ] && [ ! -f "files/boot-keys/${f}.crt" ] && \
        openssl req -new -x509 -newkey rsa:2048 -subj "/CN=${vendor} ${f} key/" -keyout "files/boot-keys/${f}.key" -out "files/boot-keys/${f}.crt" -days 3650 -nodes -sha256
done

cp files/boot-keys/linux-module-cert.crt files/boot-keys/modules/linux-module-cert.crt
