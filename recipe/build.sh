#!/bin/sh

set -eux

# For debugging
env | sort

# Default LDFLAGS from conda environment break the build on Linux
if [ "$GOOS" = linux ]; then
  unset LDFLAGS
fi

# Used by Makefile to include version in binary
echo $PKG_VERSION > VERSION

TAGS="bindata sqlite sqlite_unlock_notify" make build

mkdir -p $PREFIX/bin
cp gitea $PREFIX/bin/gitea

# Cross-compilation: check correct architecture was built
if [ -n "$GOARCH" ]; then
  if [ "$GOOS" = darwin ]; then
    if [ "$GOARCH" = arm64 ]; then
      PATTERN="Mach-O.+arm64"
    else
      PATTERN="Mach-O.+x86_64"
    fi
  else
    if [ "$GOARCH" = arm64 ]; then
      PATTERN="ELF.+aarch64"
    else
      PATTERN="ELF.+x86-64"
    fi
  fi

  file $PREFIX/bin/gitea | grep -E "$PATTERN"
fi

# There are non-go files
go-licenses save . --save_path=./license-files || true
test -d license-files/github.com
