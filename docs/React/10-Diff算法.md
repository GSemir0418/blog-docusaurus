---
sidebar-position: 10
title: Diff算法
date: 2024-05-10
authors: gsemir
tags: [react, reconcile, diff]
---

Diff算法

diff 发生在 Render 阶段，指的是 CurrentFiberNode 和 JSX 对象做对比，然后生成新的 WorkInProgressFiberNode

vue 里面将这个流程称之为 patch

如果完整对比两棵树，那么算法的复杂度也达到了 O(n^3)，n 代表元素的数量

为了降低算法复杂度，React 为 Diff 算法设置了三个限制

- 只对同级元素进行 diff，如果一个 DOM 元素再前后两次更新中跨越了层级，那么 React 不会尝试复用它
- 两个不同类型的元素会产生不同的树，比如元素从 div 变成了 p，那么 React 会直接销毁 div 以及子元素，完全新建 p 元素及其子孙元素
- 开发者可以通过 key 来暗示哪些子元素能够保持稳定。比如两个元素交换了位置，加了 key React 就会复用，不加就销毁并重建

整个 Diff 的流程分为两类

- 更新后只有一个元素，此时就会根据 newChild 创建对应的 wip FiberNode，对应单节点 diff 流程
- 更新后有多个元素，此时就会遍历 newChild 创建对应的 wip FiberNode 及其兄弟元素，对应多节点 diff 流程

单节点 diff

- 判断 key
  - 如果没有 key，相当于 null，也属于相同的情







> React 的 diff 算法目前使用的是名为 `Reconciliation` 的算法，在首次 mount 完成后，就会产生 Current Fiber Tree，再次渲染时，就会在 Render 阶段的 beginWork 方法中，使用 Diff 算法对新旧 FiberNode 节点进行对比，再决定如何产生新的 FiberNode。

如果完整对比两棵树，那么算法的复杂度也达到了 O(n^3)，n 代表元素的数量

为了降低算法复杂度，React 基于**三个限制**来优化其性能：

1. 只对同级元素进行 DIff。如果一个DOM 元素再前后前次更新中跨越了层级，那么 React 不会尝试复用它

2. 两个不同类型的元素会产生不同的树。比如元素从 div 变成了 p，那么 React 会直接销毁 div 以及子元素，完全新建 p 元素及其子孙元素

3. 开发者可以通过 `key` 属性来告诉哪些子元素在不同的渲染下保持稳定。比如两个元素交换了位置，加了 key，React 就会复用，不加就销毁并重建



Diff 算法分为单节点 diff 和多节点 diff

单节点指的是更新的节点是单一节点

单节点 diff ：

1. 判断 key 是否相同
   - 相同（包括都没有的 key 情况），继续对比
   - 不同，不能复用，继续看兄弟节点
2. 判断 type 是否相同
   - 相同，复用
   - 不同，不能复用，兄弟节点也不行

多节点 diff 会分为两轮遍历

只对同级元素进行 Diff。如果一个DOM 元素再前后前次更新中跨越了层级，那么 React 不会尝试复用它

第一轮遍历会从前往后进行遍历，存在以下三种情况

- 新旧子节点的 key 和 type 都相同，可以复用，结束遍历
- 新旧子节点 key 相同但 type 不同，此时会根据 React 元素生成一个全新的 FiberNode，旧的 FiberNode 被放入 deletions 数组中，继续遍历
- 新旧子节点的 key 和 type 都不同，结束遍历

如果第一轮遍历被提前终止了，意味着还有新的 JSX 元素或者旧的 FiberNode 没有被遍历，因此会采用第二轮遍历去处理

第二轮遍历会遇到三种情况

- 只剩下旧子节点，将旧的子节点添加到 deletions 数组中准备删除（删除）
- 只剩下新的 JSX 元素，根据 ReactElement 来创建 FiberNode 节点（新增）
- 新旧子节点都有剩余，会将剩余的 FiberNode 放入一个 map 中，遍历剩余的新 JSX 元素，然后从 map 中寻找能够复用的 FiberNode，如果能找到，就拿来复用（移动）
  - 如果找不到，就新增，如果剩余的 JSX 元素都遍历完了，map 中还有剩余的 FiberNode，就将它们添加到 deletions 中