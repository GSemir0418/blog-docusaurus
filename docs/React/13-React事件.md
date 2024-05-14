---
sidebar-position: 13
title: React 中的事件
date: 2024-05-13
authors: gsemir
tags: [react, event]
---

# React 中的事件

## 简介

在 React 中，有一套**自己的事件系统**。如果说 Fiber 用于描述 UI，那么 React 事件系统就是用于描述 Fiber 与 UI 之间的交互

对于 React DOM 环境，这套事件系统包括两个部分：

1. 合成事件对象

`SyntheticEvent` 是对浏览器原生事件对象的一层封装，兼容了主流的浏览器，同时拥有和浏览器原生事件相同的 API，例如 stopPropagation 和 preventDefault，SyntheticEvent 存在的目的就是**抹平不同浏览器在事件对象上的差异**

2. 模拟事件传播机制

利用**事件委托**的原理，React 会基于 `FiberTree` 来实现事件的捕获、目标以及冒泡的过程。同时加入了一些新特性

- 不同事件对应不同**优先级**
- 定制事件名（`onXXX`）
- 定制事件行为（`onChange` 和 `oninput` 行为是相同的）

## 实现细节

### SyntheticEvent Class

构造函数中保存传入的原生事件对象，提供 stopPropagation 方法

### 事件传播机制

- 根元素**绑定**「事件类型对应的事件回调」，所有子孙元素触发该类事件时**最终会委托给根元素**的事件回调函数进行处理

- **寻找**触发事件的 DOM 元素，找到对应的 `FiberNode`

- **收集**从当前的 `FiberNode` 向上直到 `HostRootFiber` 之间所有注册了该事件的回调函数

- 模拟事件传播机制

  - **反向**遍历（从根元素开始到目标元素）并执行一遍所有的回调函数（模拟**捕获**阶段的实现）

  - **正向**遍历（从目标元素开始到根元素）并执行一遍所有的回调函数（模拟**冒泡**阶段的实现）

  - 如果调用了 `stopPropagation`，那么就 `break` 上述遍历过程