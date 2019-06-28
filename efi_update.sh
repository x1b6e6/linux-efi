#!/bin/bash
LINUX=$1
[[ $1 == "-mk" ]] && LINUX=$2
BOOTDIR=/boot
CERTDIR=/etc/efikeys
KERNEL=$BOOTDIR/vmlinuz-$LINUX
INITRAMFS=/boot/initramfs-${LINUX}.img
EFISTUB=/usr/lib/systemd/boot/efi/linuxx64.efi.stub
TMP=/tmp/$RANDOM
while $(ls $TMP > /dev/null 2>&1); do
	TMP=/tmp/$RANDOM
done
TMP_INITRD=$TMP/initrd.img
TMP_BOOT=$TMP/boot.efi
TMP_BOOT_SIGNED=$TMP/boot-signed.efi
TMP_EMERGENCY=$TMP/emergency.efi
TMP_EMERGENCY_SIGNED=$TMP/emergency-signed.efi
TMP_CMDLINE_BOOT=$TMP/cmdline-boot
TMP_CMDLINE_EMERGENCY=$TMP/cmdline-emergency
OUTIMG_DIR=/boot/efi/EFI/$LINUX
OUTIMG_BOOT=$OUTIMG_DIR/Bootx64.efi
OUTIMG_EMERGENCY=$OUTIMG_DIR/${LINUX}-emergency.efi
CMDLINED=/etc/cmdline.d

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

[[ -f /boot/amd-ucode.img ]] && INITRAMFS="/boot/amd-ucode.img $INITRAMFS"
[[ -f /boot/intel-ucode.img ]] && INITRAMFS="/boot/intel-ucode.img $INITRAMFS"

mkdir -p $TMP
#mount -t tmpfs none $BUILDDIR
chmod 600 $TMP

echo -n "kernel param: "
CMDLINE=$(grep -vh "#" $CMDLINED/* | sed ':a;N;$!ba;s/\n/ /g')
echo $CMDLINE

cat ${INITRAMFS} > $TMP_INITRD

echo $CMDLINE "quiet" > ${TMP_CMDLINE_BOOT}
echo $CMDLINE "emergency" > $TMP_CMDLINE_EMERGENCY

/usr/bin/objcopy \
    --add-section .osrel=/etc/os-release --change-section-vma .osrel=0x20000 \
    --add-section .cmdline=$TMP_CMDLINE_BOOT --change-section-vma .cmdline=0x30000 \
    --add-section .linux=${KERNEL} --change-section-vma .linux=0x40000 \
    --add-section .initrd=$TMP_INITRD --change-section-vma .initrd=0x3000000 \
    ${EFISTUB} ${TMP_BOOT}

/usr/bin/objcopy \
    --add-section .osrel=/etc/os-release --change-section-vma .osrel=0x20000 \
    --add-section .cmdline=$TMP_CMDLINE_EMERGENCY --change-section-vma .cmdline=0x30000 \
    --add-section .linux=${KERNEL} --change-section-vma .linux=0x40000 \
    --add-section .initrd=$TMP_INITRD --change-section-vma .initrd=0x3000000 \
    ${EFISTUB} ${TMP_EMERGENCY}

while :; do 
	expect << EOF
set timeout 120
spawn /usr/bin/sbsign --key ${CERTDIR}/key.key --cert ${CERTDIR}/key.crt --output ${TMP_BOOT_SIGNED} ${TMP_BOOT}
expect "*?phrase:*"
stty -echo
expect_tty -re "(.*)\\n"
set pass "\$expect_out(1,string)\n"
stty echo
send -- "\$pass"
expect { 
	"Signing Unsigned original image" {wait}
	"bad decrypt" {exit 1}
	"bad password" {exit 2}
}
	

spawn /usr/bin/sbsign --key ${CERTDIR}/key.key --cert ${CERTDIR}/key.crt --output ${TMP_EMERGENCY_SIGNED} ${TMP_EMERGENCY}
expect "*?phrase:*"
send -- "\$pass"
expect {
	"Signing Unsigned original image" {wait}
	"bad decrypt" {exit 1}
	"bad password {exit 2}
}
EOF
	sig=$?
	case $sig in
		0)break;;
		130)exit 1;;
	esac
done

mount -o rw,remount /boot/efi
cp ${TMP_BOOT_SIGNED} ${OUTIMG}
cp ${TMP_EMERGENCY_SIGNED} ${OUTIMG_DIR}/$LINUX-emergency.efi
mount -o ro,remount /boot/efi

#umount $BUILDDIR
rm -rf $BUILDDIR
