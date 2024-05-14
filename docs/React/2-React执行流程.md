---
sidebar-position: 2
title: React 渲染流程
date: 2024-05-02
authors: gsemir
tags: [react, render, commit]
---

# React 渲染流程

React 整体的渲染流程可以分为两大阶段，分别是 **render 阶段**和 **commit 阶段**。每个阶段对应不同的组件

![image-20240504133831759](.\images\react-21.png)

- `Render` 阶段里面会经由*调度器*和*协调器*处理，调度器接受到更新开始**调度**任务，协调器计算更新造成的影响，**对比标记**更新的部分，此过程是在内存中运行，是**异步可中断**（有更高优先级、当前时间切片没有剩余时间等）的

- `Commit` 阶段会由*渲染器*进行处理，根据标记副作用进行 UI 的更新，此过程是**同步不可中断**的，否则会造成 UI 和数据显示不一致

### 调度器 Scheduler

React 在 v16 版本开始，由之前的 Stack 架构改为了现在的 Fiber 架构，并引入了 `Scheduler` 组件

Scheduler **类似于**浏览器原生 API  `requestIdleCallback`

```js
function callback(IdleDeadline) {
  while(IdleDeadline.timeRemaining() > 0 && taskList.length) {
    const task = taskList.shift()
    task()
  }
  if(taskList.length) {
    window.requestIdleCallback(callback)
  }
}

window.requestIdleCallback(callback)
```

但是由于兼容性问题，React 放弃了使用这个 API，而是自己实现了一套这样的机制

调度器的主要工作就是利用**宿主**环境的**事件循环机制**来高效**调度任务**，并让所有的任务有**优先级**的概念，这样的话紧急的任务可以优先执行。

后期会把 Scheduler 这个包单独进行发布。这就意味着 Scheduler 不仅仅是只能在 React 中使用，后面如果涉及到了任务调度的需求，都可以使用这个 Scheduler

### 协调器 Reconciler

协调是 Render 阶段的第二部分工作，该阶段会采用**深度优先**遍历并且创建每个的 `FiberNode`，并将其**串联**在一起，在遍历时分为了“递”与“归”两个阶段，其中在“递”阶段会执行 `beginWork` 方法，该方法会根据传入的 FiberNode 创建下一级的 FiberNode。而“归”阶段则会执行 `CompleteWork` 方法，做一些副作用的收集

> beginWork 边 diff 边生成新的 WorkInProgress Fiber Tree，completeWork 负责从下向上整理每个 FiberNode 的副作用到父 FiberNode

> 什么是副作用？

根据 Scheduler 调度结果的不同，协调器起点可能是不同的

- `performSyncWorkOnRoot`（同步更新流程）
- `performConcurrentWorkOnRoot`（并发更新流程）

```js
// performSyncWorkOnRoot 会执行该方法
function workLoopSync() {
	while(workInProgress !== null) {
		performUnitOfWork(workInProgress)
	}
}
```

```js
// performConcurrentWorkOnRoot 会执行该方法
function workLoopConcurrent() {
	while(workInProgress !== null && !shouldYield()) {
		performUnitOfWork(workInProgress)
	}
}
```

其中，`workInProgress` 代表的是当前的 FiberNode

`performUnitOfWork` 方法会创建下一个 FiberNode，并且还会将已创建的 FiberNode 连接起来（child、return、sibling），从而形成一个链表结构的 Fiber Tree

如果 workInProgress 为 null，说明已经没有下一个 FiberNode，也就说明整颗 Fiber 树已经构建完毕

上面两个方法唯一的区别就是是否调用了 `shouldYield` 方法，该方法表明了是否可以中断

`performUnitOfWork` 在创建下一个 FiberNode 的时候，整体上的工作流程可以分为两大块

- **递阶段**

递阶段会从 HostRootFiber 开始向下以深度优先的原则进行遍历，遍历到的每一个 FiberNode 执行 beginWork 方法。该方法会根据传入的 FiberNode 创建下一级的 FiberNode，此时可能存在两种情况

- 下一级只有一个元素，beginWork 方法会创建对应的 FiberNode，并与 workInProgress 连接
- 下一级有多个元素，此时 beginWork 方法会依次创建所有的子 FiberNode 并通过 sibling 连接到一起，每个子 FiberNode 也会和 workInProgress 连接

由于采用的是深度优先的原则，因此无法再往下走的时候，会进入到归阶段，回到父元素的位置

- **归阶段**

归阶段会调用 CompleteWork 方法来处理 FiberNode，做一些副作用的收集

当某个 FiberNode 执行完了 completeWork 方法后，如果存在兄弟元素，就会进入到兄弟元素的递阶段；否则继续向上进入父 FiberNode 的归阶段

### 渲染器 Renderer

渲染器的主要工作就是将各种副作用（flags 表示）commit 到宿主环境的 UI 中

整个阶段针对每个 FiberNode 的渲染工作可以分为三个子阶段，分别是 `BeforeMutation` 阶段、`Mutation` 阶段和 `Layout` 阶段

![image-20240504142503523](.\images\react-22.png)