---
title: 封装 Message 组件
date: 2024-04-30T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [react, message, class]
---

封装一个 Message 组件，用于全局展示操作反馈信息。可提供成功、警告和错误等反馈信息。顶部居中显示并自动消失，是一种不打断用户操作的轻量级提示方式。

#### 组件基本实现

支持传入类型与内容

```tsx
export interface MessageProps {
  type?: 'success' | 'error' | 'warning' | 'info'
  content: string
}
```

Message 支持多条展示，所以还需准备 MessageList 组件作为 Message 组件的容器

```tsx
export const MessageList: React.FC<{ messages: MessageProps[] }> = ({ messages }) => {
  return (
    <div className="message-list">
      {messages.map((message) => (
        <Message key={message.id} {...message} />
      ))}
    </div>
  )
}
```

其中 Message 组件类名使用模板字符串，根据 `type` 进行类名拼接即可

```tsx
import React from 'react'
import './message.css'

export const Message: React.FC<MessageProps> = ({
  type='success',
  content,
}) => {
  return (
    <p className={`message message-${type}`}>
      {content}
    </p>
  )
}
```

部分样式如下

```css
.message-list {
  position: fixed;
  z-index: 1000;
  left: 50%;
  transform: translateX(-50%);
  top: 16px;
}

.message {
  padding: 12px;
  border-radius: 6px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.message-success {
  background-color: #d4edda;
  border-color: #c3e6cb;
  color: #155724;
}
```

#### 组件渲染在哪？

Message 组件在实际使用中，通常不会直接显式声明在 JSX 中，而是通过一些 api 函数来渲染组件。例如 `message.success('Success')`、`message.error('Error')`，随用随调

这样就需要 root.render 方法来动态渲染组件，准备一个额外的用于挂载 MessageList 组件的容器

```ts
const CONTAINER_ID = "message-container";

export function createContainer() {
  let container = document.getElementById(CONTAINER_ID)
  if (!container) {
    container = document.createElement("div")
    container.setAttribute("id", CONTAINER_ID)
    document.body.appendChild(container)
  }

  return container
}
```

然后使用 `React.createRoot(container)` 创建 container 元素的 `root` 节点，然后调用 `root.render` 方法动态地将 MessageList 组件挂载到页面上

```js
import { createRoot } from "react-dom/client";

function renderMessage(messages) {
  // 获取容器
  const container = createContainer()
  // 创建 root 节点
  const containerRoot = createRoot(container)
  // root.render 渲染 Message 组件
  containerRoot.render(<MessageList messages={messages} />)
}
```

这样一来，当我们传入 message 数据调用 `renderMessage` 方法后，就初步实现了 MessageList 组件的渲染

#### 组件如何支持 api 调用？

使用*面向对象*的方式来组织代码，渲染 api 则由 Message 的实例方法来实现

同时我们将 `createContainer` 方法整合到 Message 的构造器中

将 `renderMessage` 方法作为 Message 的私有方法 `render`

维护 `messages` 数据与 `containerRoot` 节点

最后使用*单例模式*确保全局唯一实例

```tsx
class Message {
  static instance: Message
  #containerRoot: Root
  #messages: Array<InternalMessageProps> = []

  constructor() {
    let container = document.getElementById(CONTAINER_ID)
    if (!container) {
      container = document.createElement("div")
      container.setAttribute("id", CONTAINER_ID)
      document.body.appendChild(container)
      this.#containerRoot = createRoot(container)
    } else {
      this.#containerRoot = createRoot(container)
    }
  }

  #render() {
    this.#containerRoot.render(<MessageList messages={this.#messages} />)
  }

  success(content: string) {}

  error(content: string) {}

  info(content: string) {}

  warning(content: string) {}

  static getInstance() {
    if (!Message.instance) {
      Message.instance = new Message();
    }
    return Message.instance;
  }
}

export const message = Message.getInstance()
```

#### 如何实现组件显隐？

显示与隐藏本质上就是对 Message 类的 `messages` 数据进行新增与删除操作，然后使用新的 messages 重新渲染 MessageList 组件即可

##### 显示

当我们调用 `message.success` 时，首先需要在 messages 中新增这条数据，然后调用 render 方法使用新数据重新渲染 MessageList 组件即可

这里我们将逻辑抽离为 `addMessage` 私有方法

```tsx
class Message {
  // ...
  #addMessage(message: MessageProps) {
    this.#messages.push(message)
    this.#render()
  }

  success(content: string) {
    this.#addMessage({ type: 'success', content })
  }

  error(content: string) {
    this.#addMessage({ type: 'error', content })
  }

  info(content: string) {
    this.#addMessage({ type: 'info', content })
  }

  warning(content: string) {
    this.#addMessage({ type: 'warning', content })
  }
}
```

##### 隐藏

Message 消失实际上就是在 messages 数据中移除这条数据，然后再重新渲染 MessageList 组件即可

移除数据需要唯一标识与回调函数，这里我们扩展 MessageProps 的 Type，并新增 `InternalMessageProps` 类型

```ts
export interface MessageProps {
  type?: 'success' | 'error' | 'warning' | 'info'
  content: string
  onClose?: () => void
}

export interface InternalMessageProps extends MessageProps {
  id: number
}
```

Message 组件接收 `onClose` 回调，内部使用 `useEffect` 设置定时器，在 2s 后调用 onClose

```tsx
const Message: React.FC<MessageProps> = ({
  type = 'success',
  content,
  onClose,
}) => {
  useEffect(() => {
    const timer = setTimeout(() => {
      onClose?.()
    }, 2000)
    
    return () => {
      clearTimeout(timer)
    }
  }, [onClose])
// ...
}
```

我们在 Message 类新增 `messageCount` 私有属性作为 message 数据的唯一标识，抽离移除逻辑作为私有方法 `removeMessage`。在新增时将 id 与 onClose 回调也一同保存

```tsx
class Message {
  static instance: Message
  #containerRoot: Root
  #messages: Array<InternalMessageProps> = []
  #messageCount: number = 0

  #render() {
    this.#containerRoot.render(<MessageList messages={this.#messages} />)
  }

  #addMessage(message: MessageProps) {
    const id = ++this.#messageCount
    this.#messages.push({ id, onClose: () => this.#removeMessage(id), ...message })
    this.#render()
  }

  #removeMessage(id: number) {
    this.#messages = this.#messages.filter(message => message.id !== id)
    this.#render()
  }
	// ...
}
```

以上，我们就实现了一个 Message 组件的基本功能

完整代码

```tsx
// core.tsx
import { Root, createRoot } from "react-dom/client";
import { InternalMessageProps, MessageList, MessageProps } from "./Message";

const CONTAINER_ID = 'message-container'

class Message {
  static instance: Message
  #containerRoot: Root
  #messages: Array<InternalMessageProps> = []
  #messageCount: number = 0

  constructor() {
    let container = document.getElementById(CONTAINER_ID)
    if (!container) {
      container = document.createElement("div")
      container.setAttribute("id", CONTAINER_ID)
      document.body.appendChild(container)
      this.#containerRoot = createRoot(container)
    } else {
      this.#containerRoot = createRoot(container)
    }
  }

  #render() {
    this.#containerRoot.render(<MessageList messages={this.#messages} />)
  }

  #addMessage(message: MessageProps) {
    const id = ++this.#messageCount
    this.#messages.push({ id, onClose: () => this.#removeMessage(id), ...message })
    this.#render()
  }

  #removeMessage(id: number) {
    this.#messages = this.#messages.filter(message => message.id !== id)
    this.#render()
  }

  success(content: string) {
    this.#addMessage({ type: 'success', content })
  }

  error(content: string) {
    this.#addMessage({ type: 'error', content })
  }

  info(content: string) {
    this.#addMessage({ type: 'info', content })
  }

  warning(content: string) {
    this.#addMessage({ type: 'warning', content })
  }

  static getInstance() {
    if (!Message.instance) {
      Message.instance = new Message();
    }
    return Message.instance;
  }
}

export const message = Message.getInstance()
```

```tsx
// Message.tsx
import React, { useEffect } from 'react'
import './message.css'

export interface MessageProps {
  type?: 'success' | 'error' | 'warning' | 'info'
  content: string
  onClose?: () => void
}

export interface InternalMessageProps extends MessageProps {
  id: number
}

const Message: React.FC<MessageProps> = ({
  type = 'success',
  content,
  onClose,
}) => {
  useEffect(() => {
    const timer = setTimeout(() => {
      onClose?.()
    }, 2000)
    
    return () => {
      clearTimeout(timer)
    }
  }, [onClose])

  return (
    <p className={`message message-${type}`}>
      {content}
    </p>
  )
}

export const MessageList: React.FC<{ messages: InternalMessageProps[] }> = ({ messages }) => {
  return (
    <div className="message-list">
      {messages.map((message) => (
        <Message key={message.id} {...message} />
      ))}
    </div>
  )
}
```

```css
/* message.css */
.message-list {
  position: fixed;
  z-index: 1000;
  left: 50%;
  transform: translateX(-50%);
  top: 16px;
}

.message {
  padding: 12px;
  border-radius: 6px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.message-success {
  background-color: #d4edda;
  border-color: #c3e6cb;
  color: #155724;
}

.message-error {
  background-color: #f8d7da;
  border-color: #f5c6cb;
  color: #721c24;
}

.message-warning {
  background-color: #fff3cd;
  border-color: #ffeeba;
  color: #856404;
}

.message-info {
  background-color: #bee5eb;
  border-color: #81c784;
  color: #0c5460;
}
```

