# Maintainer: x1b6e6 <ftdabcde@gmail.com>

pkgname=linux-efi
pkgver=0.2.4
pkgrel=1
pkgdesc="sign efi hook"
arch=('any')
depends=('sbsigntools' 'efibootmgr' 'expect' 'openssl' 'efivar' 'llvm')
conflicts=('linux_efi')

INSTALL_MS_THIRDPARTY=1 # for thirdparty devices and software signed with Microsoft (such as VeraCrypt)
INSTALL_MS_ROOT=1       # for booting official Windows

source=(
	"linux_efi_upgrade.sh"
	"linux_efi.hook"
	"linux_efi.install"
	"msRoot.esl"
	"msThirdParty.esl"
)
sha1sums=(
	'9e4085daa8deb78479268105f2716045028daf48'
	'7e280fafba7f5acc96488d30e694dcf45f09a979'
	'9ded1892efee1b7474496905050dd1970c0c5dab'
	'db7ef2c3bcb35979607abad0c6f415546b7da003'
	'22594e7c709142c790bf56925c203544e433c148'
)

prepare(){
	# clean file
	echo "" > $srcdir/ms.esl

	# install additional certs
	((INSTALL_MS_ROOT)) && cat $srcdir/msRoot.esl >> ms.esl
	((INSTALL_MS_THIRDPARTY)) && cat $srcdir/msThirdParty.esl >> ms.esl
}

install=linux_efi.install

package() {
	cd "$srcdir"
	install -Dm700 "$srcdir/linux_efi_upgrade.sh" "$pkgdir/usr/share/libalpm/scripts/linux_efi_upgrade"
	install -Dm644 "$srcdir/linux_efi.hook" "$pkgdir/usr/share/libalpm/hooks/99-linux_efi.hook"
	install -Dm444 "$srcdir/ms.esl" "$pkgdir/etc/efikeys/ms.esl"
}
# vim: set ts=4 sw=0 noexpandtab autoindent :
