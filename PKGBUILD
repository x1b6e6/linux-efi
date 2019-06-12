# Maintainer: Jguer <joaogg3@gmail.com>
pkgname=linux-old
pkgver=0.1.1
pkgrel=1
pkgdesc="old files"
arch=('i686' 'x86_64' 'armv7h' 'armv6h' 'aarch64')
depends=('binutils' 'sbsigntools' 'efibootmgr')

source=(
	"efi_update.sh"
	"efi_update.hook"
	"reboot-win10"
	"reboot-grub"
	"efikeys.tar.xz"
	"ldlocal.conf"
)
sha1sums=(
	'9a8845398be3b8bd5b3eea963c54981fde74241c'
	'00bba33f5cb898708791cf00b0bfd461d32700d4'
	'44a1bfb86c0d2605f0fc3ba8fe345c1227dd27ee'
	'e64a5d44dd4f4b346502a61fd7ad955191c80397'
	'984f298fb1cd268ddc83bcaac0b868e4d2e8c92e'
	'ffa441f6aecaff47beedc200626292f0c71fa607'
)

package() {
	cd "$srcdir"
	install -Dm700 "efi_update.sh" "$pkgdir/usr/bin/efi_update"
	install -Dm700 "reboot-win10" "$pkgdir/usr/bin/reboot-win10"
	install -Dm700 "reboot-grub" "$pkgdir/usr/bin/reboot-grub"
	install -Dm644 "efi_update.hook" "$pkgdir/usr/share/libalpm/hooks/99-efi_update.hook"
	install -Dm600 "key.key" "$pkgdir/etc/efikeys/key.key"
	install -Dm600 "key.crt" "$pkgdir/etc/efikeys/key.crt"
	install -Dm600 "efikeys.tar.xz" "$pkgdir/etc/efikeys/efikeys.tar.xz"
	install -Dm644 "ldlocal.conf" "$pkgdir/etc/ld.so.conf.d/local.conf"
	chmod -R 600 $pkgdir/etc/efikeys
}
