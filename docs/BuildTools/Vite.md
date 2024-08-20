---
title: 'Vite'
date: '2024-04-18T15:42:00+08:00'
tags: ["vite", "rollup", "rolldown", "esbuild", "esm"]
sidebar-position: 1
authors: gsemir
---

> https://www.vitejs.net/guide/why.html

## 对前端工程化的理解

借助一些工程化手段或工具，涵盖从项目启动到代码部署的全过程，从而提升开发效率、代码质量、可维护性，优化项目构建，使开发流程标准化、自动化

**提高开发效率：**通过制定统一的**代码规范**、使用**版本控制系统**、进行代码审查等方式，可以规范团队成员的开发流程，**减少沟通成本**，提高团队协作效率。

**提升代码质量：**通过使用**代码规范工具**、**代码质量检查工具**、单元测试等手段，可以有效地约束代码风格，提高代码的可读性和可维护性，并减少潜在的错误。

**增强可维护性：**通过**模块化**开发、**组件化**开发、**代码版本管理**等方式，可以将代码拆分成更小、更易于管理的单元，从而降低代码的耦合度，提高代码的可维护性。

**优化项目构建：**通过使用**模块打包工具**、**代码压缩工具**、**图片优化工具**等，可以优化项目构建流程，减少代码体积，提高页面加载速度，提升用户体验。

**开发流程自动化：**通过配置 CICD 或者自动化部署脚本，实现一键部署，减轻运维压力，提升整体项目实施效率

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

### 手动分包

vite 默认情况下都会将全部源码和全部依赖重新打包成一个 js 文件。这对于依赖库很多或者很重的项目来说，每次版本更新，客户端都需要重新下载这个 js 文件（文件指纹变了），一定程度上影响了用户体验。

解决方案就是手动分包，将依赖和源码分开打包成若干个 js 文件

vite 在打包时使用的是 rollup，支持 rollup 的 `manualChunks` 分包配置：

```ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'react': ['react'],
          'react-router-dom': ['react-router-dom'],
          // 也可以写成一个
          'vendor': ['react', 'react-router-dom'],
        }
      }
    }
  }
})
```

同时 `manualChunks` 支持传入函数，入参为依赖的文件 id，返回值可以为字符串

```ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  build: {
    rollupOptions: {
      output: {
        manualChunks: (id) => {
          if(id.includes('node_modules')) {
            return 'vendor'
          }
        }
      }
    }
  }
})
```

