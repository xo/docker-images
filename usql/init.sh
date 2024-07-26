#!/bin/bash

SRC=$(realpath $(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd))

OUT=$SRC/out
REPO=xo/usql
TARGET=amd64
VERSION=

OPTIND=1
while getopts "t:v:" opt; do
case "$opt" in
  t) TARGET=$OPTARG ;;
  v) VERSION=$OPTARG ;;
esac
done

set -e

(set -x;
  mkdir -p $OUT
)

# get latest
if [ -z "$VERSION" ]; then
  VERSION=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | jq -r .tag_name)
fi

# check version
if ! [[ $VERSION =~ ^v[0-9\.]+$ ]]; then
  echo "ERROR: invalid version '$VERSION'"
  exit 1
fi

NAME="usql-${VERSION#v}-linux-$TARGET"
URL="https://github.com/xo/usql/releases/download/$VERSION/$NAME.tar.bz2"
ARCHIVE="$OUT/$NAME.tar.bz2"

if [ ! -f $ARCHIVE ]; then
  (set -x;
    curl -L -o "$ARCHIVE" "$URL"
  )
fi

DEST=$OUT/${VERSION#v}-$TARGET
(set -x;
  rm -rf $DEST
  mkdir -p $DEST
  tar -C $DEST -jxvf $ARCHIVE
)
