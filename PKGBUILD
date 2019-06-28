# Maintainer: Jguer <joaogg3@gmail.com>
pkgname=linux-efi
pkgver=0.1.2
pkgrel=1
pkgdesc="sign efi hook"
arch=('any')
depends=('sbsigntools' 'efibootmgr' 'expect')

source=(
	"efi_update.sh"
	"efi_update.hook"
	"reboot-win10"
	"reboot-grub"
	"efikeys.tar.xz"
	"linux-efi.install"
)
sha1sums=(
	'e299eb6055553bc4b35274e51e3fbf13e1f5011c'
	'00bba33f5cb898708791cf00b0bfd461d32700d4'
	'44a1bfb86c0d2605f0fc3ba8fe345c1227dd27ee'
	'e64a5d44dd4f4b346502a61fd7ad955191c80397'
	'984f298fb1cd268ddc83bcaac0b868e4d2e8c92e'
	'7f873b781daa12fbb226e7889469cf4691116191'
)

install='linux-efi.install'

package() {
	cd "$srcdir"
	install -Dm700 "efi_update.sh" "$pkgdir/usr/bin/efi_update"
	install -Dm700 "reboot-win10" "$pkgdir/usr/bin/reboot-win10"
	install -Dm700 "reboot-grub" "$pkgdir/usr/bin/reboot-grub"
	install -Dm644 "efi_update.hook" "$pkgdir/usr/share/libalpm/hooks/99-efi_update.hook"
	install -Dm600 "key.key" "$pkgdir/etc/efikeys/key.key"
	install -Dm600 "key.crt" "$pkgdir/etc/efikeys/key.crt"
	install -Dm600 "efikeys.tar.xz" "$pkgdir/etc/efikeys/efikeys.tar.xz"
	chmod -R 600 $pkgdir/etc/efikeys
}
