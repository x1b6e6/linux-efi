#!/bin/bash

package=0

packages=()

while read -r line; do
	if [[ "$line" != */vmlinuz ]]; then
		package=1
		continue
	fi

	if ! read -r pkgbase &>/dev/null < "${line%/vmlinuz}"/pkgbase; then
		continue
	fi

	packages+=("$pkgbase")
done

if (($package)); then
	packages=()
	for file in /etc/cmdline-*; do
		filename=$(basename "$file")
		suffix=${filename#cmdline-}
		packages+=("$suffix")
	done
fi

for pkgbase in "${packages[@]}"; do
	echo Update EFI for $pkgbase >&2
	/usr/lib/systemd/ukify /boot/vmlinuz-"$pkgbase" /boot/initramfs-"$pkgbase".img --cmdline @/etc/cmdline-"$pkgbase" --secureboot-private-key /etc/efi.key.pem --secureboot-certificate /etc/efi.pub.pem -o /boot/EFI/"$pkgbase"/Bootx64.efi >/dev/null
done

# vim: set ts=4 sw=4 :
