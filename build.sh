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
  IMAGE=$(cat Dockerfile|grep FROM|awk '{print $2}')
  (set -x;
    docker build --pull -t $ORG/$DB:latest .
  )
  docker push $ORG/$DB:latest
  popd &> /dev/null
done
