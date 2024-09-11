# systemd service to reset a USB touchpad driver on boot

USB touchpads seem to not work out of the box due to a kernel bug (afaik, don't know the details). This can be solved by force-reloading the driver.

## How to

### Find the device ID
```
~ > lsusb

    Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
    Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
    Bus 003 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
    Bus 003 Device 002: ID 8087:0029 Intel Corp. AX200 Bluetooth
    Bus 003 Device 018: ID 2109:2813 VIA Labs, Inc. VL813 Hub
    Bus 003 Device 019: ID 062a:636a MosArt Semiconductor Corp. 2.4G Mouse
    Bus 003 Device 020: ID 05ac:0265 Apple, Inc.
    Bus 003 Device 021: ID 05e3:0618 Genesys Logic, Inc. Hub
    Bus 003 Device 022: ID 05e3:0752 Genesys Logic, Inc. micros Reader
    Bus 003 Device 023: ID 2109:0100 VIA Labs, Inc. USB 2.0 BILLBOARD
    Bus 004 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
    Bus 004 Device 008: ID 2109:0813 VIA Labs, Inc. VL813 Hub
    Bus 004 Device 009: ID 0bda:8153 Realtek Semiconductor Corp. RTL8153 Gigabit Ethernet Adapter
```

In this case:
```
Bus 003 Device 020: ID 05ac:0265 Apple, Inc.
```

The device ID is **05ac:0265**

### Find the driver

```
~ > hwinfo | grep  'input device.*05AC:0265'

    input device: bus = hid, bus_id = 0003:05AC:0265.000A driver = hid-multitouch
    input device: bus = hid, bus_id = 0003:05AC:0265.000A driver = hid-multitouch
    input device: bus = hid, bus_id = 0003:05AC:0265.0009 driver = magicmouse
    input device: bus = hid, bus_id = 0003:05AC:0265.000A driver = hid-multitouch
    input device: bus = hid, bus_id = 0003:05AC:0265.000A driver = hid-multitouch
    input device: bus = hid, bus_id = 0003:05AC:0265.0009 driver = magicmouse
    input device: bus = hid, bus_id = 0003:05AC:0265.000A driver = hid-multitouch
```

`hid-multitouch` is a generic driver (I guess?). What we're after is `magicmouse`

### Add a script to remove and re-add the driver module

As shown in `reset-touchpad-driver.sh`, change the driver name to match your driver. Make this script executable

### Add a systemd service
Add `reset-touchpad-driver.service` to `/etc/systemd/system/service`,

### Run the service and make it run at startup

```
~ > systemctl start restart-touchpad-service
~ > systemctl enable restart-touchpad-service
```
