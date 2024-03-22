---
title: useRef（译）
date: 2023-02-08T13:19:00+08:00
tags: ["react", "useRef"]
sidebar-position: 5
authors: gsemir
---

> [useRef • React (reactjs.org)](https://beta.reactjs.org/reference/react/useRef)

`useRef` 是一个 React Hook ，可以让我们引用一个不参与渲染过程的值

```react
const ref = useRef(initialValue)
```

## 介绍

### `useRef(initialValue)`

在组件顶部调用 useRef 来声明一个 ref。

#### 参数

- initialValue：ref 对象 `current` 属性的初始值。可以是任何类型的值。这个参数在初始化渲染后将被忽略。

#### 返回值

`useRef` 返回一个只有一个属性的对象：

- `current`：初始值为传入的 `initialValue`，后续可以随意设置它的值。可以将 ref 对象作为组件的 `ref` 属性传递。

在后续渲染中，`useRef` 将返回相同的对象

#### 注意事项

- 我们可以变更 `ref.current` 属性。不同于 state，它是可变的。如果它包含一个用于渲染的对象（例如 state 的一部分），那么就不应该修改它。
- 当修改 `ref.current` 属性时，React 不会重新渲染组件。由于 ref 是一个普通 JavaScript 对象，React不会注意其变化。
- 不要在渲染过程中（组件函数体）读或写 `ref.current`，可能会导致组件的行为无法预测。建议只在事件处理函数或 effects 中进行 ref 的读或写操作

- 严格模式下，React 将会调用两次组件函数。这意味着每个 ref 对象将被创建两次，其中一个版本将被丢弃。如果您的组件函数时纯函数（应该是），这将不会造成任何影响。

---

## 用法

### 利用ref引用一个值

```react
import { useRef } from 'react'

function App() {
	const someRef = useRef(0)
	// ...
```

`useRef` 返回一个具有 `current` 属性的 ref 对象，并将传入的值作为其初始值。

在下一次渲染时，`useRef` 将会返回相同的对象。

更改 ref 不会出发重新渲染。这意味着 refs 非常适合存储不会影响组件UI的一些信息。通过手动更改 current 属性来更新 ref 的值：

```react
function handleStartClick() {
	const intervalId = setInterval(() => {
		// ...
	}, 1000)
	intervalRef.current = intervalId
}
```

通过使用 ref，可以确保：

- 可以在 re-render 之间存储信息（与普通变量不同，普通变量会在每次渲染时重置）
- 修改 ref 不会触发 re-render，这使得 ref 不适合存储要在屏幕上显示的信息
- 该信息仅存在于组件内部（与外部变量不同，外部变量是共享的）

### 利用ref操作DOM

使用 ref 来操作 DOM 是很常见的，React 对此有内置支持。

首先声明一个初始值为 `null` 的 ref 对象:

```react
import { useRef } from 'react'

function MyComponent() {
	const inputRef = useRef(null)
// ...
```

将 ref 对象作为 JSX 节点的 `ref` 属性传入要操作的 DOM 节点：

```react
// ...
return <input ref={inputRef} />
```

在 React 创建 DOM 节点并将其渲染到页面后，React 会将 ref 对象的 `current` 属性设置为该 DOM 节点，现在我们就可以访问 `<input/>` 的 DOM 节点并调用例如 focus() 这样的方法了：

```react
function handleClick() {
	inputRef.current.focus()
}
```

当该节点在页面中被移除后，React 会将 `current` 属性设置回 `null`

### 避免重复创建ref

React 会在第一次渲染时保存 ref 的初始值，并在后续渲染中忽略它。

```react
function Video() {
  const playerRef = useRef(new VideoPlayer());
  // ...
```

尽管 `new VideoPlayer()` 的返回值只用于第一次渲染，但我们仍会在每次渲染中调用它。这会对性能造成一定影响。

解决方案如下：

```react
function Video() {
  const playerRef = useRef(null);
  if (playerRef.current === null) {
    playerRef.current = new VideoPlayer();
  }
  // ...
```

通常，不推荐在渲染过程中对 `ref.current` 进行读或写。但是，上述情况算是个例外，因为结果总是相同的，并且该条件语句仅在初始化期间执行，即对 `ref.current` 的写操作仅在第一次渲染时执行，后续渲染将不会对 ref 对象造成影响，因此它是完全可预测的。

---

## 常见问题

### 自定义组件不接受ref

如果我们尝试在自定义组件中传入 `ref`，控制台会出现如下报错：

```react
const inputRef = useRef(null);

return <MyInput ref={inputRef} />;

// Warning: Function components cannot be given refs. Attempts to access this ref will fail. Did you mean to use React.forwardRef()?
```

 默认情况下，我们的自定义组件不会向其中的 DOM 节点公开 ref 属性

要解决此问题，请精准地找到内部要获取 ref 的组件

然后使用 `forwardRef` 包裹自定义组件：

```react
import { forwardRef } from 'react';

const MyInput = forwardRef(({ value, onChange }, ref) => {
  return (
    <input
      value={value}
      onChange={onChange}
      ref={ref}
    />
  );
});

export default MyInput;
```

此时自定义组件 MyInput 就能够接收 ref 属性了。