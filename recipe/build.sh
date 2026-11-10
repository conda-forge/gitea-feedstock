#!/bin/sh

set -eux

# For debugging
env | sort

# Default LDFLAGS from conda environment break the build:
#   flag provided but not defined: [LDFLAGS]
#   usage: link [options] main.o
unset LDFLAGS

# Used by Makefile to include version in binary
echo $PKG_VERSION > VERSION

# https://github.com/go-gitea/gitea/blob/0d59b737aa7a0200f8334cbfa29e5056390b4845/Dockerfile
export TAGS="bindata timetzdata"
make frontend
# Remove frontend packages to prevent go generate from discovering Go packages in Library/pnpm.
#   pattern ./...: directory Library/pnpm/.../flatted/golang/pkg/flatted outside main module or its selected dependencies
#   make: *** [Makefile:508: generate-go] Error 1
rm -rf $PREFIX/Library/pnpm

make generate-backend
make gitea

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
