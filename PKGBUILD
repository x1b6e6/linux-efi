# Maintainer: x1b6e6 <ftdabcde@gmail.com>

pkgname=linux_efi
pkgver=0.2.0
pkgrel=1
pkgdesc="sign efi hook"
arch=('any')
depends=('sbsigntools' 'efibootmgr' 'expect' 'openssl' 'efivar')

CMDLINED=/etc/cmdline.d
TMP=/tmp/linux_efi
TMP_CMDLINED=$TMP/cmdline.di
EFIKEYS=/etc/efikeys

source=(
	"linux_efi_upgrade.sh"
	"linux_efi.hook"
	"linux_efi.install"
	"ms.esl"
)
sha1sums=(
	'c824c2e06ab8d90e524a35645a33eb24a6146af3'
	'c9a8e9fdd431b22837e32af123dc91c9eb5f1b8d'
	'26e4f3bc20677acc2d59691cded9469b72ca014b'
	'52a296ac12ed09058d227a056cf6d4b3d6ac2760'
)

install=linux_efi.install

package() {
	cd "$srcdir"
	install -Dm700 "$srcdir/linux_efi_upgrade.sh" "$pkgdir/usr/share/libalpm/scripts/linux_efi_upgrade"
	install -Dm644 "$srcdir/linux_efi.hook" "$pkgdir/usr/share/libalpm/hooks/99-linux_efi.hook"
	install -Dm444 "$srcdir/ms.esl" "$pkgdir$EFIKEYS/ms.esl"
}
# vim: set ts=4 sw=0 noexpandtab autoindent :
