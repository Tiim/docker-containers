
VERSION="1.40.1"


NAME=tiimb/mediawiki

TS=$(date +%s)
TAG_FULL=$NAME:$VERSION-$TS
TAG_LATEST=${NAME}:latest
TAG_VERSION=$NAME:$VERSION

docker build . \
    --tag $TAG_FULL \
    --tag $TAG_LATEST \
    --tag $TAG_VERSION

docker push $TAG_FULL
docker push $TAG_LATEST
docker push $TAG_VERSION

echo "Built the following tags:"
echo " * $TAG_FULL"
echo " * $TAG_LATEST"
echo " * $TAG_VERSION"

