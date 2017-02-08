#!/bin/bash

docker login -u="$QUAY_USERNAME" -p="$QUAY_PASSWORD" quay.io
docker tag keboola/r-tree quay.io/keboola/r-tree:$TRAVIS_TAG
docker tag keboola/r-tree quay.io/keboola/r-tree:latest
docker images
docker push quay.io/keboola/r-tree:$TRAVIS_TAG
docker push quay.io/keboola/r-tree:latest
