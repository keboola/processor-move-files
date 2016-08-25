#!/bin/bash

docker login -e="." -u="$QUAY_USERNAME" -p="$QUAY_PASSWORD" quay.io
docker tag keboola/processor-move-files quay.io/keboola/processor-move-files:$TRAVIS_TAG
docker tag keboola/processor-move-files quay.io/keboola/processor-move-files:latest
docker images
docker push quay.io/keboola/processor-move-files:$TRAVIS_TAG
docker push quay.io/keboola/processor-move-files:latest
