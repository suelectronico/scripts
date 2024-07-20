#!/bin/bash

# Comprobar si se ha especificado el dispositivo como argumento
if [ -z "$1" ]; then
    echo "Uso: $0 <dispositivo>"
    echo "Ejemplo: $0 /dev/sdX"
    exit 1
fi

DEVICE=$1

# Validar que el dispositivo existe
if [ ! -b "$DEVICE" ]; then
    echo "El dispositivo $DEVICE no existe o no es un bloque válido."
    exit 1
fi

# Confirmar antes de proceder
read -p "Esto borrará todos los datos en $DEVICE. ¿Estás seguro? (escribe 'SI' para continuar): " CONFIRM
if [ "$CONFIRM" != "SI" ]; then
    echo "Operación cancelada."
    exit 1
fi

# Limpiar la tabla de particiones existente
sudo parted -s $DEVICE mklabel gpt

# Crear la partición FAT32 de 300MB
sudo parted -s -a optimal $DEVICE mkpart primary fat32 0% 300MB
sudo parted -s $DEVICE set 1 boot on

# Crear la partición root del 30%
sudo parted -s -a optimal $DEVICE mkpart primary ext4 300MB 25%

# Crear la partición home del 30%
sudo parted -s -a optimal $DEVICE mkpart primary ext4 25% 50%

# Crear la partición almacén con el resto del espacio
sudo parted -s -a optimal $DEVICE mkpart primary ext4 50% 75%

# Crear la partición para máquinas virtuales con el resto del espacio
sudo parted -s -a optimal $DEVICE mkpart primary ext4 75% 100%

# Formatear las particiones
echo "Formateando las particiones..."
sudo mkfs.vfat -F 32 ${DEVICE}1
sudo mkfs.ext4 ${DEVICE}2
sudo mkfs.ext4 ${DEVICE}3
sudo mkfs.ext4 ${DEVICE}4
sudo mkfs.ext4 ${DEVICE}5

# Montar las particiones
echo "Montando las particiones..."
sudo mount ${DEVICE}2 /mnt/
sudo mkdir -p /mnt/boot/efi/
sudo mount ${DEVICE}1 /mnt/boot/efi/
sudo mkdir -p /mnt/home /mnt/box/ /mnt/vm/
sudo mount ${DEVICE}3 /mnt/home/
sudo mount ${DEVICE}4 /mnt/box/
sudo mount ${DEVICE}5 /mnt/vm/

echo "Particiones y formateo completados en $DEVICE:"
sudo parted $DEVICE print

echo "Las particiones han sido creadas, formateadas y montadas:"
echo "/mnt         -> ${DEVICE}2 (root)"
echo "/mnt/boot/efi -> ${DEVICE}1 (boot)"
echo "/mnt/home    -> ${DEVICE}3 (home)"
echo "/mnt/almacen -> ${DEVICE}4 (almacen)"
echo "/mnt/almacen -> ${DEVICE}4 (maquinas virtuales)"

echo "Generando fstab..."
genfstab -p /mnt >> /mnt/etc/fstab
if [ $? -ne 0 ]; then
  echo "Error al generar fstab."
  exit 1
fi
echo "fstab generado correctamente."
