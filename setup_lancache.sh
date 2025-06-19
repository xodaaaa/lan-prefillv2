#!/bin/bash

# Instalar dependencias
sudo apt update
sudo apt install -y apt-transport-https ca-certificates software-properties-common docker-compose docker.io

# Clonar el repositorio si no existe
if [ ! -d "lancache" ]; then
  git clone https://github.com/lancachenet/docker-compose lancache
fi
cd lancache

# Detectar IP local
IP_LOCAL=$(hostname -I | awk '{print $1}')

# Modificar el archivo .env
sed -i "s/^LANCACHE_IP=.*/LANCACHE_IP=${IP_LOCAL}/" .env
sed -i "s/^DNS_BIND_IP=.*/DNS_BIND_IP=${IP_LOCAL}/" .env
sed -i "s/^UPSTREAM_DNS=.*/UPSTREAM_DNS=1.1.1.1/" .env
sed -i "s/^CACHE_DISK_SIZE=.*/CACHE_DISK_SIZE=350g/" .env
sed -i "s/^CACHE_INDEX_SIZE=.*/CACHE_INDEX_SIZE=250m/" .env

# Levantar los contenedores
sudo docker-compose up -d

# Esperar a que se creen los contenedores
sleep 10

# Obtener nombres de los contenedores
CONTS=$(sudo docker ps --format "{{.Names}}" | grep -E 'lancache|lancache-dns')

# Añadir restart always
for c in $CONTS; do
  sudo docker update --restart always "$c"
done

echo "Lancache listo y configurado."