---
sidebar-position: 1
title: React 面试题
date: 2023-07-13
authors: gsemir
tags: [react]
---

> 参考：https://www.youtube.com/watch?v=7YhdqIR2Yzo&list=PLxRVWC-K96b0ktvhd16l3xA6gncuGP7gJ&index=1&t=72s

首先，JSX 被转换为 React.createElement 的函数调用

使用 [babel](https://babeljs.io/repl#?browsers=defaults%2C%20not%20ie%2011%2C%20not%20ie_mob%2011&build=&builtIns=false&corejs=3.21&spec=false&loose=false&code_lz=JYWwDg9gTgLgBAbwK4GcCmBlGBDGaC-cAZlBCHAORRrYDGMFAUI7RAHYrwCCYYcAvHAAUASgEA-RIzhxWHeAG1OuNABo46GFhUBdAXFSYceIQEYR02e05x2AYQA2wWgGt9oiRrRbjaIQCYLGWoYJCg2YUsZGQAeABNgADdZB2wUFAA5bBA0fgQKORxgNjQoCkJ7J1c8yucXfHEo6Ob4pPEEZTx8GIB6BMTG5ti-tssLfCA&debug=false&forceAllTransforms=false&modules=false&shippedProposals=false&circleciRepo=&evaluate=false&fileSize=false&timeTravel=false&sourceType=module&lineWrap=true&presets=env%2Creact%2Cstage-0%2Cflow&prettier=true&targets=&version=7.24.3&externalPlugins=&assumptions=%7B%7D) 在线解析工具能够直观看到 jsx 代码转换的结果

第一个参数是元素类型，第二个参数是 props，后面的参数都属于 children

函数返回 React 元素，本质上就是一个 js 的对象，主要有以下属性：

$$typeof 安全措施

key

props  props 中包含children className 等其他 props 属性

type

ref

```js
{
  "$$typeof": Symbol(react.element),
  "type": "div",
  "key": null,
  "ref": null,
  "props": {
    "className": "App",
    "children": [
      {
        "type": "h1",
        "key": null,
        "ref": null,
        "props": {
            "children": "Hello CodeSandbox"
        },
        "_owner": null,
        "_store": {}
      }
    ]
  },
  "_owner": null,
  "_store": {}
}
```

为什么 key 和 ref 不是 props 的一部分

React 元素就是上述说的

什么是 React 组件呢

组件是就是输出一个元素树的函数或类

函数组件的输出就是函数返回值

类组件的输出就是render方法的返回值

React 组件接收 props 作为组件的输入



因此 React 元素不仅可以描述 DOM 节点，还可以描述组件



什么是组件实例

当 React 元素描述一个组件时，React 会跟踪它并创建一个组件实例

每个实例都有内部状态和生命周期，这些实例实际上我们非常熟悉

在函数组件中，使用 React Hooks 访问状态和生命周期

在类组件中，我们使用预定义的方法和 this 关键字

### setState 是同步还是异步的

useState 的 setState 函数实际上是同步的，但 React 将多个 setState 调用分组到一个批处理中以优化性能，这可能会使其看起来是异步的

它不是严格意义上的 JavaScript 异步。在计算机科学中对该术语的更一般理解中，它是异步的。

## DOM Diffing 算法

## 虚拟 DOM

## JSX 本质 为啥只能写表达式

## useState为什么不能在条件或循环中使用

## react工作流程

## react fiber

## why hooks

## 分别会打印出什么

```js
setState((n) => {
	console.log(n)
	return n + 1
})
setState((n) => {
	console.log(n)
	return n + 1
})
setState((n) => {
	console.log(n)
	return n + 1
})
```

## useEffect 和 useLayoutEffect 先后顺序，同步还是异步，页面刷新时呢

## useRef 与 useState 区别

为什么不会更新

与 常量的区别

## 受控与非受控