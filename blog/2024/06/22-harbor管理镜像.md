---
title: harbor 管理镜像
date: 2024-06-22T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [docker, harbor, ubuntu, wsl]
---

项目采用 docker compose 来管理前后端镜像，以及承担部署的工作

> 自 2024-06-06 开始，国内的 Docker Hub 镜像加速器相继停止服务，导致服务器从 docker hub 拉取 image 一直失败，因此选择在本地搭建 harbor 服务来管理项目前后端镜像

没有空闲的服务器，手头只有一个 windows，只能在 wsl 中安装 harbor 服务

### 1 安装 wsl ubuntu

- 方式一 命令安装（失败）

```bash
wsl --list --online
wsl --install <name>
```

- 方式二 Microsoft Store [安装](https://www.microsoft.com/store/productId/9PDXGNCFSCZV?ocid=pdpshare)

已经在 Windows 上安装了 Docker Desktop，并且配置了与 WSL 2 的集成，那么就无需在 WSL 中再次安装 Docker 及其相关组件

> 检查 Docker Desktop 与 WSL 2 集成设置
>
> 1. 打开 Docker Desktop 设置。
> 2. 查看 General 选项卡，确保 Use the WSL 2 based engine 选项被勾选。
> 3. 切换到 Resources > WSL Integration 选项卡，确保你想要使用 Docker 的 Linux 发行版（比如 Ubuntu-22.04）已经开启集成。

### 2 安装 harbor

- [下载](https://github.com/goharbor/harbor/releases) harbor 安装包

- 将安装包保存至 wsl

> 方法 1：使用 Windows 文件资源管理器
>
> 1. 在 Windows 文件资源管理器的地址栏中，输入 `\\wsl$` 后按回车键。这会显示所有已安装的 WSL 分发版本
>
> 2. 找到并打开你想要复制文件到的目标 Linux 分发版，比如 `\\wsl$\Ubuntu-22.04`
>
> 3. 现在，你可以直接拖拽文件从 Windows 文件资源管理器到这个目录中，或者使用复制粘贴的方式。这样，文件就被复制到了 WSL 分发版内
>
> 方法 2：使用命令行
>
> 如果你更喜欢使用命令行，可以使用 `cp` 命令从 Windows 的路径复制文件到 WSL 中，或者反过来。首先，你需要了解如何在 WSL 中访问 Windows 的文件系统。
>
> 在 WSL 中，Windows 的驱动器被挂载在 `/mnt/` 下。例如，C 盘位于 `/mnt/c/`，D 盘位于 `/mnt/d/`，以此类推
>
> ```bash
> cp /mnt/c/Users/<你的用户名>/Downloads/harbor-online-installer-v2.5.0.tgz ~/
> ```
>

- 解压

```bash
tar xzvf harbor-offline-installer-v2.11.0.tgz
```

- 修改 harbor 配置文件

```yml
# windows 内网 ip
# hostname: 192.168.31.117
hostname: 公网ip
http:
  port: 70
harbor_admin_password: admin
database:
  password: gsqzs123
data_volume: /home/gsemir/harbor-data
# 注释掉 https 相关配置
```

- 改名

```bash
mv harbor.yml.tmpl harbor.yml
```

- 执行安装脚本

```bash
sudo ./install.sh
```

windows 浏览器访问 192.168.31.117:70 或者 localhost:70 打开 harbor 管理页面，默认用户名 admin，密码 admin，

> 比较麻烦的一点是，当 ip 改变后，需要修改 harbor.yml 中的 ip 地址，然后重新执行安装脚本，重新安装

### 3 push 本地镜像到 harbor

Docker 默认情况下期望 Registry 使用 `HTTPS`。如果你的 Registry 使用的是 HTTP，你需要告诉 Docker 客户端信任这个 HTTP 地址。这可以通过配置 Docker 客户端来实现。

1. 打开 Docker Desktop 设置。
2. 寻找到 Docker 引擎的配置项（通常在 "Docker Engine" 或 "Daemon" 标签下）。
3. 在 JSON 配置中，添加你的 Harbor 域名到 `insecure-registries` 数组

```json
{
  "insecure-registries" : ["192.168.31.117:70"]
}
```

- Windows docker 登录

```bash
docker login 192.168.31.117:70
```

- 修改部署脚本，支持多目标推送
- 同时需要修改 buildx 的配置，使其信任 http 的镜像源地址

```sh
#!/bin/bash
# push.sh

VERSION=$1
if [ -z "$VERSION" ]; then
    echo "Error: No version specified."
    exit 1
fi

TARGET=$2
if [ "$TARGET" = "dh" ]; then
  TAG=gsemir/account-app-frontend:$VERSION
elif [ "$TARGET" = "h" ]; then
  TAG=192.168.31.117:70/account-app/account-app-frontend:$VERSION
else
  echo "未知目标。请指定 'dockerhub' 或 'harbor'。"
  exit 1
fi

docker buildx rm mybuilder
docker buildx create --name mybuilder --config ./buildkitd.toml --use
docker buildx build --platform linux/amd64,linux/arm64 -t $TAG . --push
```

buildkitd.toml

```toml
[registry."192.168.31.117:70"]
  http = true
  insecure = true
```

- 执行推送脚本

```sh
sh ./push.sh 0.2.3 h
```

### 4 服务端拉取镜像

服务器也需要配置 insecure-registries 为 windows 公网 ip，即 harbor.yml 中配置的 `hostname` 地址

```sh
sudo vi /etc/docker/daemon.json
# 添加后重启
sudo systemctl restart docker 
```

然后修改 docker-compose 文件的 image 配置

```diff
services:
  frontend:
-   image: gsemir/account-app-frontend:0.2.2
+   image: ip:70/account-app/account-app-frontend:0.2.3
```

执行 docker compose up -d，完成镜像拉取