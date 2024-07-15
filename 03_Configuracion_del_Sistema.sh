#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

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

