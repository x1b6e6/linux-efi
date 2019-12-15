# Linux kernel as EFI application

Only for Arch-based Linux Systems.

## About
This script split `/boot/vmlinuz-linux`, from `linux` package, and `/boot/initramfs-linux.img`, generated via `mkinitcpio`, into one EFI executable file. Also, your    `cmdline` is configuring into `/etc/cmdline.d/`.

## Where it saved?
This script save your EFI app into `/boot/efi/EFI/linux/bootx64.efi`

## New folder `/etc/cmdline.d/`
This folder work as anouther folder with postfix `.d`. Rreading all text from files in this folder, and add it to ended `cmdline` (w/o lines, what started from `#`)

## EFI SecureBoot
This script sign all generated EFI app with keys, what generated at installation (if you already have keys, this step skipping).
- private at `/etc/efi.key.pem`
- public  at `/etc/efi.pub.pem`

after generating, you must install this key manualy:
- PK : `/etc/PK.auth`
- KEK: `/etc/KEK.auth`
- db : `/etc/db.auth`

## Install dependencies
```bash
pacman -Sy sbsigntools efibootmgr expect openssl efivar
```

## Installing
```bash
git clone https://github.com/x1b6e6/linux-efi.git
cd linux-efi
makepkg --install
```
