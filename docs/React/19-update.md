---
sidebar-position: 19
title: update
date: 2024-05-19
authors: gsemir
tags: [react, update, update queue]
---

# update

在 React 中，有许多触发状态更新的方法，比如

- ReactDOM.createRoot
- this.setState
- this.forceUpdate
- useState dispatcher
- useReducer dispatcher

虽然这些方法执行的场景会有所不同，但是都可以接入同样的更新流程，原因是因为它们使用同一种数据结构来表示「更新」，即 Update

## [Update](https://github.com/facebook/react/blob/main/packages/react-reconciler/src/ReactFiberHooks.js#L162C1-L169C3)

React 中更新是存在优先级的，其心智模型类似于「代码版本管理工具」

函数组件中的 Update 类型如下

```ts
export type Update<S, A> = {
  lane: Lane,
  revertLane: Lane,
  action: A,
  hasEagerState: boolean,
  eagerState: S | null,
  next: Update<S, A>,
};
```

- **lane**: 每个更新被赋予一个或多个 `lane`，用于标识其优先级级别

- **revertLane**: 当更新被打断或回滚时，`revertLane` 用于标识这个更新应该返回到哪个 `lane`

- **action**: 表示当这个更新被应用时，应该执行什么动作，用于根据当前的状态和更新的内容来计算出新的状态

- **hasEagerState**: 这个字段标记是否已经计算出了这个更新的「急切」状态，即是否已经提前尝试应用这个更新

- **eagerState**: 这个字段在 `hasEagerState` 为 `true` 时保存预计算的新状态。这个预计算的状态是尽早计算出来的，目的是为了尽可能快地应用更新，提高响应速度。如果 `hasEagerState` 为 `false`，则此字段为 `null`。

- **next**: 更新是以**链表**的形式组织的，`next` 字段指向链表中的下一个更新

## [UpdateQueue](https://github.com/facebook/react/blob/main/packages/react-reconciler/src/ReactFiberHooks.js#L171C1-L177C3)

`UpdateQueue` 是用于管理一个 Fiber 的**状态更新队列**。这个队列以**链表**的形式组织所有挂起的更新

```ts
type UpdateQueue<S, A> = {
  pending: Update<S, A> | null,
  lanes: Lanes,
  dispatch: (A => mixed) | null,
  lastRenderedReducer: ((S, A) => S) | null,
  lastRenderedState: S | null,
};
```

- **pending**: 这个字段指向队列中的**最后一个更新**。更新是以环形链表的形式组织的，所以这个最后一个更新的 `next` 属性会指向队列中的第一个更新。如果 `pending` 为 `null`，表示没有任何更新在这个队列中

- **lanes**: 这个字段表示当前 `UpdateQueue` 中所有更新的**合并后的优先级**

- **dispatch**: 用于触发更新的函数。它接受一个 `action` 作参数，并将其加入更新队列。这个 `dispatch` 函数通常是通过 `useReducer` 或者 `useState` 钩子返回的。如果当前没有与更新队列关联的 `dispatch` 函数，则此字段为 `null`

- **lastRenderedReducer**: 这个字段保存了**最后一次渲染**时使用的 `reducer` 函数。reducer 函数接受当前的状态和一个 `action`，返回新的状态。它被用于 `useReducer` 钩子，以及内部状态更新逻辑中。如果没有使用到 reducer，这个字段可能为 `null`

- **lastRenderedState**: 这个字段保存了**最后一次渲染**时组件的状态。这个状态被**用于下一次**渲染前的计算，特别是在处理优化或者中断更新时，比对新老状态以决定是否需要重新渲染。

## 更新流程

1. **触发更新**

当用户与界面交互（例如点击按钮）时，这通常会触发事件处理函数，该函数通过调用 `useState` 的 setter 函数或 `useReducer` 的 dispatch 方法来请求一个状态更新

2. **创建 Update**

在事件处理函数中，一旦调用了 setter 或 dispatch 方法，React 会立即为这次操作创建一个新的 `Update` 对象。这个对象包含了代表请求的 action（对于 `useState` 是新的状态值，对于 `useReducer` 是用户提供的 action 对象），以及当前的优先级 `lane`。

3. **添加更新到 UpdateQueue**

React 接着会把这个 `Update` 对象添加到 Fiber 节点的 `UpdateQueue` 中，的 `pending` 链表中。React 会把它放在以环形链表组织的 `pending` 更新列表的尾部。同时，新的 `Update` 的 `lane` 会被加到 `UpdateQueue` 的 `lanes` 字段中，表示此队列中有新的 `lane` 需要去处理。如果是第一个更新，它会成为链表的开始和结束；如果不是，它将被添加到链表的末尾。

4. **调度更新**

一旦新的 `Update` 被添加到了队列中，React 就会根据更新的优先级来安排工作。当 React 开始处理 Fiber 节点时，它会遍历该节点的 `UpdateQueue`，并运用更新队列中的每一个 `Update` 来**计算**（beginWork）出新的状态。这可能会立即开始，或者被推迟到其他更高优先级的工作完成之后。

5. **渲染阶段**

当这个更新的优先级变为当前正在处理的优先级后，React 就会开始重新渲染这个组件。过程中，在这个阶段，React 会遍历 `UpdateQueue`，通过使用每个 `Update` 的 `action` 和 `lastRenderedReducer` 动态计算出新的组件状态。

6. **提交阶段**

根据新计算出的状态，React 将与上一次渲染的结果进行对比。如果存在差异，React 会提交这些改变，并把它们同步到 DOM 上

## 性能优化策略

有一个很神奇的现象

```jsx
function Child() {
  console.log('child render')
  return <span>child</span>
}

function App() {
  const [num, setNum] = useState(0)
  console.log('App render', num)
  
  return (
  	<div onClick={() => setNum(1)}>
    	<Child />
    </div>
  )
}
```

首次渲染

```
App render 0
child render
```

第一次点击

```
App render 1
child render
```

第二次点击

```
App render 1
```

第三次及之后的点击，将不会有任何 log

- 第二次打印结果说明 child 组件命中了 bailout 策略，跳过了 Reconcile 过程，不进入 Render 阶段

- 第三次及之后的打印结果说明 App 和 child 都命中了 eagerState 策略，此次更新不会进入 Schedule 阶段，更不会进入 Render 阶段

eagerState 的核心逻辑是如果某个状态更新前后没有变化，则可以跳过后续的更新流程，该策略将状态的计算提前到了 Schedule 阶段之前。当有 FiberNode 命中 eagerState 策略后，就不会在进入 Schedule 阶段，而是直接使用上一次的状态

这两种策略都是用来避免不必要的计算和渲染，以提高应用的性能。Eager State Update 通过**预先更新状态**减少了评估更新必要性的工作负担，而 Bailout 通过**比较新旧状态**避免了不必要的虚拟 DOM 对比和实际 DOM 更新