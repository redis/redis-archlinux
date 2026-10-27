# Maintainer: Andrew Crerar <crerar@archlinux.org>
# Maintainer: Frederik Schwan <freswa at archlinux dot org>
# Contributor: Sergej Pupykin <pupykin.s+arch@gmail.com>
# Contributor: Bartłomiej Piotrowski <bpiotrowski@archlinux.org>
# Contributor: Jan-Erik Rediger <badboy at archlinux dot us>
# Contributor: nofxx <x@<nick>.com>

pkgname=redis
pkgver=8.10.2
pkgrel=6
pkgdesc='An in-memory database that persists on disk'
arch=('x86_64' 'aarch64')
url='https://redis.io/'
license=('AGPL-3.0-only' 'BSD-2-Clause')
# Let upstream coordinate C/C++ and Rust LTO instead of injecting makepkg flags.
options=('!lto')
depends=('glibc' 'libgcc' 'libstdc++' 'openssl' 'zstd' 'grep' 'shadow' 'systemd-libs')
# pkg-config fails to detect systemd libraries if systemd is not installed
makedepends=('clang' 'cmake' 'git' 'lld' 'python' 'python-pip' 'rust' 'systemd')
backup=('etc/redis/redis.conf'
        'etc/redis/sentinel.conf')
install=redis.install
source=("${pkgname}-${pkgver}.tar.gz::https://github.com/redis/redis/releases/download/${pkgver}/redis-full.tar.gz"
        redis.service
        redis-sentinel.service
        redis.sysusers
        redis.tmpfiles
        redis.conf-sane-defaults.patch
        redisjson-build-library-only.patch
        redis-smoke-test.sh)
sha512sums=('e06f570b741bec9e1b34e65a211c2c59bc1d4220b6d2ef06fc00c0e99bdec29a0bc15a81fd0fc24c56a1c61d9c3e35aabc3cb292abd5cf034012020a3aef2cff'
            '8abf27f173a4532295dafd91b8e6e226e4376f1b2543c911e4fa60466d50523ada4dcfe520a738fd756c5725f4319153a0c0b26f6cdba234775114c72e4e7865'
            '2314c26920f5f0989fb98622f594b621a0b5035525146263da3fdfe640257118e03fc1903c15a62bcd4fbf260e0dcbf9249088292323739a607a11c9630795bf'
            '52a36e44dd0ebfbc75d4849c66fa68cedd8ab0dcdcaaf0e3ac92f1dfe9fbd538a3b98e0658c88295b4c9f61334445f887decbccee210d0b4e7c5b456485599d1'
            '149e56c5da953e61d2f3864949c38d3f36d2ab1af6c74571ae36fa9ec991dee93dcac81e3caff69ac581a5218405f3e896b5dc58b9474f997bff48f5af06ee68'
            'f45b5d20769159faeeb705e1bb9e4fdc3d74c0779b476cada829bfb49014c6ba6cd78d1d2751bf39acb6db4528281e9cab3aca684cadf687eb5fad10c7453154'
            '65183fd80bdf525a14283197260af082b5f4938aef1bed87f65b83e3913ee434bc7808804afd75d94091d46c8bb5864a5ba0108877a05a7da73007a5a0e1ffc6'
            '6a49672c49591ab89aa24bfe50ddd686cfb1c00f0259f235cfd4649212de970e5c82e79a1e815c30731ee35b0e199e0e2df77ed7ab8eaa898593ff3dda90144a')

prepare() {
  cd $pkgname-$pkgver
  patch -Np1 < ../redis.conf-sane-defaults.patch
  patch -Np1 < ../redisjson-build-library-only.patch
}

build() {
  # Redis's jemalloc provides active defrag and usable-size allocation APIs.
  make MALLOC=jemalloc \
       BUILD_TLS=yes \
       BUILD_COMPRESSION=yes \
       USE_SYSTEMD=yes \
       LTO=1 \
       IGNORE_MISSING_DEPS=1 \
       build \
       -C $pkgname-$pkgver
}

check() {
  cd $pkgname-$pkgver
  bash "$srcdir/redis-smoke-test.sh" \
       "$PWD/src/redis-server" \
       "$PWD/src/redis-cli" \
       "$PWD/modules/redisbloom/redisbloom.so" \
       "$PWD/modules/redisearch/redisearch.so" \
       "$PWD/modules/redisjson/rejson.so" \
       "$PWD/modules/redistimeseries/redistimeseries.so"
}

package() {
  cd $pkgname-$pkgver
  make MALLOC=jemalloc \
       BUILD_COMPRESSION=yes \
       PREFIX=/usr \
       DESTDIR="$pkgdir" \
       LTO=1 \
       IGNORE_MISSING_DEPS=1 \
       deploy
  make PREFIX=/usr/lib/redis/modules \
       ASSUME_BUILT=1 \
       sync-redis-conf

  install -Dm644 LICENSE.txt "$pkgdir"/usr/share/licenses/redis/LICENSE
  install -Dm644 deps/jemalloc/COPYING "$pkgdir"/usr/share/licenses/redis/jemalloc-COPYING
  install -Dm644 redis-full.conf "$pkgdir"/etc/redis/redis.conf
  install -Dm644 sentinel.conf "$pkgdir"/etc/redis/sentinel.conf
  install -Dm644 -t "$pkgdir"/usr/lib/systemd/system/ ../redis.service ../redis-sentinel.service
  install -Dm644 "$srcdir"/redis.sysusers "$pkgdir"/usr/lib/sysusers.d/redis.conf
  install -Dm644 "$srcdir"/redis.tmpfiles "$pkgdir"/usr/lib/tmpfiles.d/redis.conf
}
