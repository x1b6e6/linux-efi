#!/bin/sh

# constants
CERT_DIR="/etc/efikeys"
EFI_KEY="/etc/efi.key.pem"
EFI_CRT="/etc/efi.pub.pem"
EFISTUB="/usr/lib/systemd/boot/efi/linuxx64.efi.stub"
ADDITIONAL_INITRAMFS="/boot/amd-ucode.img /boot/intel-ucode.img"

# list of files what need update (generating automaticaly)
KERN_FILES=""

# generate KERN_FILES
while read -r UPDFILE; do
		
	if \
			# check updated initcpio
			grep -e "\busr/lib/initcpio/[[:alnum:][:punct:]]*" <<< "${UPDFILE}" || \
			# check updated efistub
		    [[ "usr/lib/systemd/boot/efi/linuxx64.efi.stub" == "${UPDFILE}" ]]; then

		echo UPDATE ALL KERNELS >&2
		KERN_FILES="$(find /usr/lib/modules/ -mindepth 2 -maxdepth 2 -type f -name vmlinuz)"
		break;
	fi

	# check updated only kernel
	if grep -e "\busr/lib/modules/[[:alnum:][:punct:]]*/vmlinuz\b" <<< "${UPDFILE}"; then
		KERN_FILES="${KERN_FILES} /${UPDFILE}"
	fi
done

PKGS_UPDATE=""

# proccess KERN_FILES
for KFile in ${KERN_FILES}; do
	KERNEL_IMAGE="${KFile}"
	PKG=$(pacman -Qo ${KERNEL_IMAGE} | cut -f5 -d ' ')

	echo UPDATE ${PKG} >&2

	INITRAMFS="/boot/initramfs-${PKG}.img"
	CMDLINE="/etc/cmdline-${PKG}"
	[[ ! -f $CMDLINE ]] && cp /proc/cmdline $CMDLINE
	
	TMP_EFI_APPLICATION="/tmp/linux-efi-${PKG}-application.efi"
	TMP_INITRAMFS="/tmp/linux-efi-initramfs.img"

	# DON'T TOUCH NEXT LINE
	TMP_EFI_APPLICATION_SIGNED="/tmp/linux-efi-${PKG}-application-signed.efi"

	cat ${INITRAMFS} ${ADDITIONAL_INITRAMFS} > ${TMP_INITRAMFS} 2>/dev/null

	/usr/bin/llvm-objcopy \
		-R .osrel \
		-R .cmdline \
		-R .linux \
		-R .initrd \
		${EFISTUB} ${TMP_EFI_APPLICATION}

	# add sections
	/usr/bin/llvm-objcopy \
        --add-section .osrel=/etc/os-release        \
        --add-section .cmdline=${CMDLINE}           \
        --add-section .linux=${KERNEL_IMAGE}        \
        --add-section .initrd=${TMP_INITRAMFS}      \
        ${TMP_EFI_APPLICATION} ${TMP_EFI_APPLICATION}
	
	# change vma of sections
	/usr/bin/objcopy \
        --change-section-vma .osrel=0x20000    \
        --change-section-vma .cmdline=0x30000  \
        --change-section-vma .linux=0x40000    \
        --change-section-vma .initrd=0x3000000 \
        ${TMP_EFI_APPLICATION} ${TMP_EFI_APPLICATION}

	/usr/bin/sbsign                            \
		--key ${EFI_KEY}                       \
		--cert ${EFI_CRT}                      \
		--output ${TMP_EFI_APPLICATION_SIGNED} \
		${TMP_EFI_APPLICATION}

	PKGS_UPDATE="${PKGS_UPDATE} ${PKG}"

	# clear temporary files
	rm ${TMP_EFI_APPLICATION} ${TMP_INITRAMFS}
done

for PKG in $PKGS_UPDATE; do
	EFI_APPLICATION_DIR=/boot/EFI/${PKG}
	EFI_APPLICATION=${EFI_APPLICATION_DIR}/Bootx64.efi

	# DON'T TOUCH NEXT LINE
	TMP_EFI_APPLICATION_SIGNED="/tmp/linux-efi-${PKG}-application-signed.efi"

	# copy result to efi partition
	mkdir -p ${EFI_APPLICATION_DIR}
	cp ${TMP_EFI_APPLICATION_SIGNED} ${EFI_APPLICATION}

	# remove temporary signed efi application
	rm ${TMP_EFI_APPLICATION_SIGNED}
done

# vim: set ts=4 sw=4 :
