# Maintainer: x1b6e6 <ftdabcde@gmail.com>

pkgname=linux-efi
pkgver=1.0.3
pkgrel=1
pkgdesc="sign efi hook"
arch=('any')
depends=(
	'pacman'
	'systemd-ukify'
)

source=(
	"linux-efi-upgrade.sh"
	"linux-efi.hook"
)
sha1sums=('11780769a58eae1e57e230e1f069923fcecae543'
          '3d9dcc21ede673f622759dac2e8d8441a5ffd3b8')

package() {
	cd "$srcdir"
	install -Dm700 "$srcdir/linux-efi-upgrade.sh" "$pkgdir/usr/share/libalpm/scripts/linux-efi-upgrade"
	install -Dm644 "$srcdir/linux-efi.hook" "$pkgdir/usr/share/libalpm/hooks/99-linux-efi.hook"
}
# vim: set ts=4 sw=0 noexpandtab autoindent :
