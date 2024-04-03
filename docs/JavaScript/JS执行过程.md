---
title: 'JS执行过程'
date: '2024-03-21T15:42:00+08:00'
tags: ["JavaScript", "v8", "ec", "scope"]
sidebar-position: 5
authors: gsemir
---

![image-20240327131557992](./images/v81.png)

# 3 this

- this永远指向**最后调用**它的那个对象
- 箭头函数没有this，即始终指向**函数定义**时的this
- this就是call一个函数时，传入的第一个参数
