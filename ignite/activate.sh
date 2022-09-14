#!/bin/bash

podman exec -it ignite \
  /opt/ignite/apache-ignite/bin/control.sh \
  --yes \
  --set-state ACTIVE \
  --user ignite \
  --password ignite
