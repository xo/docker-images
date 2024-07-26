#!/bin/bash

SRC=$(realpath $(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd))

IMAGES=()
TARGETS=()
PUSH=0
BASE=docker.io/usql
GH_REPO=xo/usql
DOCKER_USER=kenshaw
DOCKER_PASSFILE=$HOME/.config/headless-shell/token

OPTIND=1
while getopts "d:t:pb:" opt; do
case "$opt" in
  d) IMAGES+=($OPTARG) ;;
  t) TARGETS+=$($OPTARG) ;;
  p) PUSH=1 ;;
  b) BASE=$OPTARG ;;
esac
done

set -e

# determine databases
if [ ${#IMAGES[@]} -eq 0 ]; then
  #IMAGES=(postgres cassandra)
  IMAGES=(usql)
fi

# determine targets
if [ ${#TARGETS[@]} -eq 0 ]; then
  TARGETS=(amd64 arm64)
fi

USQL_VERSION=$(curl -s "https://api.github.com/repos/$GH_REPO/releases/latest" | jq -r .tag_name)

# login
(set -x;
  buildah login docker.io \
    --username $DOCKER_USER \
    --password-stdin < $DOCKER_PASSFILE
)

# build databases
REPO=$(sed -e 's%^docker\.io/%%' <<< "$BASE")
for IMG in ${IMAGES[@]}; do
  NAMES=()

  # build images
  for TARGET in ${TARGETS[@]}; do
    if [ -x $SRC/$IMG/init.sh ]; then
      $SRC/$IMG/init.sh \
        -t "$TARGET" \
        -v "$USQL_VERSION"
    fi

    NAME=localhost/$IMG-$TARGET
    NAMES+=($NAME)
    EXTRA=()
    if [ "$IMG" = "usql" ]; then
      EXTRA=(--build-arg VERSION="${USQL_VERSION#v}-$TARGET")
    fi
    (set -x;
      buildah build \
        --file $SRC/$IMG/Dockerfile \
        --platform linux/$TARGET \
        --tag $NAME \
        ${EXTRA[@]} \
        $SRC/$IMG
    )
  done

  # create manifest
  MANIFEST=localhost/$IMG
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
  for NAME in ${NAMES[@]}; do
    (set -x;
      buildah manifest add $MANIFEST $NAME
    )
  done

  if [ $PUSH -eq 1 ]; then
    (set -x;
      buildah manifest push \
        --all \
        $MANIFEST \
        docker://$REPO/$IMG:latest
    )
    if [ "$IMG" = "usql" ]; then
      (set -x;
        buildah manifest push \
          --all \
          $MANIFEST \
          docker://$REPO/$IMG:${USQL_VERSION#v}
      )
    fi
  fi
done
