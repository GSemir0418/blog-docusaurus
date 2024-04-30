---
sidebar-position: 5
title: 初识 CICD
date: 2023-04-02T17:59:59
authors: gsemir
tags: [Github, CI, Github Action, CD]
---

> 参考文章：[作为前端，要学会用Github Action给自己的项目加上CICD - 掘金 (juejin.cn)](https://juejin.cn/post/7113562222852309023#heading-2)

## CI

### 1 概念

**CI**的全称是**Continuous Integration**，直译为**可持续集成**，而普遍对其的解释是**频繁地（一天多次）将代码集成到主干**。对于这个解释我们要搞懂其中的两个概念：

1. **主干**：是指包含多个已上和即将上线的特性的分支。
2. **集成**：是指把含新特性的分支合并(`merge`)到**主干**上的行为

#### 1.1 目的

持续集成的目的，就是让产品可以快速迭代，同时还能保持高质量。它的核心措施是，代码集成到主干之前，必须通过自动化测试。只要有一个测试用例失败，就不能集成。

#### 1.2 github flow

`github flow`在开发新特性的运行模式如下所示：

1. 基于`master`创建新的分支`feature`进行开发。注意这需要保证`master`的代码和特性永远是最稳定的。
2. 开发期间，定期提交更改(`commit and push change`)到远程仓库的`feature`分支
3. 在编码以及自测完成后，通过创建`pull request`去对`master`发起合并`feature`的请求
4. `pull request`在经过审核确认可行后合并到`master`分支
5. 删除已合并的特性分支`feature`

#### 1.3 采用github flow的原因 

而`github flow`模型**保证高质量的核心措施**是：在**集成**前通过`pull request`，从而触发审核（审核可以是一系列的自动化校验测试以及代码审核**Code Review**），在审核通过后再合并到**主干**，从而保证**主干**的稳定性。

### 2 实现思路

#### 2.1 Github Action

当我们想往自己的项目里接入**Github Actions**时，要在根项目目录里新建`.github/workflows`目录。然后通过编写`yml`格式文件定义**Workflow(工作流程)\**去实现`CI`。在阅读`yml`文件之前，我们要先搞懂在\**Workflow**中一些比较重要的概念：

- **Event(触发事件)**：指触发 **Workflow(工作流程)** 运行的事件。
- **Job(作业)**：一个**工作流程**中包含一个或多个**Job**，这些**Job**默认情况下并行运行，但我们也可以通过设置让其按顺序执行。每个**Job**都在指定的环境(虚拟机或容器)里开启一个**Runner**(可以理解为一个进程)运行，包含多个**Step(步骤)**。
- **Step(步骤)**：**Job**的组成部分，用于定义每一部的工作内容。每个**Step**在运行器环境中以其单独的进程运行，且可以访问工作区和文件系统。

```yml
# 指定工作流程的名称
name: learn-github-actions
# 指定此工作流程的触发事件Event。 此示例使用 推送 事件，即执行push后，触发该流水线的执行
on: [push]
# 存放 learn-github-actions 工作流程中的所有Job
jobs:
  # 指定一个Job的名称为check-bats-version
  check-bats-version:
    # 指定该Job在最新版本的 Ubuntu Linux 的 Runner(运行器)上运行
    runs-on: ubuntu-latest
    # 存放 check-bats-version 作业中的所有Step
    steps:
      # step-no.1: 运行actions/checkout@v3操作，操作一般用uses来调用，
      # 一般用于处理一些复杂又频繁的操作例如拉取分支，安装插件
      # 此处 actions/checkout 操作是从仓库拉取代码到Runner里的操作
      - uses: actions/checkout@v3
      # step-no.2: actions/setup-node@v3 操作来安装指定版本的 Node.js，此处指定安装的版本为v14
      - uses: actions/setup-node@v3
        with:
          node-version: "14"
      # step-no.3: 运行命令行下载bats依赖到全局环境中
      - run: npm install -g bats
      # step-no.4: 运行命令行查看bats依赖的版本
      - run: bats -v
```

`Github Action`在**开源项目**是免费使用的，而在**私有项目**方面的计费会根据你购买的服务而不同，详细可看[关于 GitHub Actions 的计费](https://link.juejin.cn?target=https%3A%2F%2Fdocs.github.com%2Fcn%2Fbilling%2Fmanaging-billing-for-github-actions%2Fabout-billing-for-github-actions)。

而对于其他**CICD 工具**及其没被选为本文实现方式的原因如下所示：

- **`Gitlab CI`**：与`Gitlab`高度绑定，项目放在`Gitlab`就谈不上开源了
- **`Travic CI`**：限时免费，过后按进程收费
- **`Drone CI`**：执行任务时，国内机器从`Github`拉取仓库代码时会偶尔超时，从而导致任务失败
- **`Jenkins CI`**：除了存在与`Drone CI`一样的缺点外，自身比较重量，占用宿主机较多资源

// TODO CD