INSTALL - CUPS v2.3.1 - 2022-06-28 (Fork)
=======================================================================
Reworked of [CUPS](https://github.com/OpenPrinting/cups) version adaptated for Ubuntu 20.04.4 LTS.

Main my [CUPS](https://github.com/Deplee/linux_projects/tree/master/deb_pkgs) - reworked version.

Changelog
=======================================================================

 + Fixes:
   1. Addaptated for Ubuntu 20.04.4 LTS
   2. usb printer connection
   3. interaction with Olivetty usb printer
***
Dependencies
=======================================================================
```
autoconf build-essential libavahi-client-dev
libgnutls28-dev libkrb5-dev libnss-mdns libpam-dev
libsystemd-dev libusb-1.0-0-dev zlib1g-dev
```
***
Checkup
=======================================================================
> Must be checked before installation by following commands

```
sudo /usr/lib/cups/backend/usb
```

Output it should be like

```
DEBUG: Loading USB quirks from "/usr/share/cups/usb".
DEBUG: Loaded 95 quirks.
DEBUG: list_devices
DEBUG: libusb_get_device_list=3

```

> Note: if your *output* is null (empty) or different then you should reinstall you **CUPS** by following next commands

```
sudo apt purge cups -y
sudo apt autoclean -y && sudo apt autoremove -y
sudo apt install cups -y
```
***
Install
=======================================================================

```
sudo apt-get install autoconf build-essential libavahi-client-dev \
libgnutls28-dev libkrb5-dev libnss-mdns libpam-dev \
libsystemd-dev libusb-1.0-0-dev zlib1g-dev
sudo apt update -y
sudo dpkg -i cups-reworked-david_3.1-1_all.deb
```

> Must be checked after installation by following commands

```
sudo /usr/lib/cups/backend/usb
```

Output it should be like

```
DEBUG: Loading USB quirks from "/usr/share/cups/usb".
DEBUG: Loaded 95 quirks.
DEBUG: list_devices
DEBUG: libusb_get_device_list=3
```

> Note: if your *output* is null (empty) or different then you should reinstall you **CUPS** by following next commands:

```
sudo apt purge cups -y
sudo apt autoclean -y && sudo apt autoremove -y
sudo apt install cups -y
```

or disable usblp ban in */etc/modprobe.d/blacklist-usblp.conf*
***
Post Install
=======================================================================

Your output in **lpinfo -v** should be like 

```
usb://USB2.0-Print/
or
usb://EPSON/TM-P2.01
```
***
