---
sidebar-position: 12
title: lane 模型
date: 2024-05-12
authors: gsemir
tags: [react, schedule, lane]
---

# lane 模型

在 Scheduler 内部，定义了一套通用的优先级机制

```js
export const NoPriority = 0
export const ImmediatePriority = 1
export const UserBlockingPriority = 2
export const NormalPriority = 3
export const LowPriority = 4
export const IdlePriority = 5
```

每个优先级对应一个 timeout，以区分任务在任务队列中的的优先级顺序

但是当任务类型逐渐增多，这套通用的优先级机制**很难准确表达「任务分批」**的概念，因为任务不一定会严格按照优先级去分类

因此 React 推出了**基于位运算**的 `lane` 模型算法，每个 lane 就是一个 32 位整数，越低的位代表了越高的优先级。不仅能够高效表达优先级的概念，还可以准确灵活地表达『任务批次』的概念

Scheduler 负责决定何时开始工作，而 Lane 模型则管理着哪些工作需要先完成、哪些可以稍后进行。两者之间的相互配合，使得 React 能更好地处理并发的渲染任务，从而达到优化性能和用户体验的目标。

