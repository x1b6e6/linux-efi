#!/bin/bash

while read -r pkgbase; do

grep -e "\busr/lib/modules/[[:alnum:][:punct:]]*/vmlinuz\b" <<< "$pkgbase" || continue;

KERNEL=/$pkgbase
pkgbase=$(pacman -Qo $KERNEL)

[[ "$pkgbase" == "" ]] && exit 1;

# set 1, if you want generate boot file with emergency cmdline
GENERATE_EMERGENCY=0

LINUX=$pkgbase
BOOTDIR=/boot
CERTDIR=/etc/efikeys
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
EFI_KEY=/etc/efi.key.pem
EFI_CRT=/etc/efi.pub.pem

EXPECT_COMMANDS="
set timeout 120
spawn /usr/bin/sbsign --key $EFI_KEY --cert $EFI_CRT --output ${TMP_BOOT_SIGNED} ${TMP_BOOT}
expect \"*?phrase:*\"
stty -echo
expect_tty -re \"(.*)\\n\"
set pass \"\$expect_out(1,string)\n\"
stty echo
send -- \"\$pass\"
expect {
        \"Signing Unsigned original image\" {wait}
        \"bad decrypt\" {exit 1}
        \"bad password\" {exit 2}
}"

EXPECT_COMMANDS_EMERGENCY="
spawn /usr/bin/sbsign --key $EFI_KEY --cert $EFI_CRT --output ${TMP_EMERGENCY_SIGNED} ${TMP_EMERGENCY}
expect \"*?phrase:*\"
send -- \"\$pass\"
expect {
        \"Signing Unsigned original image\" {wait}
        \"bad decrypt\" {exit 1}
        \"bad password\" {exit 2}
}"

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

[[ -f /boot/amd-ucode.img ]] && INITRAMFS="/boot/amd-ucode.img $INITRAMFS"
[[ -f /boot/intel-ucode.img ]] && INITRAMFS="/boot/intel-ucode.img $INITRAMFS"

mkdir -p $TMP
chmod 600 $TMP


# generating cmdline from files /etc/cmdline.d/*
echo -n "kernel param: "
CMDLINE=$(find $CMDLINED -type f -exec awk -F '#' '{printf $1 " "}' {} \;)
echo $CMDLINE


# create full initramfs
cat ${INITRAMFS} > $TMP_INITRD

echo $CMDLINE "quiet" > ${TMP_CMDLINE_BOOT}
(( GENERATE_EMERGENCY )) && 
echo $CMDLINE "emergency" > ${TMP_CMDLINE_EMERGENCY}

/usr/bin/objcopy \
    --add-section .osrel=/etc/os-release --change-section-vma .osrel=0x20000 \
    --add-section .cmdline=$TMP_CMDLINE_BOOT --change-section-vma .cmdline=0x30000 \
    --add-section .linux=${KERNEL} --change-section-vma .linux=0x40000 \
    --add-section .initrd=$TMP_INITRD --change-section-vma .initrd=0x3000000 \
    ${EFISTUB} ${TMP_BOOT}

(( GENERATE_EMERGENCY )) &&
/usr/bin/objcopy \
    --add-section .osrel=/etc/os-release --change-section-vma .osrel=0x20000 \
    --add-section .cmdline=$TMP_CMDLINE_EMERGENCY --change-section-vma .cmdline=0x30000 \
    --add-section .linux=${KERNEL} --change-section-vma .linux=0x40000 \
    --add-section .initrd=$TMP_INITRD --change-section-vma .initrd=0x3000000 \
    ${EFISTUB} ${TMP_EMERGENCY}

if grep -i ENCRYPTED $EFI_KEY 2>&1 > /dev/null; then

while :; do 
    (( GENERATE_EMERGENCY )) &&
	(expect <<< "$EXPECT_COMMANDS$EXPECT_COMMANDS_EMERGENCY") || 
    (expect <<< "$EXPECT_COMMANDS")
	sig=$?
	case $sig in
		0)break;;
		130)exit 1;;
	esac
done
else
    /usr/bin/sbsign --key $EFI_KEY --cert $EFI_CRT --output $TMP_BOOT_SIGNED $TMP_BOOT
    (( GENERATE_EMERGENCY )) &&
    /usr/bin/sbsign --key $EFI_KEY --cert $EFI_CRT --output $TMP_EMERGENCY_SIGNED $TMP_EMERGENCY
fi
mount -o rw,remount /boot/efi
cp ${TMP_BOOT_SIGNED} ${OUTIMG_BOOT}
(( GENERATE_EMERGENCY )) &&
cp ${TMP_EMERGENCY_SIGNED} ${OUTIMG_DIR}/$LINUX-emergency.efi
mount -o ro,remount /boot/efi

rm -rf $BUILDDIR

# TODO: adding to efi boot list
done
