---
sidebar-position: 12
title: How root.render() works(译)
date: 2024-04-17
authors: gsemir
tags: [react, render, updateContainer]
---

> https://incepter.github.io/how-react-works/docs/react-dom/how.root_render.works

# root.render() 工作原理

使用 React 渲染UI，首先我们要做：

- 使用 createRoot 创建 root 对象
- 调用 root.render(ui) 方法

```jsx
import { App } from "./app";
import { createRoot } from "react-dom/client";

const container = document.getElementById("root");

// This is the first step
const root = createRoot(container);

// Then, the second
root.render(<App />);
```

这一节我们会聚焦 root.render 方法的定义与原理

## 定义

### 声明

FiberRoot 对于 render 方法的声明在 [`/packages/react-dom/src/client/ReactDOMRoot.js`](https://github.com/facebook/react/blob/80d9a40114bb43c07d021e8254790852f450bd2b/packages/react-dom/src/client/ReactDOMRoot.js#L102)

### 签名

render 方法的定义如下

```ts
function render(children: ReactNodeList): void {
  // [Not Native Code]
}
```

我们通常将参数称作 app 或者 ui，但源码中称其为 children

children 的类型定义为 [ReactNodeList](https://github.com/facebook/react/blob/80d9a40114bb43c07d021e8254790852f450bd2b/packages/shared/ReactTypes.js#L22)：

```ts
type ReactNodeList = ReactEmpty | React$Node;

// where:
type ReactEmpty = null | void | boolean;

// and
type React$Node =
  | null
  | boolean
  | number
  | string
  | React$Element<any>
  | React$Portal
  | Iterable<React$Node>;

// where
type React$Element<ElementType extends React$ElementType> = {
  ref: any,
  type: ElementType,
  key: React$Key | null,
  props: React$ElementProps<ElementType>,
}
```

这么看来，我们实际上可以给 render 方法传递很多类型的值，例如一个 React Element 或者 React Element 的集合，React 将会递归渲染它们并展示出来

## 实现

render 方法的实现可以被简化为

```js
// simplified
ReactDOMRoot.prototype.render = function render(children: ReactNodeList): void {
    const root = this._internalRoot;
    if (root === null) {
      throw new Error('Cannot update an unmounted root.');
    }
    
    // __DEV__ only checks
    
    updateContainer(children, root, null, null);
}
```

这个方法做了如下动作：

1. 如果 root.internalRoot (即 FiberRootNode) 为空，则报错，这意味着 root.unmount 方法被调用了
2. 开发环境下会做一些校验及警告
   1. 是否传递了 function 类型的参数
   2. 是否将 children 作为第二个参数传入，它会认为你在使用旧版的函数
   3. 是否传递了第二个参数
3. 调用 updateContainer(children, root, null, null) 

## UpdateContainer

[`updateContainer`](https://github.com/facebook/react/blob/80d9a40114bb43c07d021e8254790852f450bd2b/packages/react-reconciler/src/ReactFiberReconciler.js#L318) 是一个在 React 源码中经常使用的一个方法，你可能会疑惑为什么命名为 update 而不是 render 或者 mount？这是因为 React 将不同的行为统一视为更新。React 可以知道树在同一时间下的具体哪个部分被挂载，并且每次都会执行必要的代码。本系列后续文章会详细介绍。

函数签名如下

```ts
export function updateContainer(
  element: ReactNodeList, // children
  container: OpaqueRoot, // OpaqueRoot = FiberRoot = new FiberRootNode
  parentComponent?: React$Component<any, any>,
  callback?: Function,
): Lane {
  // [Not Native Code]
}
```

这个函数在树的第一次挂载和后续的更新中都会被调用

在 root.render 函数中，updateContainer 最后两个参数被传递为 null，这意味着它们没有被使用。后续将会讨论它们

updateContainer的执行步骤如下：

### 1 将 current 变量赋值为 FiberRootNode

传递给此函数的 container 参数并不是之前传给 createRoot 时的 DOM 节点，而是 root._internalRoot，即 FiberRootNode 对象

container.current 属性所储存的 FiberNode，正是当前应用程序当前时间节点下所创建的唯一的 Fiber 节点

React 现在引用了这个 Fiber，因此 current 变量将表示 fiber 或 fiberNode

```js
const current = container.current;
```

### 2 请求一个更新通道

下一步 React 将会为当前 Fiber 请求一个更新通道

```js
const lane = requestUpdateLane(current);
```

为了理解 React 中的 Lanes（通道）的概念，我们首先先要了解按位运算符和数字的二进制表现形式

一个通道就是一个 2 的幂（1,2,4,8,16...），它们的二进制形式只存在唯一一个有效的 1

不同类型的 Lane 在 React 中的定义[如下](https://github.com/facebook/react/blob/fc801116c80b68f7ebdaf66ac77d5f2dcd9e50eb/packages/react-reconciler/src/ReactFiberLane.js#L18)：

```js
// from React's codebase

export const NoLane: Lane = /*                          */ 0b0000000000000000000000000000000;

export const SyncHydrationLane: Lane = /*               */ 0b0000000000000000000000000000001;
export const SyncLane: Lane = /*                        */ 0b0000000000000000000000000000010;

export const InputContinuousHydrationLane: Lane = /*    */ 0b0000000000000000000000000000100;
export const InputContinuousLane: Lane = /*             */ 0b0000000000000000000000000001000;

export const DefaultHydrationLane: Lane = /*            */ 0b0000000000000000000000000010000;
export const DefaultLane: Lane = /*                     */ 0b0000000000000000000000000100000;

export const IdleHydrationLane: Lane = /*               */ 0b0010000000000000000000000000000;
export const IdleLane: Lane = /*                        */ 0b0100000000000000000000000000000;

export const OffscreenLane: Lane = /*                   */ 0b1000000000000000000000000000000;
```

组合不同的通道将产生一个具有很少有效位的新任意整数，使用右边的位掩码，可以将多个通道组合成一个数字（最多 32 中组合形式），这将使得 React 组合和检测功能和行为

在 React 中，组合的 Lane 被称作 Lanes

```
// from React's codebase
export const NoLanes: Lanes = /*                        */ 0b0000000000000000000000000000000;

// Pesonal comment: this should be Lanes ? i don't know
export const SyncUpdateLanes: Lane = /*                */ 0b0000000000000000000000000101010;

const TransitionLanes: Lanes = /*                       */ 0b0000000011111111111111110000000;

```

requestUpdateLane 会根据 fiber.mode 来推断其他变量中的必要更新通道 

