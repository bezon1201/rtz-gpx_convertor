#!/bin/sh
set -eu

if [ "$#" -ne 2 ]; then
    echo "usage: $0 /path/to/libxml2-2.15.4.tar.xz /tmp/build-directory" >&2
    exit 64
fi
archive=$1
work=$2
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
expected=98087fd181d9070724f3fbc65c7377db03038eb92bd882374daff44940138821
actual=$(shasum -a 256 "$archive" | awk '{print $1}')
if [ "$actual" != "$expected" ]; then
    echo "FAIL source checksum mismatch: $actual" >&2
    exit 65
fi
case "$(uname -s):$(uname -m)" in
    Darwin:arm64) ;;
    *) echo "FAIL qualified only on macOS arm64" >&2; exit 66 ;;
esac

mkdir -p "$work/source" "$work/build" "$work/prefix" "$work/bin"
tar -xJf "$archive" -C "$work/source"
src="$work/source/libxml2-2.15.4"
cd "$work/build"
"$src/configure" \
    --prefix="$work/prefix" \
    --disable-shared --enable-static \
    --without-catalog --without-http --without-python --without-zlib \
    --without-valid --without-xinclude \
    --with-schemas --with-reader --with-push --with-iconv
make -j2
make install

clang -std=c11 -O2 -Wall -Wextra -Werror \
    -I"$work/prefix/include/libxml2" \
    "$script_dir/harness.c" \
    "$work/prefix/lib/libxml2.a" -liconv -lpthread \
    -o "$work/bin/ip2a-harness"

if otool -L "$work/bin/ip2a-harness" | grep -qi 'libxml'; then
    echo "FAIL dynamically linked libxml2 detected" >&2
    exit 67
fi
if [ "$(lipo -archs "$work/bin/ip2a-harness")" != "arm64" ]; then
    echo "FAIL unexpected executable architecture" >&2
    exit 68
fi

echo "BUILD_PROVENANCE archive_sha256=$actual compiler=$(clang --version | sed -n '1p') arch=$(uname -m)"
echo "HOST_PROVENANCE macos=$(sw_vers -productVersion) build=$(sw_vers -buildVersion) machine=$(uname -m)"
echo "LINK_CHECK static_archive=$work/prefix/lib/libxml2.a dynamic_libxml2=absent"
"$work/bin/ip2a-harness" self-test
