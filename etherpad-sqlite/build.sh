#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail


# download the latest image from
# https://hub.docker.com/repository/docker/etherpad/etherpad
# and extract the versions

docker pull etherpad/etherpad:latest
VERSION=$(docker image inspect --format '{{json .}}' etherpad/etherpad:latest | jq -r '.Config.Labels."org.opencontainers.image.version"')
MINOR=${VERSION%.*}
MAJOR=${MINOR%.*}

if [ "$VERSION" == "null" ]; then
  echo 'Unable to extract version' >&2
  exit 1
fi

if [[ -z "$MINOR" ]]; then
  echo 'Unable to extract version' >&2
  exit 1
fi

if [[ -z "$MAJOR" ]]; then
  echo 'Unable to extract version' >&2
  exit 1
fi

docker build \
  -t tiimb/etherpad-sqlite:latest \
  -t tiimb/etherpad-sqlite:$VERSION \
  -t tiimb/etherpad-sqlite:$MINOR \
  -t tiimb/etherpad-sqlite:$MAJOR .


docker push tiimb/etherpad-sqlite:latest
docker push tiimb/etherpad-sqlite:$VERSION
docker push tiimb/etherpad-sqlite:$MINOR
docker push tiimb/etherpad-sqlite:$MAJOR

echo "Built the following tags:"
echo " * latest"
echo " * $VERSION"
echo " * $MINOR"
echo " * $MAJOR"
