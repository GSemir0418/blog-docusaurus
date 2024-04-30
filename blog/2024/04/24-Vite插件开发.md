---
title: Vite插件开发
date: 2024-04-24T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [vite, plugin, rollup]
---
### Vite 插件开发

插件可以运行在构建期间的一些特殊节点，从而扩展构建工具的能力

插件本质上就是一个工厂函数，返回一个对象

Rollup 官方将钩子分为两类：**构建钩子**和**输出生成钩子**。

- 构建钩子在构建阶段运行。它们主要涉及在 Rollup 处理输入文件之前定位、提供和转换输入文件。
- 输出生成钩子可以提供有关生成的产物的信息并在构建完成后修改构建。

文档对于这些 hook 的声明与运行时机有[详细说明](https://cn.rollupjs.org/plugin-development/#a-simple-example)，这里不再赘述

下面我们实现一个根据路由生成 html 文件结构的简单插件

```js
// plugins/generateHTMLFromRoutes.ts
import fs from 'node:fs'
import path from 'node:path'

// 暂时手动维护一份路由表
const routes = [
  {
    path: 'basic-data',
    children: [
      { path: 'material' },
      { path: 'resource' },
      { path: 'switch-rule' },
    ],
  },
  { path: 'overview-today' },
  { path: 'overview-month' },
]
interface Options {
  outDir?: string
}
/*
* options: 目前仅支持 outDir 配置
* */
export default function generateHtmlWithRoutes(options: Options = {}) {
  const outputDir = options.outDir || 'dist'
  return {
    name: 'generateHtmlWithRoutes',
    apply: 'build' as const,
    writeBundle() {
      const sourceFile = path.join(outputDir, 'index.html')
      const makeDir = (url: string) => fs.mkdirSync(url, { recursive: true })
      const cpHtml = (target: string) => fs.copyFile(
        sourceFile,
        target,
        (err) => {
          if (err)
            throw err
        })
      // 按路由表生成文件夹并复制 html
      for (const m of routes) {
        if (m.children) {
          for (const m2 of m.children) {
            makeDir(path.join(outputDir, m.path, m2.path))
            cpHtml(path.join(outputDir, m.path, m2.path, 'index.html'))
          }
        }
        else {
          makeDir(path.join(outputDir, m.path))
          cpHtml(path.join(outputDir, m.path, 'index.html'))
        }
      }
    },
  }
}
```

使用

```ts
// vite.config.ts
export default defineConfig({
  plugins: [generateHtmlWithRoutes()],
	// ...
})
```
