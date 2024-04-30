---
title: 'Vite'
date: '2024-04-18T15:42:00+08:00'
tags: ["vite", "rollup", "rolldown", "esbuild", "esm"]
sidebar-position: 1
authors: gsemir
---

> https://www.vitejs.net/guide/why.html

### Vite 是什么

是尤雨溪及 Vue 团队开发的一个现代化的前端构建工具

### Vite 解决了什么问题

传统的基于打包器（bundle-based）的方案，无论是在*首次启动*还是*热更新*，其构建效率都会随着应用规模的增长而显著下降，影响开发效率与开发体验。

其更深层的原因还有：传统基于打包器的方案必须先 build 再启动服务器；基于 JS 开发的工具的构建效率很低。

### Vite 如何解决以上问题的

- 冷启动：

  - Vite 一开始会将应用中的模块分为「依赖」和「源码」

  - Vite 使用 ESBuild 预构建依赖以及 TS/JSX 转换，比 JS 编写的打包器要快 10 - 100 倍

  -  Vite 利用浏览器对 ESM 的原生支持，只需要在浏览器请求源码时进行转换并按需提供源码即可

- 热更新：

  - Vite 中的 HMR 也是基于原生 ESM 执行的，当一个文件更新后，Vite 只需要准确替换这个文件的链接即可，这样一来，热更新效率就不再受应用规模的影响了。

  - 同时利用 `HTTP` 缓存机制来加速页面重新加载：源码使用 304 协商缓存；依赖使用 `Cache-Control` 进行强缓存

### 为什么生产环境仍需打包

尽管原生 ESM 现在得到了广泛支持，但由于嵌套导入会导致额外的网络往返，在生产环境中发布未打包的 ESM 仍然效率低下（即使使用 HTTP/2）。为了在生产环境中获得最佳的加载性能，最好还是将代码进行 tree-shaking、懒加载和 chunk 分割（以获得更好的缓存）。

### 为什么不用 ESBuild 打包

> esbuild 快但不成熟，rollup 成熟但不快

ESBuild 虽然构建速度快，但灵活性与可扩展性以及技术生态还不及 Rollup，而且 Vite 强大的插件 API 也正是基于 Rollup 来展开的，所以两套方案并存也算是 Vite 的一个权衡之策

目前 Vite 团队正在基于 Rust 重构 Rollup，命名为 Rolldown，一旦 Rolldown 问世，Vite 就会替换 Rollup 和 ESBuld，显著提高构建性能，并消除开发和构建之间的不一致性

