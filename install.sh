#!/bin/bash

# sudo loginctl enable-linger $USER
# systemctl enable --now --user build-usql-images.timer

SRC=$(realpath $(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd))

set -e

(set -x;
  mkdir -p $HOME/.config/systemd/user
  cp $SRC/build-usql-images.{service,timer} $HOME/.config/systemd/user
  systemctl daemon-reload --user
)
