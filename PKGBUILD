# Maintainer: Jguer <joaogg3@gmail.com>
pkgname=linux-old
pkgver=0.0.2
pkgrel=1
pkgdesc="old files"
arch=('i686' 'x86_64' 'armv7h' 'armv6h' 'aarch64')


source=(
	"efi_update.sh"
	"efi_update.hook"
	"reboot-win10"
	"reboot-grub"
	"efikeys.tar.xz"
	"ldlocal.conf"
)
sha1sums=(
	'2fc3bb495e27cc42d9317f7cfcec7a037f696883'
	'4d18f81575e0cd12184cf84f2c1febca8819ec08'
	'44a1bfb86c0d2605f0fc3ba8fe345c1227dd27ee'
	'e64a5d44dd4f4b346502a61fd7ad955191c80397'
	'6e1134f36f628a77797ba10278e6e40bcc5e302d'
	'ffa441f6aecaff47beedc200626292f0c71fa607'
)

package() {
	cd "$srcdir"
	install -Dm700 "efi_update.sh" "$pkgdir/usr/local/bin/efi_update.sh"
	install -Dm700 "reboot-win10" "$pkgdir/usr/local/bin/reboot-win10"
	install -Dm700 "reboot-grub" "$pkgdir/usr/local/bin/reboot-grub"
	install -Dm644 "efi_update.hook" "$pkgdir/etc/pacman.d/hooks/efi_update.hook"
	install -Dm600 "ISK.key" "$pkgdir/etc/efikeys/ISK.key"
	install -Dm600 "ISK.pem" "$pkgdir/etc/efikeys/ISK.pem"
	install -Dm600 "KEK.key" "$pkgdir/etc/efikeys/KEK.key"
	install -Dm600 "KEK.pem" "$pkgdir/etc/efikeys/KEK.pem"
	install -Dm600 "MsWin.pem" "$pkgdir/etc/efikeys/MsWin.pem"
	install -Dm600 "PK.key" "$pkgdir/etc/efikeys/PK.key"
	install -Dm600 "PK.pem" "$pkgdir/etc/efikeys/PK.pem"
	install -Dm600 "UEFI.pem" "$pkgdir/etc/efikeys/UEFI.pem"
	install -Dm600 "efikeys.tar.xz" "$pkgdir/etc/efikeys/efikeys.tar.xz"
	install -Dm644 "ldlocal.conf" "$pkgdir/etc/ld.so.conf.d/local.conf"
	chmod -R 600 $pkgdir/etc/efikeys
}
