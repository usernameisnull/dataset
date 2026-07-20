## 在环境上修改镜像
打镜像: 合并代码到notes分支, 然后在github上执行Action  
在环境上更改dataset-system里的cm dataset:
```yaml
image: 10.6.178.191:5000/dataset-data-loader:v1.0.101
```
然后重启pod

## 重复拉取某个仓库代码出现的问题
新建了一个分支名字叫v0.6从main分支而来, 并push到了gitlab的v0.6
```bash
root in 󱃾 gpu-cluster(dataset-system) /tmp/Megatron-LM on  v0.6 via 🐍
➜ git remote -v
gitlab  git@gitlab.daocloud.cn:bing.ma/Megatron-LM.git (fetch)
gitlab  git@gitlab.daocloud.cn:bing.ma/Megatron-LM.git (push)
origin  https://github.com/NVIDIA/Megatron-LM.git (fetch)
origin  https://github.com/NVIDIA/Megatron-LM.git (push)

root in 󱃾 gpu-cluster(dataset-system) /tmp/Megatron-LM on  core_r0.5.0 via 🐍 v3.10.4
➜ git checkout main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.

root in 󱃾 gpu-cluster(dataset-system) /tmp/Megatron-LM on  main via 🐍
➜ git checkout -b v0.6
Switched to a new branch 'v0.6'

root in 󱃾 gpu-cluster(dataset-system) /tmp/Megatron-LM on  v0.6 via 🐍
➜ git push gitlab v0.6:v0.6 -f
Total 0 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
remote:
remote: To create a merge request for v0.6, visit:
remote:   https://gitlab.daocloud.cn/bing.ma/Megatron-LM/-/merge_requests/new?merge_request%5Bsource_branch%5D=v0.6
remote:
To gitlab.daocloud.cn:bing.ma/Megatron-LM.git
 * [new branch]          v0.6 -> v0.6
```
然后根据下面的yaml执行成功, 重新同步也是成功的
```yaml
apiVersion: dataset.baizeai.io/v1alpha1
kind: Dataset
metadata:
  annotations:
    baize.io/description: ""
    shadow.clusterpedia.io/cluster-name: gpu-cluster
  labels:
    app.kubernetes.io/part-of: baize
  name: mabing-gitlab-717-test-fail2
  namespace: katib-demo
spec:
  dataSyncRound: 4
  mountOptions:
    gid: 1000
    mode: "0774"
    path: /
    uid: 1000
  resources: {}
  source:
    options:
      branch: v0.6
#      branch: core_r0.5.0
      commit: HEAD
    type: GIT
#    uri: https://github.com/NVIDIA/Megatron-LM.git
    uri: https://gitlab.daocloud.cn/bing.ma/Megatron-LM.git
  volumeClaimTemplate:
    metadata: {}
    spec:
      accessModes:
        - ReadWriteMany
      resources:
        requests:
          storage: "0"
      storageClassName: nfs-csi
    status: {}
```
然后修改了v0.6分支的代码~~或者直接在网页上修改v0.6分支的代码~~
```bash
git checkout core_r0.5.0
git push gitlab core_r0.5.0:v0.6 -f
```
再次同步,会失败, 要2次差距够大才会失败
```txt
fatal: Need to specify how to reconcile divergent branches.
```

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