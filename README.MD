# Linux kernel as EFI application

Only for Arch-based Linux Systems.

## About
This script is spliting `/boot/vmlinuz-linux`, from `linux` or other packages, and `/boot/initramfs-linux.img`, generated via `mkinitcpio`, into one EFI executable file.

## Where it saved?
This script save your EFI app into `/boot/EFI/${pkgname}/Bootx64.efi`
For example: 
* for `linux`    : `/boot/EFI/linux/Bootx64.efi`
* for `linux-lts`: `/boot/EFI/linux-lts/Bootx64.efi`
* for `linux-git`: `/boot/EFI/linux-git/Bootx64.efi`
* ...etc

`/boot/EFI` can be symbolic link to real `EFI` directory

## Kernel arguments
cmdline written in `/etc/cmdline-${pkgname}`

## EFI SecureBoot
This script signing all generated EFI app with generated keys.
- private at `/etc/efi.key.pem`
- public  at `/etc/efi.pub.pem`

you must install this keys in EFI manualy:
- PK : `/etc/PK.auth`
- KEK: `/etc/KEK.auth`
- db : `/etc/db.auth`

## Build and install
```bash
git clone https://github.com/x1b6e6/linux-efi.pkgbuild.git
cd linux-efi.pkgbuild
makepkg -si
```
