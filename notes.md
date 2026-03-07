## helm包在docs目录下
https://github.com/BaizeAI/charts/tree/main/docs

## api/dataset/v1alpha1/dataset_types.go怎么生成yaml文件的?
make manifests

## 怎么样跑单元测试(ut)
go test ./... -coverprofile=coverage.out -covermode=atomic -p=1

## 怎么样跑golangci-lint
golangci-lint run --timeout=10m
```cgo
golangci-lint run --timeout=10m Error: can't load config: the Go language version (go1.24) used to build golangci-lint is lower than the targeted Go version (1.25.1) The command is terminated due to an error: can't load config: the Go language version (go1.24) used to build golangci-lint is lower than the targeted Go version (1.25.1)
```
需要升级golangci-lint
```cgo
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

## 怎么打的镜像
- 预热用到的镜像的Dockerfile: data-loader.Dockerfile
- dataset安装后唯一的pod的镜像的Dockerfile: [Dockerfile](Dockerfile)
- controller的镜像, 代码: https://github.com/usernameisnull/dataset/blob/e97f29b1c023a3fb7c6f436dac74990a8d079093/.github/workflows/build.yml#L32
- data-loader的镜像, 代码: https://github.com/usernameisnull/dataset/blob/e97f29b1c023a3fb7c6f436dac74990a8d079093/.github/workflows/build.yml#L61
- 手动打2个镜像,推送镜像,在集群里更新:  [build-2-images.sh](build-2-images.sh)
- https://github.com/usernameisnull/dataset 可以手动打镜像和helm chart
```cgo
helm repo add myrepo https://usernameisnull.github.io/dataset
helm repo update myrepo
➜ helm search repo myrepo/dataset -l --devel
NAME            CHART VERSION   APP VERSION     DESCRIPTION
myrepo/dataset  0.1.9           1.16.0          A Helm chart for Kubernetes
myrepo/dataset  0.1.8           1.16.0          A Helm chart for Kubernetes

skopeo copy \
--override-os linux \
--override-arch amd64 \
docker://ghcr.io/usernameisnull/dataset-controller:v0.1.9 \
docker://release-ci.daocloud.io/demo/dataset-controller:v0.1.9

skopeo copy \
--override-os linux \
--override-arch amd64 \
docker://ghcr.io/usernameisnull/dataset-data-loader:v0.1.9 \
docker://release-ci.daocloud.io/demo/dataset-data-loader:v0.1.9

helm install dataset myrepo/dataset --version 0.1.9 \
--set global.imageRegistry='release-ci.daocloud.io' \
--set controller.image.repository="demo/dataset-controller" \
--set dataloader.image.repository="demo/dataset-data-loader" \
--set dataloader.image.tag="v0.1.9" \
--set controller.image.tag="v0.1.9" 

```
### data-loader的镜像
用`python:3.13`作为基础镜像, 里面已经有git了
```cgo
➜ docker run -it --rm --entrypoint sh m.daocloud.io/docker.io/python:3.13 -c 'git --version'
git version 2.47.3
```
用`python:3.13`打出来的镜像能够适配git和s3作为数据源, baize总的source: 
- GIT
- S3
- HTTP, 预热模式能支持? baize用的rcloneOP, 这里用syncMode
- PVC
- NFS
- Huggingface
- Modelscope
- DATABASE
- HADOOP
- 引用已有数据空间

## helm chart
需要手动把config/crd/bases/dataset.baizeai.io_datasets.yaml拷贝到manifests/dataset/templates   
https://github.com/usernameisnull/dataset/blob/e97f29b1c023a3fb7c6f436dac74990a8d079093/.github/workflows/build.yml#L89

## 验证
- copy `dataset.baizeai.io_datasets.yaml`
- 打镜像
- 安装命令
```cgo
helm install dataset manifests/dataset/ \
--set global.imageRegistry='release-ci.daocloud.io' \
--set controller.image.repository="demo/dataset-controller" \
--set controller.image.tag="mabing-0203" \
--set dataloader.image.repository="demo/dataset-data-loader" \
--set dataloader.image.tag="mabing-0203" \
```