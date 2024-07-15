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
