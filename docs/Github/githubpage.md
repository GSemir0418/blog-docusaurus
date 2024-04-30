---
sidebar-position: 4
title: Github Page
date: 2023-07-13T17:59:59
authors: gsemir
tags: [Github Page, sh, Github Action]
---

共两种方案，一种是需要额外创建 Github Page 仓库，将源码打包后的产物 push 到仓库中，开启仓库的 Github Page 支持即可；第二种是基于源码仓库，利用Github Action 实现自动化部署并生成 Github Page

### 1 初始化Preview仓库

- 建仓库，建议名称为 `<源码仓库名>-preview`

- 本地运行打包命令，生成 build（或 dist）目录

- 进入 build（或 dist）目录，初始化 git 仓库，将代码正常提交到上面创建的远程仓库中

- git init => git add . => git commit -m "" => git remote add origin xxx => git push -u origin master

- 在git仓库页面，选择 Settings => Pages，配置部署选项，选择一个部署的分支（master）

![image-20230712150153293](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20230712150153293.png)

- 如果 save 按钮不能点击，就换一个选项，点击save，再换回来就可以了

### 2 自动化部署 GithubPage 脚本

实现一条命令，就能完成自动化打包并将产物部署到 Github Page 

- 项目根目录下创建 `bin/deploy_to_github_page.sh`

```sh
# shebang 指定使用 Bash 解释器来执行脚本，并使得脚本能够更方便地直接运行
#!/usr/bin/env bash
rm -rf build
npm run build
cd build
git init
git add .
git commit -m deploy
git remote add origin git@github.com:GSemir0418/blog-docusaurus-preview.git
git push -f origin master
# 返回上一个工作目录
cd -
```

- 执行 `bin/deploy_to_github_page.sh`，待代码自动 push 完成后，访问[Markdown page example | GSemir (gsemir0418.github.io)](https://gsemir0418.github.io/blog-docusaurus-preview/)

### 3 Github Action

实现在**源码仓库**执行 `git push`，自动化打包，并将产物作为 Github Page 部署到源码仓库

>  无需新建 preview 仓库

- 进入 Settings => Pages 选项，选择 Github Action 方式，点击 Static HTML 来创建 Github Action 流程配置文件，修改官方提供的默认配置文件：

```yml
# Simple workflow for deploying static content to GitHub Pages
name: Deploy static content to Pages

on:
  # Runs on pushes targeting the default branch
  push:
    branches: ["master"]

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

# Sets permissions of the GITHUB_TOKEN to allow deployment to GitHub Pages
permissions:
  contents: read
  pages: write
  id-token: write

# Allow only one concurrent deployment, skipping runs queued between the run in-progress and latest queued.
# However, do NOT cancel in-progress runs as we want to allow these production deployments to complete.
concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  # Single deploy job since we're just deploying
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      - name: Set up Node
        uses: actions/setup-node@v3
        with:
          node-version: 18
          cache: 'npm'
      - name: Install dependencies
        run: npm install
      - name: Build
        run: npm run build
      - name: Setup Pages
        uses: actions/configure-pages@v3
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v2
        with:
          # Upload dist repository
          path: './build'
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v2
```

- 点击提交，Github 将会自动执行一次自动化部署流程，待流程执行完毕，可以访问新的 Github Page：[Markdown page example | GSemir (gsemir0418.github.io)](https://gsemir0418.github.io/blog-docusaurus/)

