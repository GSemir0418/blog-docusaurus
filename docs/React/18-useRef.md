---
sidebar-position: 18
title: useRef
date: 2024-05-18
authors: gsemir
tags: [react, useRef]
---

# useRef

- 返回的一个普通 JavaScript 对象，其中有一个 `.current` 属性指向传递给 `useRef` 的初始值。`useRef` 并不会创建一个新的对象，它返回的是同一个 ref 对象每次渲染。而且，`useRef` 并**不负责处理状态更新**，对 `.current` 属性的修改不会触发组件重新渲染。
- 用于获取 React 组件中的 **DOM 元素的引用**，或者存储**任何可变值**，且这个值改变时**不会引起组件重新渲染**。
- 这使得 `useRef` 成为存储**与当前渲染无关的数据**的好地方，比如保存上一次的状态，或是一个不需要引起渲染更新的计时器 ID

当调用 useRef hook 时，`mount` 阶段会创建一个 hook 对象，该对象的 `memoizedState` 存储的是 `{ current: initialValue }` 对象，最后向外部返回这个对象；`update` 阶段**仅读取**之前 hook 对象的 memoizedState 属性，不做其他更新的任务。

**ref 工作流程**

- Render 阶段会标记 Ref flag，对应的内部函数为 markRef

- Commit 阶段会根据标记的 Ref flag 执行 ref 相关的操作，对应的相关函数有 commitDetachRef（Mutation）、commitAttachRef（Layout）

**ref 的失控**

主要是由于**开发者和 React 同时试图控制同一个 DOM 元素**，最终可能导致程序行为异常，出现各种难以追踪的 bug。

`ref` 在很多场景下是非常有用的，比如当你需要：

- 管理焦点、文本选择或媒体播放。
- 触发强制动画。
- 与第三方 DOM 库集成（echarts）。
- 在页面加载时测量 DOM 节点的大小或位置。

在这些情况下，`ref` 提供了一种逃生舱，让你能够进行一些 React 自己无法做到的底层操作。

关键在于，当你使用 `ref` 进行操作时，你要**确保不会干扰到 React 的状态管理**。例如，如果你改变了一个 `input` 元素的值，你应该同时更新与之关联的 state，这样 React 的状态就能够与 DOM 的状态保持同步。

如果不这么做，React 的状态和实际的 DOM 状态可能会**不一致**，这就是我们所说的“失控”。这种不一致可能导致一些诡异的 bug，因为 React 的虚拟 DOM 更新机制假定它完全控制了 DOM 元素。

所以，`ref` 绝对是一个有用的工具，但就像所有有力的工具一样，使用不当可能会引起问题。最佳实践是，**在不可避免需要操作 DOM 时使用它，并始终保持对 React 状态的同步和尊重。**

