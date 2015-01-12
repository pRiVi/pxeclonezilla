# PXE Backup via Clonezilla

## Ueberall zu ersetzen:

  * $NAME -> Name des Computers; mehrere sind moeglich dann muss dies pro Computer einmal gemacht werden
  * 00-11-22-... -> MAC Adresse von $NAME
  * $STORESERVERIP -> IP des Servers, der das Share hat wo die Backups hin gespeichert werden sollen 
  * $SERVERIP -> IP des Servers der den FTP und TFTP Server hat

## Install ISCDHCP, configure it and add PXE to DHCP Server

* apt-get install isc-dhcp-server

/etc/dhcp3/dhcpd.conf:
```
subnet x.x.x.x netmask y.y.y.y {
...
   filename "pxelinux.0";
...
}
```

## Install tftp and ftp

 * apt-get install tftpd proftpd
 * (TOCO/FIXME) Enable /srv/ftp/ and /var/lib/tftpboot/... or do ftp with username and password? Might be ssh an better solution?

## Configure clonezilla PXE boot

```
cd /var/lib/tftpboot/
for i in boot.txt boot.backup.txt chain.c32 pxelinux.0; do ln -s /path/to/$i .; done
```

## Create welcome message:

 * ln -s boot.backup.txt boot.$NAME.txt
 * mkdir pxelinux.cfg
 * cd pxelinux.cfg

$NAME.cfg:
```
DISPLAY boot.$NAME.txt

DEFAULT win7

LABEL win7
        KERNEL chain.c32
        APPEND hd0

LABEL backup
        kernel vmlinuz
        append initrd=initrd.img boot=live config noswap nolocales edd=on nomodeset ocs_live_run="ocs-live-general" ocs_live_extra_param="" keyboard-layouts="" ocs_live_batch="no" locales="" vga=788 nosplash noprompt fetch=tftp://$SERVERIP/filesystem.squashfs keyboard-layouts=de locales=de_DE.UTF-8 ocs_live_run="/usr/sbin/ocs-sr -q -j2 -rm-win-swap-hib -z1 -i 2000 -sc -p poweroff savedisk ask_user sda" ocs_prerun1="sudo wget -O /root/mount.sh ftp://$SERVERIP/mount.$NAME.sh" ocs_prerun2="chmod +x /root/mount.sh" ocs_prerun3="/root/mount.sh"

TIMEOUT 15
PROMPT 1
```

 * ln -s $NAME.cfg 00-11-22-... # <- MAC Adresse des jeweiligen Computers
 * cd /srv/ftp/
 * Freigabe auf Server erzeugen und darin die Datei "backup_directory" im Grundverzeichniss leer erzeugen.

mount.$NAME.sh:
```
#!/bin/bash
while [ ! -e /home/partimag/backup_directory ]; do
  sleep 1;
  echo "Mount failed, try again.";
  mount -t cifs -o user=clonezilla,password=PASSWORD //$STORESERVERIP/$SHARENAME/ /home/partimag;
done;
```

## Install Clonezilla

 * cd /var/lib/tftpboot/
 * Unter http://sourceforge.net/projects/clonezilla/files/clonezilla_live_stable/ die aktuelle ZIP herunterladen
 * Unter "live" die Dateien "filesystem.squashfs", "initrd.img" und "vmlinuz" entpacken und nach /var/lib/tftpboot/ legen


