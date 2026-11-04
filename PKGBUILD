# Maintainer: Andrew Crerar <crerar@archlinux.org>
# Maintainer: Frederik Schwan <freswa at archlinux dot org>
# Contributor: Sergej Pupykin <pupykin.s+arch@gmail.com>
# Contributor: Bartłomiej Piotrowski <bpiotrowski@archlinux.org>
# Contributor: Jan-Erik Rediger <badboy at archlinux dot us>
# Contributor: nofxx <x@<nick>.com>

pkgname=redis
pkgver=8.12rc2
pkgrel=3
_tag=${pkgver/rc/-rc}
pkgdesc='An in-memory database that persists on disk'
arch=('x86_64')
url='https://redis.io/'
license=('AGPL-3.0-only' 'BSD-2-Clause' 'BSD-3-Clause' 'MIT' 'BSL-1.0' 'Apache-2.0')
# Let upstream coordinate C/C++ and Rust LTO instead of injecting makepkg flags.
options=('!lto')
depends=('glibc' 'libgcc' 'libstdc++' 'openssl' 'zstd' 'grep' 'shadow' 'systemd-libs')
# pkg-config fails to detect systemd libraries if systemd is not installed
makedepends=('clang' 'cmake' 'git' 'lld' 'python' 'rust' 'systemd')
backup=('etc/redis/redis.conf'
        'etc/redis/sentinel.conf')
install=redis.install
_boostver=1.88.0
_cpu_featuresver=0.10.1
_evever=2023.02.15
_robinmapver=1.4.0
_fmtver=12.1.0
_spdlogver=1.15.3
_tomlplusplusver=3.3.0
source=("https://github.com/redis/redis/releases/download/${_tag}/redis-full-${_tag}.tar.gz"
        "boost-${_boostver}.tar.gz::https://github.com/boostorg/boost/releases/download/boost-${_boostver}/boost-${_boostver}-b2-nodocs.tar.gz"
        "cpu_features-${_cpu_featuresver}.tar.gz::https://github.com/google/cpu_features/archive/refs/tags/v${_cpu_featuresver}.tar.gz"
        "eve-${_evever}.tar.gz::https://github.com/jfalcou/eve/archive/refs/tags/v${_evever}.tar.gz"
        "robin-map-${_robinmapver}.tar.gz::https://github.com/Tessil/robin-map/archive/refs/tags/v${_robinmapver}.tar.gz"
        "fmt-${_fmtver}.tar.gz::https://github.com/fmtlib/fmt/archive/refs/tags/${_fmtver}.tar.gz"
        "spdlog-${_spdlogver}.tar.gz::https://github.com/gabime/spdlog/archive/refs/tags/v${_spdlogver}.tar.gz"
        "tomlplusplus-${_tomlplusplusver}.tar.gz::https://github.com/marzer/tomlplusplus/archive/refs/tags/v${_tomlplusplusver}.tar.gz"
        redis.service
        redis-modules.conf
        redis-sentinel.service
        redis.sysusers
        redis.tmpfiles
        redis.conf-sane-defaults.patch
        redis-smoke-test.sh
        redis-module-flags.mk
        redis-search-linker-flags.cmake
        redis-cargo-frozen
        'svs-gcc16-mutex.patch::https://github.com/intel/ScalableVectorSearch/commit/87251338cdc792dc2f1e6f2a58164e7a27f70b6b.patch')
sha512sums=('f79f0b8932599327ee1d88d9db0e4b53b870e36b8f42cd003843fcc14fadae12af3f612be89d81c8abc8d6bcb11d9d83b32a30308642c5eb72a7c70c1e3e90b9'
            'c5e6bd31e6fe9ee7c97d833b9d35fad3dfa3bddb424c8f4b35e1c79c6d3ad231da667ee9c753df789621f5c8b2665816916368d6e95c446fa970a46a2c3cb994'
            '40c314c584fcf109d9a641c055cb75f335fd5425dd336fe831828b956226eaf0ac2fd8ffceeaf10e02afa9cec01cb0ddc6af8ff78f20dd925783e6958d0b9304'
            '20b55996465fa5016d43cee95541510b6470b2358635b0e269965d3fb43731e83b92bc2df0502fcdfadd31de47f877f22b1c6ae84638f1f3db92c70315cc1b29'
            'd65831ac9d1ae1b26d26386ee06835d788d18529d1cd9132f892091377572b2f9d68aaecfce79956238d327764fea7a144ad2922ced3cbe47cda8734b2df419f'
            'f0da82c545b01692e9fd30fdfb613dbb8dd9716983dcd0ff19ac2a8d36f74beb5540ef38072fdecc1e34191b3682a8542ecbf3a61ef287dbba0a2679d4e023f2'
            '21c35f4091850ea3a0cd6a24867e06e943df70d76cd5a7ec0b15a33e0e9e0cc3584ed7930e1ac6f347e7e06f0e002d0e759884eaf05310014e24ea0e0419fcc4'
            '6ab2de83b7fc44de40e58a47c28a9507bf7c50fa9b08925b5a6d48958868a86e6790aff684d29ceb50ad18905e3832840719e1b7bfec3b8a0c00b15bb0f70f38'
            '2a48310f9814f9b74b2f70cf6dba19b2ca32434bcfbc54745faac0371bb3d74e2b46d7d02965355de4d68c49b576cc6ee55791668e58b68802fc04db4d6b1ac4'
            '0431b93f8f610ef9b9c12bf708039de86acb2eed24096c8f25f056db6a54471700b26cf086a47d4ffc66341edd3d187c7711c59adbb6ad9617b922a2abd4d598'
            'fd1cb56cf91100c2868f17445f330c295a704756445ea59b1c4d5632e8156fa19ab01024c72a71a4f1671be7c7db0d50455f629e118d835dbc57d0be8395359f'
            '52a36e44dd0ebfbc75d4849c66fa68cedd8ab0dcdcaaf0e3ac92f1dfe9fbd538a3b98e0658c88295b4c9f61334445f887decbccee210d0b4e7c5b456485599d1'
            '1dccce3fb9c90f8bb5f7e9dab3937a58820e8094694e13b6b5e2ca97cad01d3156c0e8647bc4e2e0a3f28cfd59e8825d9e5ccfffcd78e12451cbbb6d46981777'
            'f45b5d20769159faeeb705e1bb9e4fdc3d74c0779b476cada829bfb49014c6ba6cd78d1d2751bf39acb6db4528281e9cab3aca684cadf687eb5fad10c7453154'
            '6a49672c49591ab89aa24bfe50ddd686cfb1c00f0259f235cfd4649212de970e5c82e79a1e815c30731ee35b0e199e0e2df77ed7ab8eaa898593ff3dda90144a'
            '39278366dd71821cb4be11a3b55913ae6bdb44c0a87aadab397d0002ddec4bd47e98693a3aec2525894b36eece7887440420a4a39a953bfe9a5cf3ec1c69476a'
            '63225410ee53b185fcb295240049a8fb7b00f2bcfbbd4e02577bcb2b32136b8a6b2d997bc44977ee9f382d6032d6381210f59abecbabdbdbde0c326e47bea2c0'
            'a14c884985542b876f715fc1ef1b6d1fff103d8979c0ccff2f523f48677f6d23594b43d5f88a571351dc5eaeefa3a3fc9be3fc48898be57a2160b82250b47bbc'
            '807f1c5f8a0a5b45616382a2748fb9bd082eb25a9c229ce2f41f66bd574cd11549cc17487c8236c40a70970a20809a855b7f9b5954166052442d9f654d7949a0')

prepare() {
  local workspace
  export CARGO_HOME="$srcdir/cargo-home"
  install -Dm755 "$srcdir/redis-cargo-frozen" "$srcdir/redis-build-tools/cargo"
  # Fix GCC 16 builds until bundled SVS includes upstream #397.
  patch -Np1 -d "$srcdir/$pkgname-$_tag/modules/redisearch/src/deps/VectorSimilarity/deps/ScalableVectorSearch" < \
    "$srcdir/svs-gcc16-mutex.patch"
  # Local FetchContent overrides bypass upstream's dependency patch step.
  patch -Np1 -d "$srcdir/tomlplusplus-$_tomlplusplusver" < \
    "$srcdir/$pkgname-$_tag/modules/redisearch/src/deps/VectorSimilarity/deps/ScalableVectorSearch/cmake/patches/tomlplusplus_v330.patch"
  cd "$pkgname-$_tag"
  patch -Np1 < ../redis.conf-sane-defaults.patch
  for workspace in modules/redisjson/src modules/redisearch/src/src/redisearch_rs; do
    (cd "$workspace" && /usr/bin/cargo fetch --locked --target host-tuple)
  done
}

build() {
  export CARGO_HOME="$srcdir/cargo-home"
  export CARGO_NET_OFFLINE=true
  export CARGO="$srcdir/redis-build-tools/cargo"
  export PATH="$srcdir/redis-build-tools:$PATH"
  export MAKEFILES="${MAKEFILES:+$MAKEFILES }$srcdir/redis-module-flags.mk"
  export CMAKE_ARGS="${CMAKE_ARGS:+$CMAKE_ARGS }-DCMAKE_PROJECT_redisearch_INCLUDE=$srcdir/redis-search-linker-flags.cmake \
    -DCARGO_EXECUTABLE=$CARGO \
    -DBOOST_DIR=$srcdir/boost-$_boostver \
    -DFETCHCONTENT_SOURCE_DIR_CPU_FEATURES=$srcdir/cpu_features-$_cpu_featuresver \
    -DFETCHCONTENT_SOURCE_DIR_EVE=$srcdir/eve-$_evever \
    -DFETCHCONTENT_SOURCE_DIR_ROBINMAP=$srcdir/robin-map-$_robinmapver \
    -DFETCHCONTENT_SOURCE_DIR_FMT=$srcdir/fmt-$_fmtver \
    -DFETCHCONTENT_SOURCE_DIR_SPDLOG=$srcdir/spdlog-$_spdlogver \
    -DFETCHCONTENT_SOURCE_DIR_TOMLPLUSPLUS=$srcdir/tomlplusplus-$_tomlplusplusver \
    -DFETCHCONTENT_FULLY_DISCONNECTED=ON"
  # Redis's jemalloc provides active defrag and usable-size allocation APIs.
  make MALLOC=jemalloc \
       BUILD_TLS=yes \
       BUILD_COMPRESSION=yes \
       USE_SYSTEMD=yes \
       LTO=1 \
       IGNORE_MISSING_DEPS=1 \
       build \
       -C "$pkgname-$_tag"
}

check() {
  cd "$pkgname-$_tag"
  bash "$srcdir/redis-smoke-test.sh" \
       "$PWD/src/redis-server" \
       "$PWD/src/redis-cli" \
       "$PWD/modules/redisbloom/redisbloom.so" \
       "$PWD/modules/redisearch/redisearch.so" \
       "$PWD/modules/redisjson/rejson.so" \
       "$PWD/modules/redistimeseries/redistimeseries.so"
}

package() {
  local binary module notice component
  cd "$pkgname-$_tag"
  # Stage the artifacts tested by check(); deploy would invoke another build.
  for binary in redis-server redis-cli redis-benchmark; do
    install -Dm755 "src/$binary" "$pkgdir/usr/bin/$binary"
  done
  for binary in redis-sentinel redis-check-rdb redis-check-aof; do
    ln -sf redis-server "$pkgdir/usr/bin/$binary"
  done
  for module in redisbloom/redisbloom.so redistimeseries/redistimeseries.so; do
    install -Dm755 "modules/$module" "$pkgdir/usr/lib/redis/modules/${module##*/}"
  done
  # Upstream strips the staged Search/JSON libraries.
  # Search's .debug is a full ELF; Cargo keeps JSON's unstripped library.
  # Let makepkg split their debug information.
  install -Dm755 "modules/redisearch/src/bin/linux-x64-release/search-community/redisearch.so.debug" \
    "$pkgdir/usr/lib/redis/modules/redisearch.so"
  install -Dm755 "modules/redisjson/src/bin/linux-x64-release/target/release/librejson.so" \
    "$pkgdir/usr/lib/redis/modules/rejson.so"
  make PREFIX=/usr/lib/redis/modules \
       ASSUME_BUILT=1 \
       sync-redis-conf
  # The service loads vendor modules separately; keep their configuration documentation.
  sed -i '/^[[:space:]]*loadmodule[[:space:]]/d' redis-full.conf
  install -Dm644 "$srcdir/redis-modules.conf" "$pkgdir/usr/lib/redis/modules.conf"

  install -Dm644 LICENSE.txt "$pkgdir"/usr/share/licenses/redis/LICENSE
  install -Dm644 -t "$pkgdir/usr/share/licenses/redis" \
    REDISCONTRIBUTIONS.txt modules/redisearch/src/THIRD_PARTY_NOTICES.md
  for notice in \
      lua:deps/lua/COPYRIGHT \
      jemalloc:deps/jemalloc/COPYING \
      hdr_histogram:deps/hdr_histogram/LICENSE.txt \
      tre:deps/tre/LICENSE \
      xxhash:deps/xxhash/LICENSE \
      hiredis:deps/hiredis/COPYING \
      t-digest-c:modules/redisbloom/src/deps/t-digest-c/LICENSE.md \
      libuv:modules/redisearch/src/deps/libuv/LICENSE \
      libnu:modules/redisearch/src/deps/libnu/LICENSE \
      miniz:modules/redisearch/src/deps/miniz/LICENSE \
      snowball:modules/redisearch/src/deps/snowball/COPYING \
      libevent:modules/redistimeseries/src/deps/LibMR/deps/libevent/LICENSE \
      "fmt:$srcdir/fmt-$_fmtver/LICENSE" \
      "spdlog:$srcdir/spdlog-$_spdlogver/LICENSE" \
      "tomlplusplus:$srcdir/tomlplusplus-$_tomlplusplusver/LICENSE" \
      "robin-map:$srcdir/robin-map-$_robinmapver/LICENSE"; do
    component=${notice%%:*}
    notice=${notice#*:}
    install -Dm644 "$notice" "$pkgdir/usr/share/licenses/redis/$component/${notice##*/}"
  done
  install -Dm640 redis-full.conf "$pkgdir"/etc/redis/redis.conf
  install -Dm640 sentinel.conf "$pkgdir"/etc/redis/sentinel.conf
  install -Dm644 -t "$pkgdir"/usr/lib/systemd/system/ ../redis.service ../redis-sentinel.service
  install -Dm644 "$srcdir"/redis.sysusers "$pkgdir"/usr/lib/sysusers.d/redis.conf
  install -Dm644 "$srcdir"/redis.tmpfiles "$pkgdir"/usr/lib/tmpfiles.d/redis.conf
}
