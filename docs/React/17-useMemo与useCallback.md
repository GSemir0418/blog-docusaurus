---
sidebar-position: 17
title: useMemo 与 useCallback
date: 2024-05-17
authors: gsemir
tags: [react, useMemo, useCallback]
---

# useMemo 与 useCallback

## useCallback

在 useCallback 内部，mount 阶段调用 `mountCallback` 方法，将函数和依赖项一起缓存到 hook 对象的 `memoizedState` 属性上（`[callback, nextDeps]`）。

在 update 阶段调用 `updateCallback` 方法，首先拿到之前的 hook 对象（`updateWorkInProgressHook()`），从之前的 hook 对象的 `memoizedState` 属性上拿到之前的依赖数组，对比依赖项是否相同，如果相同则返回之前的 callback，否则就更新缓存，然后返回新的 callback。

## useMemo

在 useMemo 内部，mount 阶段调用 `mountMemo` 方法，将传入的函数**执行**并得到计算值，将计算值和依赖项目存储到 hook 对象的 memoizedState 上面（`[nextValue, nextDeps]`），最后向外部返回计算得到的值。

update 阶段调用 `updateMemo` 方法，首先拿到之前的 hook 对象，从而获取到之前的依赖项，和新传入的依赖项进行一个对比，如果相同，就返回上一次的计算值，否则重新调用传入的函数得到新的计算值并缓存，最后向外部返回新的计算结果。

