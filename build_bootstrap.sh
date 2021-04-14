#!/bin/bash -x

scriptpath="$(dirname "$0")"

declare -a pkgs
pkgs=(ntldd-git
      termcap
      libiconv
      pkgconf
      expat
      gettext
      bzip2
      zlib
      xz
      lz4
      libuv
      rhash
      cmake
      zstd
      libtre-git
      libsystre
      ncurses
      gmp
      nettle
      openssl
      libarchive
      jsoncpp
      c-ares
      brotli
      libunistring
      libidn2
      libmetalink
      libpsl
      libssh2
      jansson
      jemalloc
      nghttp2
      curl
      libffi
      mpdecimal
      readline
      tcl
      tk
      sqlite3
      python
      python-six
      python-setuptools
      python-pyparsing
      python-attrs
      python-packaging
      python-ordered-set
      python-appdirs
      python-certifi
      python-wincertstore
      ninja
      meson
      libtasn1
      p11-kit
      ca-certificates
      libxml2
      libgpg-error
      libgcrypt
      libxslt
      itstool
      docbook-xml
      docbook-xsl
      python-pytz
      python-babel
      python-colorama
      python-docutils
      python-imagesize
      python-markupsafe
      python-jinja
      python-pygments
      python-idna
      python-pyasn1
      python-ply
      python-pycparser
      python-cffi
      python-asn1crypto
      python-toml
      python-semantic-version
      python-cryptography
      python-pyopenssl
      python-ndg-httpsclient
      python-funcsigs
      python-pbr
      python-mock
      python-urllib3
      python-chardet
      python-requests
      python-snowballstemmer
      python-webencodings
      python-html5lib
      python-sphinx-alabaster-theme
      python-sphinxcontrib-applehelp
      python-sphinxcontrib-devhelp
      python-sphinxcontrib-htmlhelp
      python-sphinxcontrib-jsmath
      python-sphinxcontrib-moderncmakedomain
      python-sphinxcontrib-serializinghtml
      python-sphinxcontrib-svg2pdfconverter
      python-sphinxcontrib-qthelp
      python-sphinx
      gtk-doc
      z3
      wineditline
      pcre
      lua
      swig
      $( [[ $MSYSTEM == *ARM* ]] || echo "uasm" )
      clang
      $( true || [[ $MSYSTEM == *ARM* ]] || echo "rust" \
        "python-setuptools-rust"))

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
