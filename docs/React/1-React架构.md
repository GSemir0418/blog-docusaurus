---
sidebar-position: 1
title: React 整体架构
date: 2024-05-01
authors: gsemir
tags: [react]
---

# React 整体架构

React v16 之前的架构：

- Reconciler（协调器）：VDOM 的实现，负责根据自变量变化计算出 UI 变化
- Renderer（渲染器）：负责将 UI 变化渲染到宿主环境中

这种架构称之为 `Stack` 架构，在 Reconciler 中， mount 的组件会调用 mountComponent，Update 的组件会调用 updateComponent，这两个方法都会**递归更新子组件**，更新流程一旦开始，**中途无法中断**。因为采用的是递归，会不停的开启新的函数栈

但是随着应用规模的逐渐增大，之前的架构模式无法再满足快速响应这一需求，主要受限于如下两个方面：

- **CPU 瓶颈**：由于 VDOM 在进行差异比较时，采用的是递归的方式，每次更新都会去计算整颗 VDOM 树，JS 计算会消耗大量的时间，每一帧的 JS 代码执行时间过长，从而导致动画、还有一些需要实时更新的内容会产生视觉上的卡顿
- **I/O 瓶颈**：由于各种基于状态变化而产生的更新任务没有优先级的概念，因此在某些更新任务（例如文本框的输入）有轻微的延迟，对于用户来讲也是非常敏感的，会让用户产生卡顿的感觉

从 React v16 开始，React 重构了整体的架构，新的架构称之为 **Fiber 架构**：

- `Scheduler`（调度器）：调度任务的优先级，高优先级任务会优先进入到 Reconciler
- `Reconciler`（协调器）：VDOM 的实现，负责根据自变量变化计算出 UI 变化
- `Renderer`（渲染器）：负责将 UI 变化渲染到宿主环境中

引入了 `Fiber` 的概念，通过一个对象来描述一个 DOM 节点，但是和之前方案不同的地方在于，每个 Fiber 对象之间通过**链表**的方式进行串联。通过 `child` 指向子元素，通过 `sibling` 指向兄弟元素，通过 `return` 指向父元素

在新架构中，Reconciler 中的更新流程从递归变为了”**可中断的循环过程**“，每次循环都会调用 `shouldYield` 判断当前的 TimeSlice 是否有剩余时间，没有剩余时间则暂停更新流程，将主线程还给浏览器的渲染主线程，等待下一个宏任务再继续执行。这样就解决了 CPU 的瓶颈问题 

另外在新的架构中还引入了 Scheduler 调度器，用来调度任务的优先级，从而解决了 I/O 的瓶颈问题