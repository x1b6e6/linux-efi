# Linux kernel as EFI application

Only for Arch-based Linux Systems.

## About
This script is spliting `/boot/vmlinuz-linux`, from `linux` or other packages, and `/boot/initramfs-linux.img`, generated via `mkinitcpio`, into one EFI executable file.

## Where it saved?
This script save your EFI app into `/boot/efi/EFI/{Kernel packet}/Bootx64.efi`
For example: 
* for `linux`    : `/boot/efi/EFI/linux/Bootx64.efi`
* for `linux-lts`: `/boot/efi/EFI/linux-lts/Bootx64.efi`
* for `linux-git`: `/boot/efi/EFI/linux-git/Bootx64.efi`
* for `linux-zen` ...etc


## New folder `/etc/cmdline.d/`
Generate string of kernel arguments from files in `/etc/cmdline.d/`. Comment lines start from `#`.

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
