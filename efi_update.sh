#!/bin/bash
LINUX=$1
[[ $1 == "-mk" ]] && LINUX=$2
BOOTDIR=/boot
CERTDIR=/etc/efikeys
KERNEL=$BOOTDIR/vmlinuz-$LINUX
INITRAMFS=/boot/initramfs-$LINUX.img
EFISTUB=/usr/lib/systemd/boot/efi/linuxx64.efi.stub
BUILDDIR=/tmp/_build_efi_update
OUTIMG_DIR=/boot/efi/EFI/$LINUX
OUTIMG=$OUTIMG_DIR/Bootx64.efi
CMDLINED=/etc/cmdline.d

MTMP=false

if [[ $LINUX == "" ]]; then
	echo "Usage: efi_update [-mk] LINUX"
	echo
	echo "    -mk    make initramfs"
	echo 
	exit 1
fi


if [[ ! -x $EFISTUB ]]; then
	echo "efi stub not found!"
	exit 1
fi

if [[ ! -d $OUTIMG_DIR ]]; then
	echo "directory $OUTIMG_DIR not found!"
	exit 1
fi

if [[ -d $BUILDDIR ]]; then
	echo "directory $BUILDDIR already exist"
	echo "wait for complete runing process, or delete directory"
	exit 1
fi

[[ $1 == "-mk" ]] && mkinitcpio -p $2

[[ -f /boot/amd-ucode.img ]] && INITRAMFS="$INITRAMFS /boot/amd-ucode.img"
[[ -f /boot/intel-ucode.img ]] && INITRAMFS="$INITRAMFS /boot/intel-ucode.img"

mkdir -p $BUILDDIR
[[ $MTMP ]] && mount -t tmpfs none $BUILDDIR
chmod 600 $BUILDDIR

awk -F\# '{print $1}' <<< "`cat $CMDLINED/*`" | sed -e ':a;N;$!ba;s/\n/ /g' -e 's/  */ /g' | tee $BUILDDIR/cmdline

cat ${INITRAMFS} > ${BUILDDIR}/initramfs.img

/usr/bin/objcopy \
    --add-section .osrel=/etc/os-release --change-section-vma .osrel=0x20000 \
    --add-section .cmdline=${BUILDDIR}/cmdline --change-section-vma .cmdline=0x30000 \
    --add-section .linux=${KERNEL} --change-section-vma .linux=0x40000 \
    --add-section .initrd=${BUILDDIR}/initramfs.img --change-section-vma .initrd=0x3000000 \
    ${EFISTUB} ${BUILDDIR}/combined-boot.efi

/usr/bin/sbsign --key ${CERTDIR}/key.key --cert ${CERTDIR}/key.crt --output ${BUILDDIR}/combined-boot-signed.efi ${BUILDDIR}/combined-boot.efi

mount -o rw,remount /boot/efi
cp ${BUILDDIR}/combined-boot-signed.efi ${OUTIMG}
mount -o ro,remount /boot/efi

[[ $MTMP ]] && umount $BUILDDIR
rm -rf $BUILDDIR
