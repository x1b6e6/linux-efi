# Maintainer: x1b6e6 <ftdabcde@gmail.com>

mod=

pkgname=linux${mod}_efi
pkgver=0.2.0
pkgrel=1
pkgdesc="sign efi hook"
arch=('any')
depends=('sbsigntools' 'efibootmgr' 'expect' 'openssl' 'efivar')

CMDLINED=/etc/cmdline.d
TMP=/tmp/linux${mod}_efi
TMP_CMDLINED=$TMP/cmdline.di
EFIKEYS=/etc/efikeys

source=(
	"linux_efi_upgrade.sh.in"
	"linux_efi.hook.in"
	"linux_efi.install"
	"ms.esl"
)
sha1sums=(
	'e95bb0017d211b340239901242e557dbd8209900'
	'9d0e53f52729f1330085e7642ef87d1430bd2c55'
	'26e4f3bc20677acc2d59691cded9469b72ca014b'
	'52a296ac12ed09058d227a056cf6d4b3d6ac2760'
)

install=linux_efi.install

prepare() {
	sed -e "s/%mod%/$mod/g" $srcdir/linux_efi.hook.in > $srcdir/linux${mod}_efi.hook
	sed -e "s/%mod%/$mod/g" $srcdir/linux_efi_upgrade.sh.in > $srcdir/linux${mod}_efi_upgrade.sh
}

package() {
	cd "$srcdir"
	install -Dm700 "$srcdir/linux${mod}_efi_upgrade.sh" "$pkgdir/usr/bin/linux${mod}_efi_upgrade"
	install -Dm644 "$srcdir/linux${mod}_efi.hook" "$pkgdir/usr/share/libalpm/hooks/99-linux${mod}_efi.hook"
	install -Dm444 "$srcdir/ms.esl" "$pkgdir$EFIKEYS/ms.esl"
}
# vim: set ts=4 sw=0 noexpandtab autoindent :
