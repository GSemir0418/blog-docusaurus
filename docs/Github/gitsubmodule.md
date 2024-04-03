---
sidebar-position: 3
title: Git Submodule
date: 2024-03-22T17:59:59
authors: gsemir
tags: [github, submodule, pnpm]
---

>  使用 submodule + monorepo 管理工程项目

### 背景

随着部门工程项目越来越多，项目迭代开发频率的提升以及前端框架的升级，出现了工程项目代码散布在多个仓库和分支的问题，对前端代码管理与打包部署工作造成了很大影响。以某工程项目为例，其源码不仅包含新增页面的部分，还需要依赖于其他四个工程项目仓库的部分代码；同时其他项目仓库为了满足定制化需求开发，还需要单独开辟这个工程项目的分支。这意味着开发人员除了日常项目开发工作，还需要在**打包以及拼接打包产物**的工作上花费一定精力，从而影响项目整体开发交付效率。

为了解决这个问题，在不影响原来项目开发工作流的基础上，使用 pnpm 提供的 `workspace` 功能，以**工程项目**为单位，整合子项目，并统一管理项目依赖；使用 github 的 `submodule` 功能连接子项目远程仓库，管理项目前端源码。

### 构建

以某项目为例，业务源码位于a 仓库的 branch1 分支，组件源码位于 b 仓库的 branch2 分支，具体构建流程如下：

1. 创建 monorepo 目录，并初始化 git

```bash
mkdir Monorepo && cd Monorepo
git init
```

2. 添加子项目源码作为大仓库的子模块

```bash
mkdir packages
cd packages
git submodule add -b 分支名 https://github.com/user/project1.git
git submodule add -b 分支名 https://github.com/user/project2.git
```

3. 在 Monorepo 的根目录下，创建一个 `pnpm-workspace.yaml` 文件，内容如下：

```yaml
packages:
  - '**'
```

这个配置告诉 pnpm 在 packages 目录下找到所有的包。

4. 在 Monorepo 的根目录下，创建一个 package.json 文件，定义项目启动与打包等脚本

```json
{
  "name": "monorepo",
  "private": true,
  "scripts": {
    // 递归执行每个子项目的 dev 命令
    "start": "pnpm run -r dev",
    "build": "pnpm run -r build && node merge-dist.js",
    // 启动指定的子项目
    "start:main": "pnpm --prefix packages/a branch1"
  }
}
```

5. 在子项目的根目录下执行 `pnpm install` 即可统一安装子项目的全部依赖
6. 执行 `pnpm run build` 后，使用 node 完成子项目打包产物的拼接工作

```js
// merge-dist.js
import * as fs from 'fs'
import path from 'path'

const sourceDirs = ['projectA', 'projectB'];
const targetDir = 'result'

if (fs.existsSync(targetDir)) {
  fs.rmdirSync(targetDir, { recursive: true })
}

fs.mkdirSync(targetDir)

sourceDirs.forEach((dir) => {
  const source = path.join('packages', dir, 'dist')
  const destination = path.join(targetDir)

  fs.cp(source, destination, { recursive: true }, (err) => {
    console.log('[COPY_ERROR]', err)
  })
})

export {}
```

### 维护

1. 拉取主仓库代码，安装依赖

```bash
git clone http://xxx/monorepo.git
git submodule update --init --recursive
pnpm install
```

2. 更新子项目代码到主仓库

```bash
git submodule update --remote --merge
```

3. 打包项目代码

```bash
pnpm run build
```

4. 记得 push 主仓库的 commit

### 总结

此方案的核心在于利用 git submodule 以工程项目为单位重新组织前端源代码，pnpm 禁用于管理共享依赖以及管理构建命令

考虑到目前处于开发阶段的工程项目较多，以项目为单位的大仓库的构建工作量较大，同时为了不影响各位同事的开发节奏，日常开发仍然在子项目中进行即可。

大仓库的维护暂时仅由项目负责人负责，大仓库暂时只用于项目打包部署与交付。

> 由于老项目（umi3.x）使用 yarn 作为包管理器，以上基于 pnpm 的方案就不适用了。后续如果老项目的维护需求多的话，这里提供三种解决方案：
>
> 1. 使用 Lerna 来管理子项目。Lerna 是一个流行的 Monorepo 管理工具，它支持多种不同的包管理器。
> 2. 把所有的子项目都转换为使用 pnpm。工作量较大，但可以解决包管理器不一致的问题。
> 3. 如果不需要共享依赖，那么可以尝试让每个子项目都使用独立的 node_modules 文件夹，这样就能让每个子项目都使用自己的包管理器。

