---
title: 受控组件的bug
date: 2024-06-18T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [react, input, form]
---

记录一下表单组件开发过程中的一个 bug

> 需求：表单有两项，一个是 radio，一个是 input。要求实现一个基本的**联动**功能，即 radio 改变后，input 中的数据要清空（重置）

> 省流：保证组件的状态始终是受控或非受控的。如果受控，一定要指定一个初始值而不是 undefined

#### 初步方案

```tsx
export const NewItemPage: React.FC<Props> = () => {
	// 使用 formData state 保存表单数据，包括一个 tag 对象和一个 kind 属性
  const [formData, setFormData] = useState<{
    kind: 'expense' | 'income'
    tag: Tag | null
  }>({
    kind: 'expense',
    tag: null,
  })

  const handleChange = (e: ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target
    setFormData(prev => ({
      ...prev,
      [name]: value,
      // 利用三元运算符判断重置 tag 数据的逻辑
      tag: name === 'kind' ? null : prev.tag,
    }))
  }

  const handleTagSelect = (tag: Tag) => {
    setTagPickerVisible(false)
    setFormData(prev => ({
      ...prev,
      tag,
    }))
  }

  return (
    <div className="h-full flex flex-col items-center mr-4 ml-4">
      <Radio
        // radio 绑定的数据是 formData.kind
        props={[
          {
            name: 'kind',
            value: 'income',
            checked: formData.kind === 'income',
            label: '收入',
            onChange: handleChange,
          },
          {
            name: 'kind',
            value: 'expense',
            checked: formData.kind === 'expense',
            label: '支出',
            onChange: handleChange,
          },
        ]}
      />
      <Input
        label="标签"
        name="tagName"
        // input 绑定的 value 数据为 tag 对象的 name 属性，即 `formData.tag.name`
        value={formData.tag?.name}
      />   
    </div>
  )
}
```

然而当我们改变 radio 的选项，即修改 kind 字段的值时，**tag 对象已经被置为 null**，但是 input 输入框的值却**仍然是上一次的 tag.name 的值**

同时控制台报错：

```
Warning: A component is changing an uncontrolled input to be controlled. This is likely caused by the value changing from undefined to a defined value, which should not happen. Decide between using a controlled or uncontrolled input element for the lifetime of the component. 
```

造成报错以及预期之外的渲染情况，问题发生是当一个组件从未受控状态变为受控状态，或从受控状态变为未受控状态

在 React 中，对于输入组件（如`<input>`、`<textarea>`和`<select>`），有两种方式来管理状态：**受控组件**和**非受控组件**

#### 受控组件

受控组件是 React 通过 `state` 和设置组件的 `value` 属性来管理的。这意味着组件的值始终由 React 的状态（`state`）决定。每次组件的值发生变化时，都会触发一个事件处理器（如`onChange`），该处理器更新相应的状态。由于 React 的状态更新，组件重新渲染，显示新的值。这样的话，**React 的状态就成为了组件值的唯一“真理来源”**。 例如，一个受控输入框可以这样实现：

```jsx
import React, { useState } from 'react';

function ControlledInput() {
  const [value, setValue] = useState('');

  function handleChange(event) {
    setValue(event.target.value);
  }

  return <input type="text" value={value} onChange={handleChange} />;
}
```

在上面的例子中，输入框的值被 React 的 `state` 控制。每次输入数据时，`onChange` 事件被触发，调用 `handleChange` 函数，更新 `state`。随后，组件根据新的 `state` 重新渲染，输入框显示最新的值。

#### 非受控组件

与受控组件相对，非受控组件**由 DOM 自己管理状态**。这通常通过使用 `ref` 来直接从DOM节点获取值实现，而不是通过每次的输入事件同步更新 React 的状态（`state`）。在非受控组件中，React 并不负责数据的更新和渲染——这一切都交给了 DOM 自己管理。

```jsx
import React, { useRef } from 'react';

function UncontrolledInput() {
  const inputRef = useRef();

  function handleSubmit(event) {
    alert('A name was submitted: ' + inputRef.current.value);
    event.preventDefault();
  }

  return (
    <form onSubmit={handleSubmit}>
      <input type="text" ref={inputRef} />
      <button type="submit">Submit</button>
    </form>
  );
}
```

在上面的示例中，我们没有使用 `state` 来控制输入框的值。相反，我们使用 `useRef` hook 来获得对输入框 DOM 元素的引用，当表单提交时，通过 `inputRef.current.value` 直接获取当前输入框的值。

#### 解决问题

问题发生是当一个组件从未受控状态变为受控状态，或从受控状态变为未受控状态。

当 React 在组件初次渲染时没有 `value` 属性（或值为 `undefined`），然后在稍后的更新中接收到了一个具体的 `value`，就会出现这种情况；同样的，如果一个组件最初有一个确切的 `value`，之后变为了 `undefined` 或没有`value`，也会出现相反的警告。

解决这个问题的关键是**确保输入组件要么始终是非受控的**（即，不设置`value`属性或设置为`undefined`），**要么始终是受控的**（始终给`value`设置一个有效的值，包括空字符串`''`作为初始化值）。

所以上面的代码可以进行如下改动：给定 `input` 的 `value` 属性一个**默认初始值**而不是 `undefined`，确保组件永远是受控的

```diff
  <Input
    label="标签"
    name="tagName"
-   value={formData.tag?.name}
+   value={formData.tag?.name ?? ''}
  />  
```