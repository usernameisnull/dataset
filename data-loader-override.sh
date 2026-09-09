#!/usr/bin/env bash
set -euxo pipefail

REGISTRY='10.6.178.191:5000'
REPOSITORY='dataset'
BINARY_NAME='dataset-loader'
IMAGE_TAG=$(date +"%Y%m%d-%H%M%S")
IMG=${REGISTRY}/${REPOSITORY}/${BINARY_NAME}:${IMAGE_TAG}
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags "-s -w" -a -o data-loader ./cmd/data-loader
docker build . -f Dockerfile-dataloader-overide -t ${IMG} --push

