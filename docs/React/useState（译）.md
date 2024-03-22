---
title: useState（译）
date: 2023-02-07T15:19:00+08:00
tags: ["react", "useState"]
sidebar-position: 2
authors: gsemir
---

> [useState • React (reactjs.org)](https://beta.reactjs.org/reference/react/useState)

`useState` 是一个 React Hook，能够让我们在组件中添加 state 变量。

## 介绍

### `useState(initialState)`

在组件顶部调用 `useState` 来声明一个 state 变量

#### 参数

- `initialState`：state初始值，可以是任意类型的值。但如果是函数的话，存在一些特殊行为。初始化渲染后将忽略此参数。
  - 如果把函数作为 initialState，则函数会被视为一个*初始化函数*（initializer function）。这个函数应该是纯函数，不接受参数，并且应该返回任意类型的值。React 将会在初始化渲染时调用这个函数，同时保存其返回值作为 initialState。

#### 返回值

`useState` 返回一个包含两个值的数组：

1. 当前 state 值。在第一次渲染过程中，它会取我们传入的 `initialState`
2. `set` 函数。能够将 state 更新为其他值，并触发重新渲染。

#### 注意事项

- `useState` 是一个 Hook，所以只能在 React 组件顶层或者自定义 Hook 中调用，不可以在循环或者条件语句中调用。如果需要，请抽离出一个新组件来使用。
- 严格模式下该语句会执行两次。如果 initialState 是一个纯函数，其中一个调用结果将被忽略。

---

### `set` 函数, 例如 `setSomething(nextState)`

`set` 函数能够**将 state 更新为其他值，并触发重新渲染**。可以直接传递新的 state 作为 nextState（替换），或者传一个函数，基于旧 state 来计算 nextState：

```react
const [name, setName] = useState('Gsemir')

function handleClick() {
  setName('Sam')
  setAge(a => a + 1)
}
```

#### 参数

- `nextState`：新 state 值。它可以是任何类型的值，但如果是函数的话，存在一些特殊行为。
  - 如果传递的是函数，它会被视为一个*更新器函数*（updater function）。它必须是纯函数，唯一能够接受的参数是当前 state（pending state），并应该返回新 state。React 会把这个更新器函数放入一个队列中，并重新渲染组件，在渲染过程中，React 会执行队列中的更新器，利用旧 state 计算出新 state。**这是一种告诉 React “对状态值做某事”而不仅仅是替换它的方法。**

#### 返回值

无

#### 注意事项

- 如果在 set 方法执行后立即读取 state，只会得到未调用 set 时的旧 state
- 如果 nextState 值与当前 state 相同，则 React 会跳过组件及其子组件的重新渲染过程，这是一种优化手段。
- React 会统一处理 state 的更新行为。React会在全部事件处理函数执行过程中，利用队列记录set函数中指定的行为（替换或者处理），全部执行完毕后，再统一处理state更新，最后渲染页面。

- 严格模式下会执行两次。如果 nextState 是一个纯函数，其中一个调用结果将被忽略。

---

## 用法

### 在组件中添加state

```react
function App() {
	const [name, setName] = useState('react')
}
```

### 基于上一个state更新state

假设 `age` 是 `42`，下面的回调调用了 `setAge(age + 1)` 三次

```react
function handleClick() {
  setAge(age + 1); // setAge(42 + 1)
  setAge(age + 1); // setAge(42 + 1)
  setAge(age + 1); // setAge(42 + 1)
}
```

然而在单击触发后，`age` 变为了 `43` 而不是 `45`，这是因为**调用 `set` 函数不会立即更新 state**，即每次的 `setAge(age + 1)` 都变成了 `setAge(43)`

为了解决这个问题，可以传入*更新器函数*而不是直接传入新 state：

```react
function handleClick() {
  setAge(a => a + 1); // setAge(42 => 43)
  setAge(a => a + 1); // setAge(43 => 44)
  setAge(a => a + 1); // setAge(44 => 45)
}
```

React会将传入的更新器函数放入一个队列，然后在下次渲染过程中，它会按传入顺序进行调用：

1. `a => a + 1` 会接收 `42` 作为 `pending state` （可以暂时理解为当前 state），返回 `43` 作为nextState 
2. `a => a + 1` 会接收 `43`  作为 `pending state` （可以暂时理解为当前 state），返回 `44` 作为nextState 
3. `a => a + 1` 会接收 `44` 作为 `pending state` （可以暂时理解为当前 state），返回 `45` 作为nextState 

清空更新器队列后，React 最终会保存 45 作为当前 state

更新器函数中的参数，一般用 state 的第一个字母小写来指代，也可以使用更加语义化的表达：`prevXxx`

### 更新state的对象和数组

state 的类型可以是对象或数组。在 React 中，state 是只读的，所以我们应该整个替换它而不是之前改变当前对象。在写代码时勤用展开运算符。

### 避免重复初始化state

直接将函数作为初始化函数传入，而不是函数调用：

```react
function init() { return 1 }
// X 
const [state, setState] = useState(init())
// Y
const [state, setState] = useState(init)
```

虽然 init 函数的返回值仅用于初始化渲染，但每次渲染 init 函数仍会被调用，从而对性能产生影响。

### 使用key重置state

可以通过改变组件的key来重置组件的state

下面的例子包含一个Reset Button以及一个Form表单组件，重置按钮会改变Form组件的key，React则会从头开始重新创建组件（及其子组件），因此Form组件的state也被重置了。

```react
import { useState } from 'react';

export default function App() {
  const [version, setVersion] = useState(0);

  function handleReset() {
    setVersion(version + 1);
  }

  return (
    <>
      <button onClick={handleReset}>Reset</button>
      <Form key={version} />
    </>
  );
}

function Form() {
  const [name, setName] = useState('Taylor');

  return (
    <>
      <input
        value={name}
        onChange={e => setName(e.target.value)}
      />
      <p>Hello, {name}.</p>
    </>
  );
}
```

---

## 常见问题

### 我更新了state，但控制台打印的却是旧数据

调用 `set` 函数无法立即改变 state:

```react
function handleClick() {
  console.log(count);  // 0

  setCount(count + 1); // Request a re-render with 1
  console.log(count);  // Still 0!

  setTimeout(() => {
    console.log(count); // Also 0!
  }, 5000);
}
```

这是因为 state 的行为类似于**快照**。更新 state 会请求一次基于新 state 的 render，但不会影响已经运行的事件处理程序中的 Javascript 变量 `count`

> Re-render:
>
> 1. React 再次执行组件函数
> 2. 计算新的state，并基于新state生成快照
> 3. 根据快照更新DOM
> 4. 每次渲染都会生成自己的事件处理函数与变量

如果需要立即获取更新后的state值，可以借助其他变量来实现：

```react
const nextCount = count + 1;
setCount(nextCount);

console.log(count);     // 0
console.log(nextCount); // 1
```

---

### 我更新了state，但页面没有更新

如果新 state 与旧 state 相同，React 会忽略这次更新，具体是由 `object.is` 来做对比。当直接更改状态中的对象或数组时，通常会发生这种情况：

```react
obj.x = 10;  // Wrong: mutating existing object
setObj(obj); // Doesn't do anything
```

要解决此问题，需要确保始终**替换**state中的对象或数组，而不是更改它们：

```react
// Correct: creating a new object
setObj({
  ...obj,
  x: 10
});
```

> 补充：Object.is
>
> 1. `Object.is()` 与 `==` 不同。`==` 运算符在判断相等前对两边的变量（如果它们不是同一类型）进行**强制转换**（这种行为将 `"" == false` 判断为 `true`），而 `Object.is` 不会强制转换两边的值。
> 2. `Object.is()` 与 `===` 也不相同。差别是它们对待**有符号的零**和 **NaN** 不同，例如，`===` 运算符（也包括 `==` 运算符）将数字 `-0` 和 `+0` 视为相等，而将 `Number.NaN` 与 `NaN` 视为不相等。

---

### 报错：“Too many re-renders”

我们可能得到如下报错：`Too many re-renders. React limits the number of renders to prevent an infinite loop.`，通常，这意味着我们在渲染期间重复调用set函数，因此组件进入循环：渲染、设置状态（导致渲染）、渲染等。通常这是由声明事件处理函数时的错误导致的:

```react
// Wrong: calls the handler during render
return <button onClick={handleClick()}>Click me</button>

// Correct: passes down the event handler
return <button onClick={handleClick}>Click me</button>

// Correct: passes down an inline function
return <button onClick={(e) => handleClick(e)}>Click me</button>
```

---

### 我的初始化或更新函数运行了两次

在严格模式下，React 会对组件函数，包括 initializer 以及 updater function 调用两次而非一次（两次结果应该一致），从而帮助我们确保以上函数为**纯函数**。

> 纯函数：
>
> 1. 只操作自己内部的变量
> 2. 相同输入，相同输出
>
> React 就是围绕这个概念设计的。React 假设我们编写的每个组件都是一个纯函数，这意味着当我们给定相同的输入时，组件始终都会返回相同的 JSX。

> 副作用：
>
> 更新DOM、http请求等称为副作用，因为它们不是在渲染过程中发生的事。
>
> 副作用往往存在于事件处理函数中，但因为事件处理函数不会在渲染时执行，所以事件处理函数可以不是纯函数。

---

### 我尝试将state设置为一个函数，但它却被调用了

错误的方式：

```react
const [fn, setFn] = useState(someFunction);

function handleClick() {
  setFn(someOtherFunction);
}
```

这是因为 `React` 会将 `someFunction` 视为 initializer function，将 `someOtherFunction` 视为一个 updater function，所以 React 会尝试调用它们以存储其返回值。如果需要将函数设置为 state，那么需要在这两个函数前添加 `() =>` ，React 会将函数视为变量值来储存:

```react
const [fn, setFn] = useState(() => someFunction);

function handleClick() {
  setFn(() => someOtherFunction);
}
```

