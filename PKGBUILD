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
	"linux-efi-upgrade.sh"
	"linux-efi.hook"
)
sha1sums=('1f05c24c60f80b8d1be61dcffbfebc36233b4aaa'
          '9d26bc4f66202c03c8c15d2cc2a59cf9c95b1abd')

package() {
	cd "$srcdir"
	install -Dm700 "$srcdir/linux-efi-upgrade.sh" "$pkgdir/usr/share/libalpm/scripts/linux-efi-upgrade"
	install -Dm644 "$srcdir/linux-efi.hook" "$pkgdir/usr/share/libalpm/hooks/99-linux-efi.hook"
}
# vim: set ts=4 sw=0 noexpandtab autoindent :
