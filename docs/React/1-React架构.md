---
sidebar-position: 1
title: React 整体架构
date: 2024-05-01
authors: gsemir
tags: [react]
---

# 背景

## 前端框架的理解

早期使用 jQ 的时代，需要开发者手动操作 dom 节点，那时流行的还是 MPA 的模式，各个页面的代码量还在可接受的范围内

但是随着单页应用的流行，客户端 js 代码量出现井喷，手动操作 dom 节点的模式给开发者带来了很大的心智负担

此时就出现了能够**基于状态声明式渲染**以及**提供组件化开发模式**的库，例如 Vue 和 React，这两个本质上仅仅是构建 UI 的库，但是随着应用复杂度的提升，还需要前端路由方案，状态管理方案，所以 react-router、vue-router、vuex、redux 随之诞生

Vue 或 React 和这些周边生态产品共同构成了一个技术栈

一款现代前端框架，在它本身以及它的周边生态中，至少要包含以下几个方面：

- **基于状态的声明式渲染**
- **支持组件化开发**
- **客户端路由方案**
- **状态管理方案**

## React 和 Vue 描述页面对比

React 中使用 JSX 来描述 UI，因为 React 团队认为 UI 本质上与逻辑存在耦合的部分，作为前端工程师，JS 是使用最多的，如果同样使用 JS 来描述 UI，就可以**让 UI 和逻辑配合的更密切**

使用 JS 来描述页面，可以更加灵活，主要体现在

- 可以在 if 语句和 for 循环中使用 JSX
- 可以将 JSX 赋值给变量
- 可以把 JSX 当作参数传入，以及在函数中返回 JSX

而模版语言的历史则需要从后端说起，早期在前后端未分离时代，后端有各种各样的模板引擎，其本质是扩展了 HTML，在 HTML 中加入逻辑相关的语法，之后在动态的填充数据进去，如果单看 Vue 中的模板语法，实际上和后端语言中的各种模版是非常相似的

**总结**

- 模板语法的出发点是，既然前端框架使用 HTML 来描述 UI，那么就扩展 HTML 语法，使它能够描述逻辑，也就是「**从 UI 出发，扩展 UI，在 UI 中能够描述逻辑**」

- 而 JSX 语法的出发点是，既然前端使用 JS 来描述逻辑，那么就扩展 JS 语法，让它能够描述逻辑，也就是「**从逻辑出发，扩展逻辑，描述 UI**」

虽然这两者都达到了同样的目的，但是对框架的实现产生了不同的影响

## 前端框架的分类：从状态到 UI 的变化路径

现代前端框架的核心特点是“基于状态的声明式渲染”，简单来说就是：**UI 的变化取决于状态的变化**，用公式表示就是 `UI = f(state)`。

但不同的框架在**将状态变化映射到 UI 变化**这一步的实现方式有所不同，具体来说，就是 **状态 (state) 到 UI 的对应关系**，以及 **计算 UI 变化的路径** 存在差异。

我们可以根据 **状态与 UI 对应关系的抽象层级** 对前端框架进行分类，层级越高，意味着框架在运行时需要花费更少的时间来寻找状态和 UI 之间的对应关系，从而提升性能。

1. **元素级框架 (Svelte, Solidjs)**：这类框架直接将状态与 DOM 元素进行绑定，状态的改变会直接影响对应的 DOM 元素。它们 **没有中间层**，状态变化到 UI 变化的路径只有一条，因此性能非常高。
2. **组件级框架 (Vue)**：这类框架将 UI 划分成多个组件，每个组件拥有自己的状态，状态变化会触发组件的重新渲染，最终影响整个 UI。它们 **引入组件这一层级**，状态变化到 UI 变化的路径相对较短，但比元素级框架多了一层。
3. **应用级框架 (React)**：这类框架将整个应用程序视为一个**大的状态树**，状态变化会触发整个状态树的更新，进而导致 UI 的更新。它们 **抽象出应用这一层级**，状态变化到 UI 变化的路径最长，需要经过更多的中间层，因此运行时需要花费更多时间来计算 UI 变化。

**总结：**

- 元素级框架的性能最高，但抽象能力较低；
- 组件级框架的性能中等，抽象能力中等；
- 应用级框架的性能较低，但抽象能力最高。

## 虚拟 dom

最初是由 React 团队所提出的概念，这是一种编程的思想，指的是针对真实 UI DOM 的一种描述能力

在 React 中，使用了 JS 对象来描述真实的 DOM 结构。虚拟 DOM 和 JS 对象之间的关系，前者是一种思想，后者是这种思想的具体实现

使用虚拟 DOM 有如下的优点：

- **相较于 DOM 的体积和速度优势**
  - JS 层面的计算速度，要比 DOM 层面的计算快得多
    - DOM 对象最终要被浏览器绘制前，浏览器会有很多工作要做
    - DOM 上的属性是非常多的
  - 虚拟 DOM 发挥优势的时机主要体现在**更新**的时候，相比较 innerHTML 要将已有的 DOM 节点全部销毁，虚拟 DOM 能够做到针对 DOM 节点做最小程度的修改
- **多平台渲染的抽象能力**
  - 浏览器、Nodejs 宿主环境使用 ReactDOM 包
  - Native 宿主环境使用 ReactNative 包
  - Canvas、SVG 宿主环境使用 ReactArt 包

在 React 中，通过 JSX 来描述 UI，JSX 仅仅是一个语法糖，会被 Babel 编译为 `createElement` 函数的调用，该方法调用之后会返回一个 JS 对象，该对象就是虚拟 DOM 对象，官方更倾向于称之为一个 React 元素

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

