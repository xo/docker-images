#!/bin/bash

SRC=$(realpath $(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd))

ORG=usql

set -e

DATABASES=$@
if [ -z "$DATABASES" ]; then
  DATABASES="postgres cassandra ignite"
fi

for DB in $DATABASES; do
  pushd $SRC/$DB &> /dev/null
  (set -x;
    podman build --pull -t docker.io/$ORG/$DB:latest .
  )
  podman push docker.io/$ORG/$DB:latest
  popd &> /dev/null
done
