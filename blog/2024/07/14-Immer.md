---
title: Immer
date: 2024-07-14T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [react, immer, hook]
---

React 组件中的 `setState` 更新需要遵循**状态不可变原则**，不允许直接修改 state 的值。对于「深层嵌套」的引用类型例如对象或数组，更新操作变得十分**繁琐**，我们将不得不小心地**浅拷贝每层**受我们更改影响的 state 结构，而且如果不小心直接修改了原始的 state 会违反状态不可变原则并且导致一些 bug

>#### React 为什么坚持状态不可变原则？
>
>1. **简化状态管理和追踪变化:** 当状态不可变时，组件的状态只会在 `setState` 时被更新，这使得追踪状态的变化变得非常容易。开发者可以确信，只要 `setState` 没有被调用，组件的状态就不会改变。反之，如果允许直接修改状态，就很难追踪状态是什么时候、在哪里以及如何被改变的，这会导致难以调试和预测组件的行为。
>2. **提升渲染性能:** React 使用虚拟 DOM 来优化渲染性能，它会比较前后两次状态的差异，只更新实际发生变化的部分。当状态不可变时，React 可以通过简单的引用比较来判断状态是否发生变化，这比深度比较对象或数组的每个属性要高效得多
>3. **提高组件的可预测性和可测试性:** 不可变状态使组件的行为更加可预测，因为组件的状态只会在明确定义的地方发生变化。这使得组件更容易测试，因为开发者可以更容易地控制和预测组件在不同状态下的行为。
>
>#### 与单向数据流的关系？
>
>单向数据流是指，数据在 React 应用中应该以单一方向流动，通常是从父组件传递到子组件。子组件不能直接修改父组件传递给它的数据，而是通过事件或回调函数将修改通知给父组件，由父组件来更新状态，并将新的状态传递给子组件。
>
>- **状态不可变保证了数据流的单向性:** 由于状态不可直接修改，子组件无法直接改变父组件传递给它的数据，只能通过约定的方式通知父组件进行修改。这确保了数据总是从父组件流向子组件，避免了数据双向流动带来的混乱和难以追踪的问题。
>- **单向数据流简化了状态管理:** 由于数据流是单向的，开发者可以清晰地追踪到状态的变化是如何发生的，以及哪些组件会受到影响。这使得应用的状态管理变得更加简单和可预测。

使用 [Immer](https://immerjs.github.io/immer/zh-CN/example-setstate) 可以使这个更新操作**更直观**，代码**更简洁**，**可读性更强**；同时会在内部**创建状态的副本**，确保不会直接修改原始状态，避免了潜在的错误和副作用

使用

```tsx
import React, { useCallback, useState } from "react";
import {produce} from "immer";

const TodoList = () => {
  const [todos, setTodos] = useState([
    {
      id: "React",
      title: "Learn React",
      done: true
    },
    {
      id: "Immer",
      title: "Try Immer",
      done: false
    }
  ]);

  const handleToggle = useCallback((id) => {
    setTodos(
      // produce 会返回一个全新的状态对象
      produce((draft) => {
        const todo = draft.find((todo) => todo.id === id);
        todo.done = !todo.done;
      })
    );
  }, []);

  const handleAdd = useCallback(() => {
    setTodos(
      produce((draft) => {
        draft.push({
          id: "todo_" + Math.random(),
          title: "A new todo",
          done: false
        });
      })
    );
  }, []);

  return (<div>{*/ See CodeSandbox */}</div>)
}
```

