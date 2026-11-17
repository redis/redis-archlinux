# [DRAFT] Redis 8 for Archlinux


This work is based on https://aur.archlinux.org/packages/redis

Experimental packaging of Redis 8 with its bundled modules, derived from the AUR package https://aur.archlinux.org/packages/redis. Built from the official release asset.

This file summarizes the changes and the lessons learned, it is not meant to stay in the package long term.


# Installing from the Redis repository

Redis publishes signed builds of this package to its own pacman repositories. `[redis]` carries GA releases. `[redis-testing]` carries release candidates, milestones and internal builds.

Import and locally sign the packaging key. `[redis]` and `[redis-testing]` are signed with different keys, so use the key of the repository you add:

```sh
# TODO: replace with the published key URL and fingerprint of each repository
curl -fsSLo redis-packages.asc <KEY_URL>
sudo pacman-key --add redis-packages.asc
sudo pacman-key --lsign-key <KEY_FINGERPRINT>
```

Add one of the repositories to `/etc/pacman.conf`. Packages are signed, the repository database is not, hence `DatabaseOptional`.

```ini
[redis]
SigLevel = Required DatabaseOptional
Server = https://packages.redis.io/arch/$arch
```

```ini
[redis-testing]
SigLevel = Required DatabaseOptional
Server = https://redis-test-package-repository.s3.us-east-2.amazonaws.com/arch-testing/$arch
```

Then install with `sudo pacman -Syu redis`.


# Highlights

The things I found important while doing this work.


## LTO is handled by the Redis build
Redis and its modules use the `LTO` variable to arrange optimizations for mixed C/C++/Rust code, so the Arch one is disabled.

## Flag propagation
Workarounds are needed to reliably pass Arch's compiler and linker flags down to the module builds, which otherwise override or ignore them.

## Jemalloc
The bundled jemalloc is used because it carries modifications Redis relies on (active defragmentation and the usable-size allocation API) and because it takes part in LTO this way. There are no performance numbers for the difference, so reverting to system jemalloc remains an option.


## Offline build
prepare() and build() are separated so that the build runs without network access. For this, cargo dependencies are fetched with `--locked` and built through a `cargo --frozen` wrapper, and several search dependencies that CMake would otherwise download are declared as sources. Validated by running `makepkg -os` followed by `makepkg -e` with sealed network. CI builds the package the same way, so a build step that starts to need the network fails.

## Debug symbols
Search and json strips debug info, so I have to use unstripped objects to delegate it to makepkg.

## Licensing
The license array lists SPDX identifiers that cover the shipped code, the original notices of the bundled  dependencies are also installed. Licensing does not enumerate the Rust dependencies. I tried that, but it exploded the PKGBUILD with license discovery, rendering and extra tooling, so it was dropped.


## Module loading
Module loading is implemented with a `modules.conf` passed in `ExecStart`. This allows seamless upgrades when `redis.conf` has been modified and better reflects the fact that the modules are vendored in by default.
Passing it through an environment variable in `ExecStart` allows opting out by overriding the variable in a systemd drop-in.
In addition new `--config-rewrite-source-aware yes` option is used to avoid duplicating configuration when `CONFIG REWRITE` is used.

## `/etc/redis` Permissions
`/etc/redis` is made writable by the service user so that `CONFIG REWRITE` works correctly.

## PidFile
pidfile is supressed in the unit configuration, since redis is managed by systemd and there is no need of pidfile, in addition default pidfile from the upstream config uses non-writable directory anyway

# Lessons and what could be simplified upstream

## A standard way to accept the build system's compiler and linker flags
Currently workarounds are needed to propagate the distribution's compiler and linker flags to the modules. This should probably be handled by the module build systems themselves: honour `CFLAGS`, `CXXFLAGS` and `LDFLAGS` from the environment instead of overriding or ignoring them.

## Separate build and install
Currently `make deploy` (and `make install`) starts a second build. There should be a way to install the already built artifacts without rebuilding, and without stripping them: packaging has to stage the files by hand to keep the tested binaries and their debug information.

## Better and more transparent handling of licensing
More effort should go into licensing: all used dependencies should be covered, ideally in a common way across Redis and the modules. REUSE, which Arch uses, could probably help.

## Better support for offline builds
Ideally there would be a tool that prepares an offline build, or a `make` flag indicating that everything is already available offline.

## man pages
Man pages are completely missing in upstream distribution. This needs to be addressed.
