---
sidebar-position: 113
title: React 工作原理(旧)
date: 2024-04-05
authors: gsemir
tags: [react, reconcile, fiber]
---

## React 更新流程

React 中的更新流程大致可以分为以下几个阶段：

1. **触发更新（Update Trigger）：** 更新可以由组件的状态变化、属性变化、父组件的重新渲染、用户事件等触发，如：
   - 创建 React 应用的根对象 `ReactDOM.creatRoot().render()`；
   - 类组件 `this.setState()`；
   - 函数组件 `useState useEffect`；
2. **调度阶段（Schedule Phase）：** 调度器根据更新任务的优先级，将更新任务添加到相应的更新队列中，这个阶段决定了何时以及以何种优先级执行更新任务。
3. **协调阶段（Reconciliation Phase）：** 也叫 Render 阶段， `Reconciler` 负责根据虚拟DOM构建 Fiber 树，处理新旧虚拟 DOM 树之间的差异，生成更新计划，确定需要进行的操作。
4. **提交阶段（Commit Phase）：** 提交阶段将更新同步到实际的 DOM 中，React 执行 DOM 操作，例如创建、更新或删除 DOM 元素，反映组件树的最新状态。

## Reconciler

随着前端框架的出现，前端开发者的工作方式发生了根本性的变化，从过程驱动（JQuery）转变为状态驱动。在状态驱动的模式下，开发者不再直接操作宿主环境 API，而是通过前端框架提供的运行时核心模块来管理页面状态和更新。这些核心模块，例如 React 中的 `Reconciler` 和 Vue 中的 `Renderer`，负责将开发者编写的代码翻译成对应的宿主环境 API 调用，以更新页面。

`Reconciler` 的中文名叫协调器，它负责**处理 React 元素的更新**并在**内部构建虚拟 DOM**，这个过程是 React 框架实现高效的 UI 渲染和更新的核心逻辑所在。以下是 `Reconciler` 主要做的事情：

1. **接收并解析 React 元素：** Reconciler 接收 JSX 或者 createElement 函数返回的 React 元素，并将其解析成虚拟 DOM 树的结构。
2. **协调更新：** 比较新旧虚拟 DOM 树的差异，确定哪些部分需要更新，并生成更新计划。
3. **构建虚拟 DOM 树：** 在组件更新时，根据生成的更新计划，Reconciler 会更新虚拟 DOM 树的结构以反映最新的组件状态。
4. **生成 DOM 更新指令：** 将更新后的虚拟 DOM 树转换为真实的 DOM 更新指令，描述了如何将变更应用到实际的 DOM 树上。

## FiberNode

`FiberNode`（纤维节点）是 `Reconciler` 的核心数据结构之一，用于构建协调树。`Reconciler` 使用 `FiberNode` 来表示 React 元素树中的节点，并通过比较 Fiber 树的差异，找出需要进行更新的部分，生成更新指令，来实现 UI 的渲染和更新。

每个 `FiberNode` 都表示着 React 元素树中的一个节点，它包含了以下几个重要的字段：

- **type**：节点的类型，可以是原生 DOM 元素、函数组件或类组件等；
- **props**：节点的属性，包括 DOM 元素的属性、函数组件的 props 等；
- **stateNode**：节点对应的实际 DOM 节点或组件实例；
- **child**：指向节点的第一个子节点；
- **sibling**：指向节点的下一个兄弟节点；
- **return**：指向节点的父节点；
- **alternate**：指向节点的备份节点，用于在协调过程中进行比较；
- **effectTag**：表示节点的副作用类型，如更新、插入、删除等；
- **pendingProps**：表示节点的新属性，用于在协调过程中进行更新。
- **memoizedState**：储存节点的 Hooks

`FiberNode` 是一个链表结构，它有三个指针，分别记录了当前节点的下一个兄弟节点，子节点，父节点。当遍历**中断**时，它是**可以恢复**的，只需要保留当前节点的索引，就能根据索引找到对应的节点

## Fiber

React Fiber 是 React 的一个重写版本的核心算法。它是对 React 框架中核心的协调算法（reconciliation）的**重新实现**。在之前的React版本中，这部分被称为 `Stack Reconciler`。

以下是React Fiber解决的一些主要问题：

1. **增量渲染（Incremental Rendering）**：
   Fiber Reconciler使React能够将渲染任务切割成多个小任务，分批次完成。不像之前的Reconciler那样必须一口气完成整个渲染树的计算，Fiber使得React可以利用多个帧去分散工作量。
2. **任务暂停、中断与恢复（Pause, Abort, and Resume）**：
   通过Fiber，React可以在渲染过程中根据需要暂停、中断或恢复工作。这个特性可以用于实现数据的懒加载，让React根据资源的可用性来调整工作流。React 18 版本中对应的组件是 `<Suspense>`，允许组件“等待”某些内容加载完成，并且可以直接在JSX中定义加载状态时的回退内容。
3. **更好的错误边界（Error Boundaries）**：
   Fiber引入了更好的错误处理机制。如果在渲染过程中出现错误，Fiber能更优雅地捕捉组件树的错误，并提供一个回退的UI，而不是整个应用崩溃。React 18 版本中对应的组件是 `<Suspense>`，允许组件“等待”某些内容加载完成，并且可以直接在JSX中定义加载状态时的回退内容。
4. **优先级和任务调度（Prioritization and Task Scheduling）**：
   Fiber Reconciler为React的更新任务引入了优先级的概念。现在React可以决定哪些任务更重要，优先处理，例如用户的输入具有高优先级。

React提供的新功能，如Suspense和Concurrent Mode，都是建立在Fiber架构之上的，它们使得开发者能够更好地控制应用的性能和用户体验。

## Reconciler 工作流程

`Reconciler` 的工作流程总的来说就是对 Fiber 树进行一次 **深度优先遍历（DFS）** ，首先访问根节点，然后依次访问左子树和右子树，通过比较新节点（新生成的 `React Element`）和旧节点（现有的 `FiberNode`），生成更新计划，并打上不同的标记。

1. **遍历 Fiber 树：** React 使用深度优先搜索（DFS）算法来遍历 Fiber（workInProgress） 树，首先会从 Fiber 树的根节点开始进行遍历，遍历整个组件树的结构。
2. **比较新旧节点：** 对于每个 Fiber 节点，`Reconciler` 会比较新节点（即新的 `React Element`）和旧节点（即现有的 `FiberNode`）之间的差异，比较的内容包括节点类型、属性、子节点等方面的差异。
3. **生成更新计划：** 根据比较的结果，`Reconciler` 会生成一个更新计划，用于确定需要进行的操作，更新计划通常包括哪些节点需要**更新**、哪些节点需要**插入**到 DOM 中、哪些节点需要**删除**等信息。
4. **打标记（Tagging）：** 为了记录不同节点的操作，React 会为每个节点打上不同的标记。例如，如果节点需要更新，可能会打上更新标记（Update Tag）；如果节点是新创建的，可能会打上插入标记（Placement Tag）；如果节点被移除，可能会打上删除标记（Deletion Tag）等。
5. **更新 Fiber 节点：** 根据生成的更新计划和标记，`Reconciler` 会更新对应的 Fiber 节点以反映组件的最新状态。更新操作可能包括更新节点的状态、更新节点的属性、调用生命周期方法等。
6. **递归处理子节点：** 对于每个节点的子节点，React 会递归地重复进行上述的比较和更新操作，以确保整个组件树都得到了正确的处理。

当所有 React Element 都比较完成之后，会生成一棵新的 Fiber 树，此时，一共存在两棵 Fiber 树：

- **current**: 与视图中真实 UI 对应的 Fiber 树，当 React 开始新的一轮渲染时，会使用 `current` 作为参考来比较新的树与旧树的差异，决定如何更新 UI；
- **workInProgress**: 触发更新后，正在 Reconciler 中计算的 Fiber 树，一旦 `workInProgress` 上的更新完成，它将会被提交为新的`current`，成为下一次渲染的参考树，并清空旧的 `current` 树。

- **双缓冲模式**：在计算机图形领域，通过让图形硬件交替读取两套缓冲数据，可以实现画面的无缝切换，减少视觉的抖动甚至卡顿。current树和 workInProgress 树使用双缓冲模式，可以减少 fiber 节点的开销，减少性能损耗

## 示例

说了这么多概念性的内容，实际上对于函数组件的渲染过程还是比较模糊，下面我们以一段真实代码为例，解释函数组件的执行逻辑：

```react
import "./styles.css";
import { useState, useEffect, useMemo, useRef } from "react";

export default function App() {
  const [state, setState] = useState(0);
  const ref = useRef(null)
  useEffect(() => {
    if(ref.current){
      ref.current.style.color = 'red'
    }
  }, [])
  const memoState = useMemo(()=>{
    return state + 1
  },[state])

  const onClick = () => {
    setState((p) => {
      return p + 1;
    });
  };
  
  return (
    <div className="App">
      <h1 ref={ref}>{memoState}</h1>
      <h1 onClick={onClick}>{state}</h1>
    </div>
  );
}
```

我们知道，在 React 渲染组件的过程中，最重要的步骤就是 Reconcile，那么 FiberNode 是如何维护组件的 hooks 呢

**FiberNode 在 mountState 阶段，使用 `memoizedState` 属性，按定义顺序，以链表结构存储节点定义的的全部 Hooks**

每个 hook 都有一个 `queue` 属性和 `next` 属性，queue 包含挂起操作 （`pending`）、当前呈现的状态 （`lastRenderedState`） 和更多数据；而 next 属性保存的是对下一个 hook 的引用

```ts
const queue: UpdateQueue<S, BasicStateAction<S>> = {
  pending: null,
  lastRenderedState: (initialState: any),
  ...
};
```

以下面这段代码为例

```react
const [state,setState] = useState(0)
const [secondState,setSecondState] = useState("0")

const increment = () => {
    setState((prev) => prev + 1)
    setSecondState((prev) => prev + "2")
}
```

假设此时触发了 increment 函数，即两个 state 都发生了 `dispatchAction` 过程后，对应的 FiberNode 节点的 memoizedState 结构如下

```ts
fiber: FiberNode {
  child: ...
  memoizedState: {
    ...
    next: { // 每个 hook 都存在对下一个 hook 的引用
      ...,
      lastRenderedState: "0",
      pending: {
        action: prev => prev + "2",
        ...
      }
    },
    queue: {
      ...
      lastRenderedState: 0,
      pending: {
        action: prev => prev + 1,
        ...
      }
    }
  }
}
```

在更新时，会从 memoizedState 队列中取出 useState 的 hooks 依次执行；在最后的 commit 阶段结束（更新 DOM 结束）后，最后会检查一次 useEffect hook 的依赖项，按需执行。

