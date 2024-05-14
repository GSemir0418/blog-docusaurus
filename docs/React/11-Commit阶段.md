---
sidebar-position: 11
title: Commit 工作流程
date: 2024-05-11
authors: gsemir
tags: [react, commit, mutation, useEffect]
---

# Commit 工作流程

`Commit` 阶段是将 `Reconcile` 阶段计算出的 DOM 更新应用到实际 DOM 中，并执行相关的生命周期钩子和设置 effect 的阶段

该阶段的工作一旦开始就会**同步执行直到**完成

`Commit` 阶段的工作可以分为三个子阶段：`BeforeMutation`、`Mutation`、`Layout`

每个子阶段的任务也分为三个部分：`commitXXXEffects`、`commitXXXEffects_begin`、`commitXXXEffects_complete`

- commitXXXEffects 函数是每个子阶段的入口函数，**初始化** nextEffect 变量为 finishedWork（Reconcile 后的 FiberNode），然后执行下一部分的 commitXXXEffects_begin 函数

- commitXXXEffects_begin 会**向下遍历** FiberNode，如果有副作用（subtreeFlags）就对当前 FiberNode 执行 commitXXXEffects_complete 方法

```js
function commitXXXEffects_begin() {
  while(nextEffect !== null) {
    let fiber = nextEffect
    let child = fiber.child
    
    // ...
    
    if(fiber.subtreeFlags !== NoFlags && child !== null) {
      nextEffect = child
    } else {
      commitXXXEffects_complete()
    }
  }
}
```

- commitXXXEffects_complete 主要就是对 flags 做**具体操作**了，

执行 commitXXXEffectsOnFiber，如果当前 FIberNode 存在兄弟 FiberNode，则对兄弟 FiberNode 执行 commitXXXEffects_begin，如果没有兄弟 FiberNode，则对父 FiberNode 执行 commitXXXEffects_complete

```js
function commitXXXEffects_complete(root) {
  while(nextEffect !== null) {
    let fiber = nextEffect
    
    try {
      commitXXXEffectsOnFiber(fiber, root)
    } catch (err) {
      
    }
    
    let sibling = fiber.sibling
    
    if(sibling !== null) {
      // ...
      nextEffect = sibling
      return
    }
    
    nextEffect = fiber.return
  }
}
```

每个部分都会用 DFS 遍历 fibertree，最终会在 commitXXXEffectsOnFiber 中针对不同的 flags 做出不同的处理

**BeforeMutation** 阶段就是 React **准备**对 DOM 进行实际更改之前的阶段。 就像在开始放置拼图前我们需要先检查新的拼图块和现有的画面。在这个阶段，React会完成诸如调用组件的 `getSnapshotBeforeUpdate` 这样的生命周期方法。这样做的目的是让组件有机会获取 DOM 的某些信息（比如滚动位置），因为接下来 DOM 可能会发生变化。

**Mutation** 阶段，React 开始根据 Reconcile 阶段计算出的差异来**实际更新** DOM 节点。这包括删除、移动或插入、更新 DOM元素

- **删除**：删除 `FiberNode.deletions` 数组中的全部节点及其子节点，同时要考虑内部组件的 unmount 逻辑（effect 的清理等逻辑也要执行）

- **插入或移动**：对 FiberNode.flag 为 `Placement` 的节点，使用 parentNode.appendChild 或 parentNode.insertBefore 方法来操作 DOM

- **更新**：读取 `FiberNode.updateQueue` 中记录的更新属性（style、innerHTML、文本、其他），处理节点的属性更新

完成 Mutation 的工作后，进入 Layout 阶段之前，会执行 **FiberTree 的切换**

**Layout** 阶段会遍历 FiberNode 并根据 tag 不同，执行不同的操作。例如 FunctionComponent 会执行 `useLayoutEffect` 回调；ClassComponent 会执行 componentDidMount/Update 方法

而`useEffect`会等待浏览器**完成绘制后异步**调用。