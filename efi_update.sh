#!/bin/bash
BOOTDIR=/boot
CERTDIR=/etc/efikeys
KERNEL=$1
INITRAMFS="/boot/amd-ucode.img /boot/initramfs-$1.img"
EFISTUB=/usr/lib/systemd/boot/efi/linuxx64.efi.stub
BUILDDIR=/tmp/_build_efi_update
OUTIMG=/boot/efi/EFI/$1/Bootx64.efi
CMDLINE=/etc/cmdline

mkdir -p $BUILDDIR
chmod 600 $BUILDDIR

cat ${INITRAMFS} > ${BUILDDIR}/initramfs.img

echo $(cat /etc/cmdline)

/usr/bin/objcopy \
    --add-section .osrel=/etc/os-release --change-section-vma .osrel=0x20000 \
    --add-section .cmdline=${CMDLINE} --change-section-vma .cmdline=0x30000 \
    --add-section .linux=/boot/vmlinuz-${KERNEL} --change-section-vma .linux=0x40000 \
    --add-section .initrd=${BUILDDIR}/initramfs.img --change-section-vma .initrd=0x3000000 \
    ${EFISTUB} ${BUILDDIR}/combined-boot.efi

/usr/bin/sbsign --key ${CERTDIR}/key.key --cert ${CERTDIR}/key.crt --output ${BUILDDIR}/combined-boot-signed.efi ${BUILDDIR}/combined-boot.efi

mount -o rw,remount /boot/efi
cp ${BUILDDIR}/combined-boot-signed.efi ${OUTIMG}
mount -o ro,remount /boot/efi

rm -rf $BUILDDIR
