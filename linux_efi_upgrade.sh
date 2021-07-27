#!/bin/sh

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

	linux-sign "${PKG}" "/boot/EFI/${PKG}/Bootx64.efi"

done

# vim: set ts=4 sw=4 :
