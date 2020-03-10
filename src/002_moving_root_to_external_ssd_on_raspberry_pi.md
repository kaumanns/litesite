---
title: "Raspbian: Moving Root to External SSD"
last-update: 11.03.2020
author: David Kaumanns
keywords:
    - development
    - raspberrypi
---

## Introduction

By default, Raspbian's boot and root partitions are stored on the SD card.

However, even the best SD cards achieve at most around 40MB/s write speed
^[<https://www.techradar.com/reviews/samsung-portable-ssd-t5>]
, compared to 200MB/s to 300MB/s write speed on a good external SSD drive via USB 3.0 Type-A
^[<https://blog.adafruit.com/2019/07/26/comparison-of-sd-card-performance-on-a-raspberry-pi-4-raspberry_pi-piday-raspberrypi/>].

This means that we should expect writing and reading speed to be the major bottleneck for all taskes where these processes are involved, especially common desktop tasks like file processing, file transfer and using applications.

For Raspberry Pi 4, there is currently no (easy) way to move the entire operating system to a USB drive and boot from it.
However, we can move the root partition to a USB drive and mount it at boot.

The following steps are tested on a Raspberry Pi 4 running Raspbian GNU/Linux 10 (buster) using a Samsung PortableSSDT5 500GB.

Requirements:

- Raspberry Pi running a compatible GNU/Linux operating system
- An empty external SSD drive formatted as EXT4


## Copy root to the external SSD

Plug the external EXT4-formatted SSD into one of the USB 3.0 ports (blue).

Retrieve the device name:

```
lsblk
```

Mount the device via its device name (e.g. `/dev/sda1`) as `/media/root`

```
sudo mkdir -p /media/root
sudo mount /dev/sda1 /media/root
```

Copy your entire `/` (root) to the SSD:

```
sudo rsync -avx / /media/root
```


## Configure the external SSD as root partition

Retrieve the partion ID of `/dev/sda1`.
It looks this: `PARTUUID=<YOUR_SSD_PARTUUID>`:

```
sudo blkid
```

Create backups of these files:

```
sudo cp /boot/cmdline.txt /boot/cmdline.txt.bak
sudo cp /etc/fstab /etc/fstab.bak
```

Edit the single line in `/boot/cmdline.txt` such that it contains these values for the given keys.
Make sure not to insert duplicate keys and not to add a second line:

```
<...> root=PARTUUID=<YOUR_SSD_PARTUUID> <...> rootfstype=ext4 <...> rootwait <...>
```


Edit `/etc/fstab` such that it reflects the correct `PARTUUID` in the line with the `/` (root) in the second column.
It looks like this:

```
PARTUUID=<YOUR_SSD_PARTUUID> / ext4 defaults,noatime 0 1
```

Reboot:

```
sudo reboot
```


## Verify the setup

The Raspberry should behave as normal.
Note that if you do not plug in the external SSD, the Raspberry will not boot while these changes are in place.
If you encounter any errors, remove the SD card and verify the changes on a different host computer.

Verify that the correct device has been mounted as `/`.
You should see the output `/dev/sda1` or similar, not `/dev/mmcblk0p2`:

```
findmnt -n -o SOURCE /
```

Check if `/` (root) reflects the expected size of the external SSD:

```
df -h
```

Verify the expected SSD performance.
This tool installs missing dependencies, runs a benchmark test, and then allows uploading anonymous results for comparison to <https://storage.jamesachambers.com/>:

```
sudo curl https://raw.githubusercontent.com/TheRemote/PiBenchmarks/master/Storage.sh | sudo bash
```

These were my results: <https://storage.jamesachambers.com/benchmark/12150>
