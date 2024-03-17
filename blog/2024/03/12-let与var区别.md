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

栈就相当于数组把第一位（左边）堵住，然后只有 pop 和 push 方法

1. 全局污染

`var` 声明的变量（全局作用域）会挂载到 window 对象上

`let` 则不会，但能够跨 `<script>` 标签使用