---
title: let与var区别
date: 2024-03-12T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [javascript, let, var]
---

#### 1. 全局污染

`var` 声明的变量（全局作用域）会挂载到 window 对象上

`let` 则不会

二者都可以跨 `<script>` 标签使用

#### 2. 块级作用域

使用 `var` 定义的变量只有两种作用域：全局和函数

而使用 `let` 定义的变量多了一种作用域：块级作用域

#### 3. 暂时死区（TDZ）

在 `var` 声明变量之前使用该变量，会返回 `undefined` 而不是引用错误 ReferenceError

而在 `let`、`const`、`class` 声明变量之前，当前作用域开始到变量声明之间会出现**暂时性死区**

在这个区域内使用该变量，会抛出引用错误

详见 mdn 文档对于 [变量提升](https://developer.mozilla.org/en-US/docs/Glossary/Hoisting) 行为的详细说明

#### 4. 重复声明

`var` 声明的变量可以被重复声明

`let` `const` 和 `class` 不可以