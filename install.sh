#!/bin/bash

# sudo loginctl enable-linger $USER
# systemctl enable --now --user usql-images.timer

SRC=$(realpath $(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd))

set -e

(set -x;
  mkdir -p $HOME/.config/systemd/user
  cp $SRC/usql-images.{service,timer} $HOME/.config/systemd/user
  systemctl daemon-reload --user
)
