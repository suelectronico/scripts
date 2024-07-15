#!/bin/bash

# Verificar si el script se está ejecutando como root
if [ "$EUID" -ne 0 ]; then 
  echo "Por favor, ejecute el script como root."
  exit 1
fi

# Ejecutar el comando pacstrap
pacstrap /mnt base base-devel neovim linux linux-firmware linux-headers mkinitcpio

# Verificar si el comando se ejecutó correctamente
if [ $? -eq 0 ]; then
  echo "Comandos ejecutados con éxito."
else
  echo "Error al ejecutar los comandos."
  exit 1
fi
echo "Instalación de archivos base correcta..."

echo "Generando fstab..."
genfstab -p /mnt >> /mnt/etc/fstab
if [ $? -ne 0 ]; then
  echo "Error al generar fstab."
  exit 1
fi
echo "fstab generado correctamente."

echo "Iniciando arch-chroot"
arch-chroot /mnt
if [ $? -ne 0 ]; then
  echo "Error en el entorno arch-chroot."
  exit 1
fi
echo "arch-chroot completado correctamente."
