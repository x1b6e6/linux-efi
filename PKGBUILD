# Maintainer: x1b6e6 <ftdabcde@gmail.com>

pkgname=linux-efi
pkgver=1.0.0
pkgrel=1
pkgdesc="sign efi hook"
arch=('any')
depends=(
	'pacman'
	'linux-sign'
)

source=(
	"linux_efi_upgrade.sh"
	"linux_efi.hook"
)
sha1sums=('1f05c24c60f80b8d1be61dcffbfebc36233b4aaa'
          '7e280fafba7f5acc96488d30e694dcf45f09a979')

package() {
	cd "$srcdir"
	install -Dm700 "$srcdir/linux_efi_upgrade.sh" "$pkgdir/usr/share/libalpm/scripts/linux_efi_upgrade"
	install -Dm644 "$srcdir/linux_efi.hook" "$pkgdir/usr/share/libalpm/hooks/99-linux_efi.hook"
}
# vim: set ts=4 sw=0 noexpandtab autoindent :
