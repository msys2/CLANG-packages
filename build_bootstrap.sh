#!/bin/bash -x

scriptpath="$(dirname "$0")"

stepnum=$(( ${1:-1} ))

declare -a pkgs
source "${scriptpath}/packages${stepnum}.sh"

for p in "${pkgs[@]}"; do
  pushd mingw-w64-$p
  ${scriptpath}/fetch-validpgpkeys.sh
  if [[ $MSYSTEM == *32 ]]; then
    i=0
    until time makepkg --config /etc/makepkg_mingw.conf --noconfirm --noprogressbar --nocheck --syncdeps --rmdeps --cleanbuild --install -f; do
      ret=$?
      (( ++i == 5 )) && exit $ret
      sleep 1
    done
  else
    time makepkg --config /etc/makepkg_mingw.conf --noconfirm --noprogressbar --nocheck --syncdeps --rmdeps --cleanbuild --install -f || exit $?
  fi
  time makepkg --config /etc/makepkg_mingw.conf --noconfirm --noprogressbar --allsource -f || exit $?
  rm -rf src pkg
  mv *.pkg.tar.* ../packages
  mv mingw-w64-*.src.tar.* ../sources
  popd
done
