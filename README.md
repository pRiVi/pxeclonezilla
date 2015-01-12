# PXE Backup via Clonezilla

## Add PXE to DHCP Server

/etc/dhcp3/dhcpd.conf
```
subnet x.x.x.x netmask y.y.y.y {
...
   filename "pxelinux.0";
...
}
```

