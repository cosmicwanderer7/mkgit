# Maintainer: Prithvi Yewale <yewaleprithvi2002@outlook.com>
# Maintainer: Tanmay Muley <tanmaymuley009@gmail.com>

pkgname=mkgit
pkgver=VERSION
pkgrel=1
pkgdesc="A CLI tool for generating GitHub repositories and corresponding local repositories."
arch=(x86_64)
url="https://github.com/cosmicwanderer7/github-script/tree/main/mkgit"
license=('MIT')
depends=('git')
makedepends=()
source=("$pkgname-$pkgver.tar.gz"
        "$pkgname-$pkgver.patch")
noextract=()
sha256sums=()
validpgpkeys=()

prepare() {
	cd "$pkgname-$pkgver"
	patch -p1 -i "$srcdir/$pkgname-$pkgver.patch"
}

build() {
	cd "$pkgname-$pkgver"
	./configure --prefix=/usr
	make
}

check() {
	cd "$pkgname-$pkgver"
	make -k check
}

package() {
	cd "$pkgname-$pkgver"
	make DESTDIR="$pkgdir/" install
}
