#!/bin/bash

SRC=$(realpath $(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd))

DATABASES=()
TARGETS=()
TAG=latest
PUSH=0
BASE=docker.io/usql

OPTIND=1
while getopts "d:t:g:pb:" opt; do
case "$opt" in
  d) DATABASES+=($OPTARG) ;;
  t) TARGETS+=$($OPTARG) ;;
  g) TAG=$OPTARG ;;
  p) PUSH=1 ;;
  b) BASE=$OPTARG ;;
esac
done

set -e

# determine databases
if [ ${#DATABASES[@]} -eq 0 ]; then
  DATABASES=(postgres cassandra)
fi

# determine targets
if [ ${#TARGETS[@]} -eq 0 ]; then
  TARGETS=(amd64 arm64)
fi

REPO=$(sed -e 's%^docker\.io/%%' <<< "$BASE")
for DB in ${DATABASES[@]}; do
  IMAGES=()

  # build images
  for TARGET in ${TARGETS[@]}; do
    NAME=localhost/$DB-$TARGET
    IMAGES+=($NAME)
    (set -x;
      buildah build \
        --file $SRC/$DB/Dockerfile \
        --platform linux/$TARGET \
        --tag $NAME \
        $SRC/$DB
    )
  done

  # create manifest
  MANIFEST=localhost/$DB
  if `buildah manifest exists $MANIFEST`; then
    for HASH in $(buildah manifest inspect $MANIFEST|jq -r '.manifests[]|.digest'); do
      (set -x;
        buildah manifest remove $MANIFEST $HASH
      )
    done
  else
    (set -x;
      buildah manifest create $MANIFEST
    )
  fi

  # add images
  for IMG in ${IMAGES[@]}; do
    (set -x;
      buildah manifest add $MANIFEST $IMG
    )
  done

  if [ $PUSH -eq 1 ]; then
    (set -x;
      buildah manifest push \
        --all \
        $MANIFEST \
        docker://$REPO/$DB:$TAG
    )
  fi
done
