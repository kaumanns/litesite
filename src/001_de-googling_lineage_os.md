---
title: De-Googling Lineage OS
last-update: 10.03.2020
author: David Kaumanns
keywords:
    - development
    - lineageos
---

## Introduction

[Lineage OS](https://www.lineageos.org/), a derivative of the Google's Android operating system, is your best shot at carrying a smart mobile device without being surveilled by an untrustworthy third party.
However, it is not entirely free of Google snooping on your digital traffic. This guide shall address the worst offenses.

Notes:

- The following steps have been tested on Lineage OS 16.0 (no microg) on a Fairphone 2.
- Part of this guide aims to be a more concise version of that guide: [Degoogling LineageOS instructions - August 2019 update](https://www.reddit.com/r/LineageOS/comments/cl5c90/degoogling_lineageos_instructions_august_2019/). Refer to it for more detailed information and links.
- No guarantee that your device will be safe enough for your specific privacy needs. There may be bugs and undocumented behaviour.
- Google may be lurking in some yet undocumented corners of the operation system. The public documentation on this is spotty, to say the least.
- All tipps are given according to my best knowledge.


## AdAway

Requirements:

- Rooted device

Browser-based content blocking does not prevent apps from talking to anyone they please, including Google and other trackers.
In order to have full control over which servers your device talks to, you have to block domains on the system level by modifying `/etc/hosts`.

Install [AdAway](https://f-droid.org/en/packages/org.adaway) from F-Droid and grant it root access.

Inside the app, go to `Hosts sources` and add your prefered blocklist from <https://github.com/StevenBlack/hosts>.
I chose the base tracker blocklist: `https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts`

Then go to `Log DNS requests` and tap on `Enable Monitoring`.
Come back after using a couple of apps to see which domains your device requested data from.
The app allows selective blocking of those requestes by adding it to the blacklist under `Your lists`.

For example, the blocklist may include:

- `fonts.gstatic.com`
- `fonts.googleapis.com`

... in order to block font requestes to Google.

You can chose to block more aggressively, depending on your needs.
Note that the domain names may change anytime and render some entries in the blocklist obsolete.


## Changing the Domain Name Server (DNS)

Requirements: None.

Lineage OS defaults to Google's DNS (8.8.8.8).
This means that Google learns about each hostname that your device requests via the browser or any installed app, which is basically all of your internet activity on the device.

Go into `Settings -> Network & Internet -> Advanced -> Private DNS`.
Insert the hostname of your preferred **DNS-over-TLS (DoT)** provider.
IP addresses and unencrypted DNS cannot be used here.

I chose `dot-de.blahdns.com` by consulting this website: <https://www.privacytools.io/providers/dns/>


## Changing the Captive Portal

Requirements:

- Ability to open the command line on a \*nix machine.
- Android Debuge Bridge (ADB) set up on a host machine
- Device connected to that host machine

Each time your device connects to the internet via Wifi, it asks Google's [captive portal](https://en.wikipedia.org/wiki/Captive_portal) server (`connectivitycheck.gstatic.com`) for a specific response code (HTTP 204), and only then connects to the internet.

This means that you need a different third party server to respond with that code.
I chose to trust the server by Mike Kuketz, a German security researcher.
More information here (German only): <https://www.kuketz-blog.de/android-captive-portal-check-204-http-antwort-von-captiveportal-kuketz-de/>

On a host machine, run these commands:

```{.shell}
adb shell 'settings put global captive_portal_http_url "http://captiveportal.kuketz.de"'
adb shell 'settings put global captive_portal_https_url "https://captiveportal.kuketz.de"'
adb shell 'settings put global captive_portal_fallback_url "http://captiveportal.kuketz.de"'
adb shell 'settings put global captive_portal_other_fallback_urls "http://captiveportal.kuketz.de"'
```

Then check if it worked:

```
adb shell 'settings get global captive_portal_https_url'
```

You should see this output: `https://captiveportal.kuketz.de`


## Disabling SUPL for A-GPS

Requirements:

- Rooted device
- Ability to open the command line on a \*nix machine.
- Android Debuge Bridge (ADB) set up on a host machine
- Device connected to that host machine

From the source guide:

> LineageOS defaults to `supl.google.com` for SUPL data, which helps in speeding up device positioning (aka TTFF) when using A-GPS, but each request to server is accompanied by device's IMEI.

In other words, each time your device requests its GPS position, it sends a unique identifier to Google's servers along with its location.
In exchange you get a more speedy positioning.

This is pretty bad.
If you are willing to give up the benefit of fast GPS lookup, read on.
For more information about the privacy aspects, refer to:

- <https://blog.wirelessmoves.com/2014/08/supl-reveals-my-identity-and-location-to-google.html>
- (German) <https://www.kuketz-blog.de/android-imsi-leaking-bei-gps-positionsbestimmung/>

On your host machine, restart adb as root and log into your device:

```
adb root
adb shell
```

Re-mount the system partion as read+write:

```
mount -o rw,remount /system
```

Open the GPS configuration file in a terminal text editor:

```
nano /etc/gps.conf
```

Now change some entries.

You may want to change the NTP server to a European one:

```
NTP_SERVER=europe.pool.ntp.org
```

Look for these settings (they may be commented out, and the port number may vary):

```
# SUPL_HOST=supl.google.com
# SUPL_PORT=7276
```

... and change them as such:

```
SUPL_HOST=localhost
SUPL_PORT=7276
```

Save and close the editor by pressing `CTRL+X` and `Y`.

Reboot your device.

**Note**: It seems that these steps have to be repeated after each system upgrade as the configuration file is reset.

Install [SatStat](https://f-droid.org/en/packages/com.vonglasow.michael.satstat/) from F-Droid, open it, and wait for the satellite lock.
It may take a while, possibly 10 minutes or more, depending on your location and your device.
See if it works for you in the long term.


## Todo

- Cover AOSP Webview and Project Fi.
