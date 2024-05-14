---
sidebar-position: 15
title: useState 与 useReducer
date: 2024-05-15
authors: gsemir
tags: [react, useState, useReducer]
---

# useState 与 useReducer

[源码](https://github.com/facebook/react/blob/main/packages/react-reconciler/src/ReactFiberHooks.js#L1810C10-L1810C24)

## 基本使用

```js
import { useReducer } from "react";

const initialState = { count: 0 };

const init = (initialState) => {
  return { count: initialState.count + 10 };
};

const reducers = (state, action) => {
  switch (action.type) {
    case "INCREASE":
      return { count: state.count + action.payload };
    default:
      return state;
  }
};

export const App2 = () => {
  const [state, dispatch] = useReducer(reducers, initialState, init);
  return (
    <div
      onClick={() => {
        dispatch({ type: "INCREASE", payload: 1 });
      }}
    >
      {state.count}
    </div>
  );
};

```

## Mount 阶段

### useState

调用 `mountState` 方法，接收 initialState 值

创建 hook 对象，如果传入的 initialState 是函数，则调用函数使用其返回值作为初始值 initialState；然后将初始化的值保存到 hook 对象中的 memoizedState 和 baseState 中，最终返回 `[hook.memoizedState, dispatch]`

需要注意的是，`hook.queue.lastRenderedReducer` 值为内置默认的 `basicStateReducer`

### useReducer

调用 `mountReducer` 方法，接收 reducer、initialArg 和 init 函数作为参数

创建 hook 对象，根据传入的 initialArg 和 init 处理 initialState，后续基本与 useState 一致。

需要注意的是，`hook.queue.lastRenderedReducer` 值为开发者传入的 `reducer`

> `hook.queue.lastRenderedReducer` 是最后一次渲染使用的 reducer 函数的引用。这样可以在状态更新时，确保状态的变化总是基于最近一次渲染的状态，保证了状态更新的一致性

## Update 阶段

### useState

调用 `updateState` 方法，内部调用了 `updateReducer` 方法

### useReducer

调用 `updateReducer` 方法，获取对应的 hook 对象与 hook.queue，更新 state 并返回 [hook.memoizedState, dispatch]

## 总结

**useState 本质上就是一个简化版的 useReducer**

- mount 阶段二者逻辑大体一致，都是先处理初始值，然后构造 hook 对象，唯一的区别在于 `hook.queue.lastRenderedReducer` 属性，useState 对应的是**内置**的 `basicStateReducer` ，而 useReducer 对应的是开发者传入的 `reducer`

- update 阶段，updateState 内部调用的就是 updateReducer