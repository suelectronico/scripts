#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

echo 'Modificando el idioma en /etc/locale.gen...'
sed -i 's/^#\(es_ES.UTF-8 UTF-8\)/\1/' /etc/locale.gen
if [ \$? -ne 0 ]; then
  echo 'Error al modificar /etc/locale.gen.'
  exit 1
fi
echo '/etc/locale.gen modificado correctamente.'
echo 'Ejecutando locale-gen...'
locale-gen
if [ \$? -ne 0 ]; then
  echo 'Error al ejecutar locale-gen.'
  exit 1
fi
echo 'locale-gen ejecutado correctamente.'

echo "Estableciendo el valor de LANG en /etc/locale.conf..."
echo "LANG=es_ES.UTF-8" > /etc/locale.conf
if [ $? -ne 0 ]; then
  echo "Error al establecer el valor de LANG en /etc/locale.conf."
  exit 1
fi
echo "/etc/locale.conf actualizado correctamente."

echo 'Exportando la variable LANG...'
export LANG=es_ES.UTF-8
if [ \$? -ne 0 ]; then
  echo 'Error al exportar la variable LANG.'
  exit 1
fi
echo 'Variable LANG exportada correctamente.'

echo 'Estableciendo la zona horaria...'
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
if [ \$? -ne 0 ]; then
  echo 'Error al establecer la zona horaria.'
  exit 1
fi
echo 'Zona horaria establecida correctamente.'

echo 'Estableciendo la hora del hardware...'
hwclock -w
if [ \$? -ne 0 ]; then
  echo 'Error al establecer la hora del hardware.'
  exit 1
fi
echo 'Hora del hardware establecida correctamente.'

echo 'Estableciendo la configuración del teclado...'
echo KEYMAP=es > /etc/vconsole.conf
if [ \$? -ne 0 ]; then
  echo 'Error al establecer la hora del hardware.'
  exit 1
fi
echo 'Configuración del teclado establecida correctamente.'

read -p "Introduce el nombre del host que deseas configurar: " hostname
if [ -z "$hostname" ]; then
  echo "El nombre del host no puede estar vacío."
  exit 1
fi
echo "Configurando el nombre del host en /etc/hostname..."
echo "$hostname" > /etc/hostname
if [ $? -ne 0 ]; then
  echo "Error al configurar el nombre del host."
  exit 1
fi
echo "/etc/hostname configurado correctamente."

echo "Agregando entradas a /etc/hosts..."
{
  echo -e "127.0.0.1\tlocalhost"
  echo -e "::1\tlocalhost"
  echo -e "127.0.1.1\t${hostname}.localdomain ${hostname}"
} >> /etc/hosts
if [ $? -ne 0 ]; then
  echo "Error al agregar entradas a /mnt/etc/hosts."
  exit 1
fi
echo "/etc/hosts actualizado correctamente."

read -s -p "Introduce la contraseña para el usuario root: " root_password
echo 'Estableciendo la contraseña para el usuario root...'
echo root:$root_password | chpasswd
if [ \$? -ne 0 ]; then
  echo 'Error al establecer la contraseña para el usuario root.'
  exit 1
fi
echo 'Contraseña para el usuario root establecida correctamente.'

read -p "Introduce el nombre del nuevo usuario: " new_user
if [ -z "$new_user" ]; then
  echo "El nombre del nuevo usuario no puede estar vacío."
  exit 1
fi
echo 'Creando nuevo usuario y aplicando configuraciones...'
useradd -m -g users -G wheel -s /bin/bash $new_user
if [ \$? -ne 0 ]; then
  echo 'Error al crear el nuevo usuario.'
  exit 1
fi
read -s -p "Introduce la contraseña para el nuevo usuario: " new_user_password
echo $new_user:$new_user_password | chpasswd
if [ \$? -ne 0 ]; then
  echo 'Error al establecer la contraseña para el nuevo usuario.'
  exit 1
fi
echo 'Nuevo usuario creado y configurado correctamente.'

echo 'Configurando sudoers para el nuevo usuario...'
sed -i '/^root ALL=(ALL:ALL) ALL/a\\'$new_user' ALL=(ALL:ALL) ALL' /etc/sudoers
if [ \$? -ne 0 ]; then
  echo 'Error al configurar sudoers para el nuevo usuario.'
  exit 1
fi
echo 'Configuración de sudoers para el nuevo usuario completada.'

