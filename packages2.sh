#!/bin/bash -x

pkgs=(clang
      $( true || [[ $MSYSTEM == *ARM* ]] || echo "rust" \
        "python-setuptools-rust")
      libmangle-git
      tools-git
      headers-git
      crt-git
      winpthreads-git
      winstorecompat-git
)

