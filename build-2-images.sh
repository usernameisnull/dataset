#!/usr/bin/env bash
set -euxo pipefail

REGISTRY='10.6.178.191:5000'
CONTROLLER='dataset-controller'
DATA_LOADER='dataset-data-loader'
IMAGE_TAG=$(date +"%Y%m%d-%H%M%S")
REPOSITORY='dataset'

docker build . \
  --build-arg platform=linux/amd64 \
  --build-arg http_proxy=http://172.24.80.1:7890 \
  --build-arg https_proxy=http://172.24.80.1:7890 \
  -f data-loader.Dockerfile.mine \
  -t ${REGISTRY}/${REPOSITORY}/${DATA_LOADER}:${IMAGE_TAG} --push

docker build . --build-arg platform=linux/amd64 -f Dockerfile.mine -t ${REGISTRY}/${REPOSITORY}/${CONTROLLER}:${IMAGE_TAG} --push

cp -rf config/crd/bases/dataset.baizeai.io_datasets.yaml manifests/dataset/templates
kubie ctx a223 && kubie ns dataset-system

helm upgrade --install dataset manifests/dataset/ \
--set global.imageRegistry="${REGISTRY}" \
--set controller.image.repository="${REPOSITORY}/${CONTROLLER}" \
--set controller.image.tag="${IMAGE_TAG}" \
--set dataloader.image.repository="${REPOSITORY}/${DATA_LOADER}" \
--set dataloader.image.tag="${IMAGE_TAG}" \
--set global.imagePullPolicy=Always \
--version 0.1.10