#!/bin/bash -x

scriptpath="$(dirname "$0")"

stepnum=$(( ${1:-1} ))

declare -a pkgs
source "${scriptpath}/packages${stepnum}.sh"

for p in "${pkgs[@]}"; do
  pushd mingw-w64-$p
  ${scriptpath}/fetch-validpgpkeys.sh
  time makepkg --config /etc/makepkg_mingw.conf --noconfirm --noprogressbar --nocheck --syncdeps --rmdeps --cleanbuild --install -f || exit $?
  time makepkg --config /etc/makepkg_mingw.conf --noconfirm --noprogressbar --allsource -f || exit $?
  rm -rf src pkg
  mv *.pkg.tar.* ../packages
  mv mingw-w64-*.src.tar.* ../sources
  popd
done
