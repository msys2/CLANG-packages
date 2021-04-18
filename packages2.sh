#!/bin/bash -x

pkgs=(clang
      $( true || [[ $MSYSTEM == *ARM* ]] || echo "rust" )
)

