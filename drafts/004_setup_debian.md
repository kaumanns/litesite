---
title: "Setup Debian"
last-update: 11.09.2020
author: David Kaumanns
keywords:
    - development
    - raspberrypi
---

This is how I set up a fresh Debian installation. Tested on Debian 10.5 Buster, Raspberry OS and Ubuntu. Probably works on all Debian-based distros.

Gently reminder: verify all commands before executing them.

# Upgrade vom Buster (stable) to Bullseye (testing)

Modify the sources list:

```
# sed -i 's/buster/bullseye/g' /etc/apt/sources.list
```

With Bullseye, make sure that the security entries look like this^[<https://lists.debian.org/debian-devel-announce/2019/07/msg00004.html>]:

```
deb http://security.debian.org/debian-security bullseye-security main
```

Upgrade the system:

```
# apt update
# apt full-upgrade
```

Reboot:

```
$ /sbin/reboot
```

# Setup basic system

Install most basic packages:

```
# apt install sudo git make
```

Add `$USER` to sudoers:

```
# /sbin/usermod -aG sudo $USER
```

# Install dotfiles from Git server

Generate SSH key^[<https://docs.gitlab.com/ee/ssh/README.html#generating-a-new-ssh-key-pair>]:

```
$ ssh-keygen -t rsa -b 4096 -C $USER@`hostname`
```

You can now add the public key to the list of verified keys on your Git server, if you have you have a graphical desktop and a browser ready.

Else, and if you want to avoid hand-typing the whole key, plug in a USB drive, copy the public key over, and add it via a different machine:

Find the device name of the USB drive:

```
lsblk
```

E.g.: `/dev/sdc`.

Mount, copy, unmount:

```
# mkdir -p /media/usb
# mount /dev/sdc /media/usb
# cp /home/$USER/.ssh/id_rsa.pub /media/usb/
# umount /media/usb
```

Clone your dotfiles, e.g.:

```
$ mkdir ~/git && cd ~/git
$ git clone git@gitlab.com:kaumanns/dotfiles.git
```

# Set up Pass and GnuPG

Copy your `pass` password store e.g. from an external drive to your home folder:

```
cp -r /media/usb/password-store ~/.password-store
```

Import previously exported GnuPG public GPG key and ownertrust to your local GnuPG keychain, .e.g using my tool:

```
~/git/dotfiles/tools/gpg-keys.sh import $USER /media/usb/
```
