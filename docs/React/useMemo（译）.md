---
title: useMemo（译）
date: 2023-02-08T15:19:00+08:00
tags: ["react", "useMemo"]
sidebar-position: 4
authors: gsemir
---

`useMemo` 是一个React Hook，能够在 re-render 之间缓存一个计算结果。

```react
const cachedValue = useMemo(calculateValue, dependencies)
```

## 介绍

### `useMemo(calculateValue, dependencies)`

在组件函数体顶层调用 `useMemo` 以在 re-render 过程中缓存计算值：

```react
import { useMemo } from 'react';

function TodoList({ todos, tab }) {
  const visibleTodos = useMemo(
    () => filterTodos(todos, tab),
    [todos, tab]
  );
  // ...
}
```

#### 参数

- `calculateValue`：计算缓存值的方法。它应该是纯函数，不应接收任何参数，同时应该返回一个任意类型的值。React 将会在初始化渲染组件时调用这个函数，在后续的渲染中，如果 `dependencies` 没有改变，React 会再次返回相同的值。否则，React 将调用 `calculateValue`，同时将其结果返回，并储存这个结果供后续复用。
- `dependencies`：`calculateValue`函数中出现的动态引用值的列表。动态值包括props、state在内的直接定义在组件函数体顶层的全部变量。

#### 返回值

在初始化渲染中，`useMemo` 返回 `calculateValue` 函数的结果。

后续渲染过程中，如果依赖项不变，那么它将返回上一次渲染缓存的结果；否则重新调用 `calculateValue `并返回新的计算结果。

#### 注意事项

- `useMemo` 是一个 Hook，所以只能在组件函数体顶层或者自定义 Hooks 中使用。不可以在条件或循环语句中使用。
- 严格模式下的开发环境中，React 将会调用 `calculateValue` 函数两次
- React 不会丢弃缓存的值，除非有特定的原因这样做。例如，在开发环境中，React 会在编辑组件文件时丢弃缓存；在开发或生产环境中，如果组件在初始挂载期间挂起，React 都会丢弃缓存。这可以在一定程度上提升应用性能。



## 用法

### 跳过额外的重新计算过程

为了在 re-render 期间缓存一个计算值，可以讲计算逻辑包裹于 `useMemo` ，并在组件函数体顶层调用它：

```react
import { useMemo } from 'react';

function TodoList({ todos, tab, theme }) {
  const visibleTodos = useMemo(() => filterTodos(todos, tab), [todos, tab]);
  // ...
}
```

我们要传递两个值到 useMemo 中：

1. calculation function：不接受任何参数，就像 `() =>`，返回计算结果
2. 依赖项列表：calculation function 在计算过程中所使用到的全部值的列表

换句话说，`useMemo` 直到依赖项发生改变，否则会在 re-render 期间缓存计算结果。

默认情况下，React 会在 re-render 时重新运行全部组件函数体。例如下面的 `TodoList` 组件，当 state 更新或者接收来自父组件传来的新的props时，组件内部的 `filterTodos` 就会重新执行。

```react
function TodoList({ todos, tab, theme }) {
  const visibleTodos = filterTodos(todos, tab);
  // ...
}
```

当数据量很大或者计算逻辑很复杂时，这样的计算过程十分影响性能。此时我们希望在 `todos` 和 `tab` 没有改变时，就跳过计算过程，复用上次的计算值即可。这也是 `useMemo` 的典型应用场景之一。

> #### 如何判断计算是否昂贵
>
> 使用 `console.time` 来衡量
>
> ```react
> console.time('filter array');
> const visibleTodos = filterTodos(todos, tab);
> console.timeEnd('filter array');
> ```
>
> 控制台会打印出：`filter array: 0.15ms` ，如果这个时间超过了 1ms，则可以考虑使用 `useMemo`



### 跳过组件的re-render过程

默认情况下，当组件 re-render 时，React 也会递归地重新渲染其全部子组件。这可能会影响页面性能，因为有时某些子组件并不需要 re-render。

第一种想到的方案是利用 `memo` API 包裹子组件，当子组件的 props 属性没有改变时，就不会参与 re-render 过程：

```react
// TodoList
export default function TodoList({ todos, tab, theme }) {
  // ...
  return (
    <div className={theme}>
      <List items={visibleTodos} />
    </div>
  );
}

// List
import { memo } from 'react';

const List = memo(function List({ items }) {
  // ...
});
```

当 List 组件接收到的 items 属性没有改变时，List 组件将不会参与 re-render 过程。

但是当我们需要在父组件 TodoList 计算 visibleTodos 值时，由于 re-render 会重新执行`const visibleTodos = filterTodos(todos, tab)`，而 `filterTodos` 创造了一个*新的数组*，这导致 List 组件的 props 永远不会是同一个，因此再次重新渲染，我们的 memo 优化方案也失去了作用。

为了解决上述问题，可以将 memo Api 与 useMemo 搭配使用。即 memo 包裹子组件，useMemo 包裹计算过程：

```react
export default function TodoList({ todos, tab, theme }) {
  // Tell React to cache your calculation between re-renders...
  const visibleTodos = useMemo(
    () => filterTodos(todos, tab),
    [todos, tab] // ...so as long as these dependencies don't change...
  );
  return (
    <div className={theme}>
      {/* ...List will receive the same props and can skip re-rendering */}
      <List items={visibleTodos} />
    </div>
  );
}
```



### 依赖项优化

假设我们有一个计算过程，它依赖于直接在组件函数体中创建的对象 searchOptions：

```react
function Dropdown({ allItems, text }) {
  const searchOptions = { matchMode: 'whole-word', text };

  const visibleItems = useMemo(() => {
    return searchItems(allItems, searchOptions);
  }, [allItems, searchOptions]); // 🚩 Caution: Dependency on an object created in the component body
  // ...
```

优化方案一，将 searchOptions 用 useMemo 缓存：

```react
function Dropdown({ allItems, text }) {
  const searchOptions = useMemo(() => {
    return { matchMode: 'whole-word', text };
  }, [text]); // ✅ Only changes when text changes

  const visibleItems = useMemo(() => {
    return searchItems(allItems, searchOptions);
  }, [allItems, searchOptions]); // ✅ Only changes when allItems or searchOptions changes
  // ...
```

更进一步，可以将 searchOptions 的定义合并到 useMemo 中：

```react
function Dropdown({ allItems, text }) {
  const visibleItems = useMemo(() => {
    const searchOptions = { matchMode: 'whole-word', text };
    return searchItems(allItems, searchOptions);
  }, [allItems, text]); // ✅ Only changes when allItems or text changes
  // ...
```



### 缓存一个函数

避免一个函数重复创建，而使其要传递到的组件重新渲染（memo 失效），也可以使用 useMemo 缓存：

```react
export default function Page({ productId, referrer }) {
  const handleSubmit = useMemo(() => (orderDetails) => {
      post('/product/' + product.id + '/buy', {
        referrer,
        orderDetails
      });
  }, [productId, referrer]);

  return <Form onSubmit={handleSubmit} />;
}
```

建议使用 useCallback，否则看起来有点笨重：

```react
export default function Page({ productId, referrer }) {
  const handleSubmit = useCallback((orderDetails) => {
    post('/product/' + product.id + '/buy', {
      referrer,
      orderDetails
    });
  }, [productId, referrer]);

  return <Form onSubmit={handleSubmit} />;
}
```



## 常见问题

### 计算逻辑每次渲染时都会运行两次

严格模式下，React 会额外执行一次组件函数。



### 期待useMemo返回一个对象，但却返回了undefined

检查是否语法错误。。



### 每次组件渲染都会触发useMemo重新运行

- 不写依赖
- 检查依赖项



### 我需要利用useMemo遍历渲染列表项，但是不被允许

不能在循环语句中使用 Hooks

可以将列表项抽离成一个组件，在组件中使用 useMemo 缓存值即可