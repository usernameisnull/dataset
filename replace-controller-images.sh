#!/usr/bin/env bash
set -euxo pipefail

REGISTRY='10.6.178.191:5000'
CONTROLLER='dataset-controller'
IMAGE_TAG=$(date +"%Y%m%d-%H%M%S")
REPOSITORY='dataset'
DEPLOY_NAME='dataset'
CONTAINER_NAME='dataset'
IMAGE=${REGISTRY}/${REPOSITORY}/${CONTROLLER}:${IMAGE_TAG}
echo ${IMAGE}
#kubie ctx a223
# 避免直接退出脚本
#kubectl config set-context --current --namespace=dataset-system

old_image=$(kubectl get deploy ${DEPLOY_NAME} -oyaml |yq -e ".spec.template.spec.containers[] | select(.name == \"${CONTAINER_NAME}\") | .image")
if [[ -z "${old_image}" ]]; then
  echo "get image from deployment failed"
	exit 1
fi

docker build . --build-arg platform=linux/amd64 -f Dockerfile.mine -t ${IMAGE} --push
kubectl set image deployment/${DEPLOY_NAME} ${CONTAINER_NAME}=${IMAGE}
echo "${old_image}" >> /tmp/${DEPLOY_NAME}-image.txt
