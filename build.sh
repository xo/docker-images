#!/bin/bash

SRC=$(realpath $(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd))

ORG=usql

set -e

for DB in ignite; do
  pushd $SRC/$DB &> /dev/null
  IMAGE=$(cat Dockerfile|grep FROM|awk '{print $2}')
  (set -x;
    docker build --pull -t $ORG/$DB:latest .
  )
  docker push $ORG/$DB:latest
  popd &> /dev/null
done
