#!/bin/bash

set -e

# AppVeyor and Drone Continuous Integration for MSYS2
# Author: Renato Silva <br.renatosilva@gmail.com>
# Author: Qian Hong <fracting@gmail.com>

DIR="$( cd "$( dirname "$0" )" && pwd )"

# Configure
source "$DIR/ci-library.sh"
mkdir {packages,sources}
git_config user.email 'ci@msys2.org'
git_config user.name  'MSYS2 Continuous Integration'
#git remote add upstream 'https://github.com/MSYS2/CLANG-packages'
#git fetch --quiet upstream
# reduce time required to install packages by disabling pacman's disk space checking
sed -i 's/^CheckSpace/#CheckSpace/g' /etc/pacman.conf

pacman --noconfirm -Fy

# Detect
#list_commits  || failure 'Could not detect added commits'
#list_packages || failure 'Could not detect changed files'
#message 'Processing changes' "${commits[@]}"
#test -z "${packages}" && success 'No changes in package recipes'
#define_build_order || failure 'Could not determine build order'

declare -a packages
packages=(mingw-w64-clang)
if [[ $MINGW_ARCH != *ARM* ]]; then
  packages+=(mingw-w64-libmangle-git mingw-w64-tools-git mingw-w64-headers-git mingw-w64-crt-git mingw-w64-winpthreads-git)
fi

# Build
message 'Building packages' "${packages[@]}"
execute 'Approving recipe quality' check_recipe_quality

message 'Building packages'
for package in "${packages[@]}"; do
    echo "::group::[build] ${package}"
    execute 'Fetch keys' "$DIR/fetch-validpgpkeys.sh"
    execute 'Building binary' makepkg-mingw --noconfirm --noprogressbar --nocheck --syncdeps --rmdeps --cleanbuild
    MINGW_ARCH=clang64 execute 'Building source' makepkg-mingw --noconfirm --noprogressbar --allsource
    echo "::endgroup::"

    echo "::group::[install] ${package}"
    execute 'Installing' yes:pacman --noprogressbar --upgrade '*.pkg.tar.*'
    echo "::endgroup::"

    echo "::group::[diff] ${package}"
    cd "$package"
    for pkg in *.pkg.tar.*; do
        message "File listing diff for ${pkg}"
        pkgname="$(echo "$pkg" | rev | cut -d- -f4- | rev)"
        diff -Nur <(pacman -Fl "$pkgname" | sed -e 's|^[^ ]* |/|' | sort) <(pacman -Ql "$pkgname" | sed -e 's|^[^/]*||' | sort) || true
    done
    cd - > /dev/null
    echo "::endgroup::"

    mv "${package}"/*.pkg.tar.* packages
    mv "${package}"/${package}*.src.tar.* sources
    unset package
done

cd packages
echo "::group::Create repo"
repo-add "${MINGW_ARCH,,}.db.tar.xz" *.pkg.tar.*
echo "::endgroup::"

execute 'SHA-256 checksums' sha256sum *

success 'All packages built successfully'
