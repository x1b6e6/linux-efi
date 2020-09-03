#!/bin/sh

# settings constants
EFI_MOUNT_POINT="/boot/efi"
EFI_MOUNT_READONLY=1

# constants
CERT_DIR="/etc/efikeys"
CMDLINED="/etc/cmdline.d"
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
		# TODO: add to KERN_FILES all kernel files
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

	CMDLINE=$(find ${CMDLINED} -type f -exec awk -F '#' '{printf $1 " "}' {} \;)
	INITRAMFS="/boot/initramfs-${PKG}.img"
	
	TMP_EFI_APPLICATION="/tmp/linux-efi-${PKG}-application.efi"
	TMP_KERNEL_PARAMS="/tmp/linux-efi-kernel-params"
	TMP_INITRAMFS="/tmp/linux-efi-initramfs.img"

	# DON'T TOUCH NEXT LINE
	TMP_EFI_APPLICATION_SIGNED="/tmp/linux-efi-${PKG}-application-signed.efi"

	cat ${INITRAMFS} ${ADDITIONAL_INITRAMFS} > ${TMP_INITRAMFS} 2>/dev/null
	if ! [[ -f ${TMP_INITRAMFS} ]]; then
		echo ${TMP_INITRAMFS} not exist
		exit 1
	fi

	echo ${CMDLINE} > ${TMP_KERNEL_PARAMS}

	/usr/bin/llvm-objcopy \
		-R .osrel \
		-R .cmdline \
		-R .linux \
		-R .initrd \
		${EFISTUB} ${TMP_EFI_APPLICATION}

	# add sections
	/usr/bin/llvm-objcopy \
        --add-section .osrel=/etc/os-release        \
        --add-section .cmdline=${TMP_KERNEL_PARAMS} \
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
	# rm ${TMP_EFI_APPLICATION} ${TMP_INITRAMFS} ${TMP_KERNEL_PARAMS}
done

# remount efi mount point with rw privileges
((EFI_MOUNT_READONLY)) && \
	mount -orw,remount ${EFI_MOUNT_POINT}

for PKG in $PKGS_UPDATE; do
	EFI_APPLICATION=${EFI_MOUNT_POINT}/EFI/${PKG}/Bootx64.efi

	# DON'T TOUCH NEXT LINE
	TMP_EFI_APPLICATION_SIGNED="/tmp/linux-efi-${PKG}-application-signed.efi"

	# copy result to efi partition
	cp ${TMP_EFI_APPLICATION_SIGNED} ${EFI_APPLICATION}

	# remove temporary signed efi application
	# rm ${TMP_EFI_APPLICATION_SIGNED}
done

# remount efi mount point with default options
((EFI_MOUNT_READONLY)) && \
	mount -oremount ${EFI_MOUNT_POINT}

# vim: set ts=4 sw=4 :
