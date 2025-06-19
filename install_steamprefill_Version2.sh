#!/bin/bash

set -e

# Instalar dependencias necesarias
apt-get update
apt-get install curl jq unzip wget -y

# Crear carpeta y descargar scripts
mkdir -p SteamPrefill
cd SteamPrefill/
curl -o update.sh --location "https://raw.githubusercontent.com/tpill90/steam-lancache-prefill/master/scripts/update.sh"
chmod +x update.sh
./update.sh
chmod +x ./SteamPrefill

# Ejecutar seleccionador interactivo (el usuario interactúa aquí)
./SteamPrefill select-apps

# Cuando el usuario termine la selección, el script continúa aquí

# Crear archivo steamprefill.timer
cat <<EOF > /etc/systemd/system/steamprefill.timer
[Unit]
Description=SteamPrefill run daily
Requires=steamprefill.service

[Timer]
# Runs every day at 4am (local time)
OnCalendar=*-*-* 4:00:00

# Set to true so we can store when the timer last triggered on disk.
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Crear archivo steamprefill.service
cat <<EOF > /etc/systemd/system/steamprefill.service
[Unit]
Description=SteamPrefill
After=remote-fs.target
Wants=remote-fs.target

[Service]
Type=oneshot
# Sets the job to the lowest priority
Nice=19
User=root
WorkingDirectory=/root/SteamPrefill
ExecStart=/root/SteamPrefill/SteamPrefill prefill --no-ansi

[Install]
WantedBy=multi-user.target
EOF

# Recargar systemd y activar los servicios
systemctl daemon-reload
systemctl enable --now steamprefill.timer
systemctl enable steamprefill

# Mostrar estado del timer
systemctl status steamprefill.timer