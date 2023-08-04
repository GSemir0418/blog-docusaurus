---
title: useEffect（译）
date: 2023-02-08T15:19:00+08:00
tags: ["react", "useEffect"]
sidebar-position: 2
authors: gsemir
---

`useEffect` 是一个React Hook，可以使组件与外部系统同步。

```react
useEffect(setup, dependencies?)
```

## 介绍

### `useEffect(setup, dependencies?)`

在组件函数体顶部调用 `useEffect` 以声明一个 Effect：

```react
import { useEffect } from 'react';
import { createConnection } from './chat.js';

function ChatRoom({ roomId }) {
  const [serverUrl, setServerUrl] = useState('https://localhost:1234');

  useEffect(() => {
    const connection = createConnection(serverUrl, roomId);
    connection.connect();
    return () => {
      connection.disconnect();
    };
  }, [serverUrl, roomId]);
  // ...
}
```

#### 参数

- `setup`：包含 Effect 逻辑的函数。同时支持返回一个cleanup函数。当组件第一次挂载到页面时，React 会执行 setup 函数。在每次使用更改的依赖项进行 re-render 后，React 会先石油旧值运行 cleanup 函数，然后再使用新值运行 setup 函数。当组件在DOM中卸载后，React 会最后执行一次 cleanup 函数。
- 可选 `dependencies`： `setup` 函数中引用到的动态值的列表。动态值包括 props、state 以及在组件函数体中直接声明的任意变量或函数。React 利用 `object.is` 比较每个依赖值的改变。如果不写此参数，Effect 逻辑会随着组件的 re-render 而重复执行。

#### 返回值

`useEffect` 返回 `undefined`

#### 注意事项

- `useEffect` 只能在组件函数体顶部或自定义 Hook 中调用。不能在条件语句或循环语句中使用。
- 如果不需要与组件外部系统同步，大概率也不需要 Effect
- 严格模式下，React 将在正式 setup 之前额外执行一次 setup + cleanup，这能确保 cleanup  逻辑“镜像” setup 逻辑，能够停止或撤销 setup 所做的任何操作。
- 如果某些依赖项是在组件中定义的对象或函数，可能会导致 Effect 重新运行的频率超出预期，可以通过移除不必要的对象依赖或函数依赖来解决此问题。
- 如果Effect不是由交互（例如单击）引起的，React 会让浏览器在 Effect 执行前绘制页面。如果 Effect 逻辑与视觉操作相关（例如对 tooltip 进行定位），而且会产生很明显的延迟（闪烁），那么建议将 `useEffect` 替换为 `useLayoutEffect`。



## 用法

### 连接外部系统

当组件挂载到页面中时，可能需要保持与网络、某些浏览器API或第三方库的连接，这样不受 React 控制的系统被称作*外部系统*，例如：

- 使用`setInterval()` 和 `clearInterval()` 管理的计时器
- 使用 `window.addEventListener()` 和 `window.removeEventListener()`
- 具有类似 API 的第三方动画库 `animation.start()` 和 `animation.reset()`

```react
// 示例代码同上
```

React 会在必要时调用 setup 与 cleanup 函数，具体调用顺序如下：

1. 组件挂载时会运行 setup 
2. 在每次渲染组件后，依赖项发生变更：
   1. 首先，会利用旧的 props 和 state 运行 cleanup code
   2. 接着，会利用新的 props 和 state 运行 setup code
3. 当组件在页面中卸载后，cleanup code会最终执行一次

尝试将每个 Effect 编写为一个独立的进程，并且一次只考虑一个 set/clean 周期。

#### 示例1 监听全局浏览器事件

Effect 可以使我们访问window对象并监听其事件。下面的示例实现了对鼠标位置的监听并实时更新红点的位置：

```react
import { useState, useEffect } from 'react';

export default function App() {
  const [position, setPosition] = useState({ x: 0, y: 0 });

  useEffect(() => {
    function handleMove(e) {
      setPosition({ x: e.clientX, y: e.clientY });
    }
    window.addEventListener('pointermove', handleMove);
    return () => {
      window.removeEventListener('pointermove', handleMove);
    };
  }, []);

  return (
    <div style={{
      position: 'absolute',
      backgroundColor: 'pink',
      borderRadius: '50%',
      opacity: 0.6,
      transform: `translate(${position.x}px, ${position.y}px)`,
      pointerEvents: 'none',
      left: -20,
      top: -20,
      width: 40,
      height: 40,
    }} />
  );
}

```

#### 示例2 控制弹窗的显隐

下面的示例中，`ModalDialog` 组件渲染了一个 `<dialog>` 元素，应用 Effect 将 `isOpen` 属性与 `showModal()` 和 `close()` 方法的调用。

```react
import { useEffect, useRef } from 'react';

export default function ModalDialog({ isOpen, children }) {
  const ref = useRef();

  useEffect(() => {
    if (!isOpen) {
      return;
    }
    const dialog = ref.current;
    dialog.showModal();
    return () => {
      dialog.close();
    };
  }, [isOpen]);

  return <dialog ref={ref}>{children}</dialog>;
}
```

#### 示例3 追踪元素可见性

在此示例中，外部系统是浏览器 DOM 。`App` 组件渲染了一个长列表，列表中穿插了一个 `Box` 组件。当页面滚动至 `Box` 组件时，即 `Box` 组件出现在视口时，使用 Effect 控制 `IntersectionObserver`，这个浏览器 API 可以帮助我们判断元素是否出现在视口:

```react
import { useRef, useEffect } from 'react';

export default function Box() {
  const ref = useRef(null);

  useEffect(() => {
    const div = ref.current;
    const observer = new IntersectionObserver(entries => {
      const entry = entries[0];
      if (entry.isIntersecting) {
        document.body.style.backgroundColor = 'black';
        document.body.style.color = 'white';
      } else {
        document.body.style.backgroundColor = 'white';
        document.body.style.color = 'black';
      }
    });
    observer.observe(div, {
      // 阈值为 1.0 意味着目标元素完全出现在 root 选项指定的元素中可见时，回调函数将会被执行。
      threshold: 1.0
    });
    return () => {
      observer.disconnect();
    }
  }, []);

  return (
    <div ref={ref} style={{
      margin: 20,
      height: 100,
      width: 100,
      border: '2px solid black',
      backgroundColor: 'blue'
    }} />
  );
}
```



> #### 补充：IntersectionObserver API
>
> [Intersection Observer API - Web API 接口参考 | MDN (mozilla.org)](https://developer.mozilla.org/zh-CN/docs/Web/API/Intersection_Observer_API)
>
> Intersection Observer API 提供了一种异步检测目标元素与祖先元素或 [viewport](https://developer.mozilla.org/zh-CN/docs/Glossary/Viewport) 相交情况变化的方法。下面这些情况都需要用到相交检测：
>
> - 图片懒加载——当图片滚动到可见时才进行加载
> - 内容无限滚动——也就是用户滚动到接近内容底部时直接加载更多，而无需用户操作翻页，给用户一种网页可以无限滚动的错觉
> - 检测广告的曝光情况——为了计算广告收益，需要知道广告元素的曝光情况
> - 在用户看见某个区域时执行任务或播放动画



### 使用 useEffect 包裹自定义 Hook 逻辑

Effect 是一个“逃生舱口”：当我们要“逃离 React ”时，以及当我们的需求没有更好的内置解决方案时，我们将会使用 Effect 。但如果频繁编写一段 Effect 逻辑，就会出现代码冗余，那么我们需要将组件所依赖的常见行为提取为自定义 Hook。

以最上面的聊天室需求为例，下面的 `useChatRoom` Hook 封装了 Effect 中的逻辑：

```react
function useChatRoom({ serverUrl, roomId }) {
  useEffect(() => {
    const options = {
      serverUrl: serverUrl,
      roomId: roomId
    };
    const connection = createConnection(options);
    connection.connect();
    return () => connection.disconnect();
  }, [roomId, serverUrl]);
}
```

在组件中使用：

```react
function ChatRoom({ roomId }) {
  const [serverUrl, setServerUrl] = useState('https://localhost:1234');

  useChatRoom({
    roomId: roomId,
    serverUrl: serverUrl
  });
  // ...
```

#### 示例1 useWindowListener Hook

将上面示例1中的逻辑提取为自定义 Hook：

```react
import { useState, useEffect } from 'react';

export function useWindowListener(eventType, listener) {
  useEffect(() => {
    window.addEventListener(eventType, listener);
    return () => {
      window.removeEventListener(eventType, listener);
    };
  }, [eventType, listener]);
}

// App
import { useState } from 'react';
import { useWindowListener } from './useWindowListener.js';

export default function App() {
  const [position, setPosition] = useState({ x: 0, y: 0 });

  useWindowListener('pointermove', (e) => {
    setPosition({ x: e.clientX, y: e.clientY });
  });

  return (
    <div style={{
      position: 'absolute',
      backgroundColor: 'pink',
      borderRadius: '50%',
      opacity: 0.6,
      transform: `translate(${position.x}px, ${position.y}px)`,
      pointerEvents: 'none',
      left: -20,
      top: -20,
      width: 40,
      height: 40,
    }} />
  );
}
```

#### 示例2 useIntersectionObserver Hook

将上面的示例3中的 Effect 逻辑抽离为一个自定义 Hook：

```react
import { useState, useEffect } from 'react';

export function useIntersectionObserver(ref) {
  const [isIntersecting, setIsIntersecting] = useState(false);

  useEffect(() => {
    const div = ref.current;
    const observer = new IntersectionObserver(entries => {
      const entry = entries[0];
      setIsIntersecting(entry.isIntersecting);
    });
    observer.observe(div, {
      threshold: 1.0
    });
    return () => {
      observer.disconnect();
    }
  }, [ref]);

  return isIntersecting;
}

// Box
import { useRef, useEffect } from 'react';
import { useIntersectionObserver } from './useIntersectionObserver.js';

export default function Box() {
  const ref = useRef(null);
  const isIntersecting = useIntersectionObserver(ref);

  useEffect(() => {
   if (isIntersecting) {
      document.body.style.backgroundColor = 'black';
      document.body.style.color = 'white';
    } else {
      document.body.style.backgroundColor = 'white';
      document.body.style.color = 'black';
    }
  }, [isIntersecting]);

  return (
    <div ref={ref} style={{
      margin: 20,
      height: 100,
      width: 100,
      border: '2px solid black',
      backgroundColor: 'blue'
    }} />
  );
}
```



### 控制非React的小部件

可以在 Effect 中调用第三方库的API，使其状态与 React 组件当前的 state 匹配。



### 请求数据

可以使用 Effect 获取组件的数据：

```react
import { useState, useEffect } from 'react';
import { fetchBio } from './api.js';

export default function Page() {
  const [person, setPerson] = useState('Alice');
  const [bio, setBio] = useState(null);
  useEffect(() => {
    let ignore = false;
    setBio(null);
    fetchBio(person).then(result => {
      if (ignore) return 
      setBio(result);
    });
    return () => {
      ignore = true;
    }
  }, [person]);

  return (
    <>
      <select value={person} onChange={e => {
        setPerson(e.target.value);
      }}>
        <option value="Alice">Alice</option>
        <option value="Bob">Bob</option>
        <option value="Taylor">Taylor</option>
      </select>
      <hr />
      <p><i>{bio ?? 'Loading...'}</i></p>
    </>
  );
}

```

注意要将 `ignore` 在 cleanup 期间设置为 `false`，即当 person state 变更后，第一时间会运行 `cleanup` 方法，重置 `ignore` 为 `true`，这意味着忽略这次数据请求。有 `ignore` 变量与 cleanup 逻辑的存在，可以避免多次请求的响应顺序不确定所导致的一些问题。

通过 Effect 手动获取数据也存在一些缺陷：

- Effects 逻辑不会在服务端运行。
- 组件渲染并挂载后才会运行 Effects 从而发起请求，这对于嵌套组件来说，会造成“网络瀑布“的现象。如果网络环境不是很好的话，与统一并行请求全部数据相比要慢得多。
- 在 Effects 中直接请求数据意味着不会对数据进行预加载或缓存的操作。例如组件卸载后再挂载，那么就又会进行一次数据请求。
- 对于上述提到的多次响应的顺序不确定问题，虽然使用 ignore 变量解决了，但我们之后也会经常写这样的模版代码。这不够人性化。

推荐使用 React Query、useSWR 等开源解决方案



### 指定动态依赖项

在使用过程中，要注意我们没有权利“选择” Effect 中的依赖项。在 Effect 逻辑中任何动态变量（props、state 或其他直接声明在组件函数体中的变量）都必须作为其依赖项。

如果一定要移除某个依赖项，我们需要去想办法“证明”它不需要作为一个依赖。还是以 chatRoom 需求为例：

```react
const serverUrl = 'https://localhost:1234'; // Not a reactive value anymore

function ChatRoom({ roomId }) {
  useEffect(() => {
    const connection = createConnection(serverUrl, roomId);
    connection.connect();
    return () => connection.disconnect();
  }, [roomId]); // All dependencies declared
  // ...
}
```

如果 Effects 中不存在任何动态变量，那么依赖项必须指定为 `[]`。如果不传递这个参数，那么 Effect 会在组件每次 re-render 时执行。



### 在 Effect 中 setState

以“每过一秒就加1“的需求为例，当 count 更新后，Effect 将重新执行，这就会导致计时器被重置：

```react
function Counter() {
  const [count, setCount] = useState(0);

  useEffect(() => {
    const intervalId = setInterval(() => {
      setCount(count + 1); // You want to increment the counter every second...
    }, 1000)
    return () => clearInterval(intervalId);
  }, [count]); // 🚩 ... but specifying `count` as a dependency always resets the interval.
  // ...
}
```

由于 `count` 是动态变量，必须要添加到 Effect 的依赖项中，但是会导致计时器每次都会重新执行。要解决此问题，只能从 updater function 方面入手：

```react
import { useState, useEffect } from 'react';

export default function Counter() {
  const [count, setCount] = useState(0);

  useEffect(() => {
    const intervalId = setInterval(() => {
      setCount(c => c + 1); // Pass a state updater
    }, 1000);
    return () => clearInterval(intervalId);
  }, []); // Now count is not a dependency

  return <h1>{count}</h1>;
}
```

我们在 updater 中传入 `c => c + 1` 而不是 `count + 1`，那么 Effect 就不再需要依赖 `count`，同时其内部的 cleanup 和 setup 在 count 更新时也不会再执行了。



### 移除不必要的对象或函数的依赖

还是以聊天室的需求为例，我们将 serverUrl 和 roomId 抽离成 `options` 对象并将其作为 Effect 的依赖。当我们输入消息，就会触发 setMessage ，`options` 由于声明在组件函数体中，会在 re-render 时重置，从而引发 Effect 重新执行，导致程序重新与聊天室建立连接：

```react
const serverUrl = 'https://localhost:1234';

function ChatRoom({ roomId }) {
  const [message, setMessage] = useState('');

  const options = { // This object is created from scratch on every re-render
    serverUrl: serverUrl,
    roomId: roomId
  };

  useEffect(() => {
    const connection = createConnection(options); // It's used inside the Effect
    connection.connect();
    return () => connection.disconnect();
  }, [options]); // As a result, these dependencies are always different on a re-render
  // ...
```

解决方法很简单，将 `options` 对象的声明移入 Effect 逻辑中即可：

```react
import { useState, useEffect } from 'react';
import { createConnection } from './chat.js';

const serverUrl = 'https://localhost:1234';

function ChatRoom({ roomId }) {
  const [message, setMessage] = useState('');

  useEffect(() => {
    const options = {
      serverUrl: serverUrl,
      roomId: roomId
    };
    const connection = createConnection(options);
    connection.connect();
    return () => connection.disconnect();
  }, [roomId]);

  return (
    <>
      <h1>Welcome to the {roomId} room!</h1>
      <input value={message} onChange={e => setMessage(e.target.value)} />
    </>
  );
}

export default function App() {
  const [roomId, setRoomId] = useState('general');
  return (
    <>
      <label>
        Choose the chat room:{' '}
        <select
          value={roomId}
          onChange={e => setRoomId(e.target.value)}
        >
          <option value="general">general</option>
          <option value="travel">travel</option>
          <option value="music">music</option>
        </select>
      </label>
      <hr />
      <ChatRoom roomId={roomId} />
    </>
  );
}
```



### 在 Effect 中读取最新的 props 和 state

使用 useEffectEvent Hook，由于其属于试验性 API，这里就不深入讨论了。



### 在服务器和客户端显示不同的内容

如果我们的应用使用到了服务端渲染，组件将会渲染在两个环境。在服务端会渲染并生成初始的 HTML；在客户端，React 会再次渲染代码，目的是在 HTML 中添加事件处理函数。

在极少数情况下，我们需要在客户端上显示不同的内容。例如，关于 localStorage 的操作只能在客户端实现，此时就需要借助下面的逻辑：

```react
function MyComponent() {
  const [didMount, setDidMount] = useState(false);

  useEffect(() => {
    setDidMount(true);
  }, []);

  if (didMount) {
    // ... return client-only JSX ...
  }  else {
    // ... return initial JSX ...
  }
}
```



## 常见问题

### Effect 在组件挂载时运行了两次

在严格模式下的开发环境中，React 会在第一次执行 setup function 之前额外执行一次 Effect 中的 setup 与 cleanup 逻辑。

这是为了验证 Effect 中的 cleanup 逻辑是否能准确清理 setup 。



### Effect 在每次 re-render 都会运行

检查依赖项是否每次 re-render 都会改变，然后利用上面的方法优化 Effect 逻辑。

实在不行，使用 `useMemo` 或 `useCallback` 包裹依赖项。



### Effect 陷入了死循环

当Effect陷入死循环，说明 Effect 更新了 state，同时 re-render 又改变了 Effect 依赖项的值。

解决方案：（废话）

- 重新审视组件逻辑，确定是否需要 Effect

- 重新审视 Effect 逻辑，确定依赖项与 state 的联系



### cleanup 逻辑在组件未卸载时就执行了

原因同常见问题1，在此再次强调，Effect 中的 setup 逻辑应与 cleanup 逻辑“一一对应”，避免出现如下代码：

```react
useEffect(() => {
  // X Avoid: Cleanup logic without corresponding setup logic
  return () => {
    doSomething();
  };
}, []);
```



### Effect 会执行一些视觉操作，并且在运行之前看到闪烁

例如，在用户首次看到 tooltip 之前测量并定位 tooltip 的需求，应使用useLayoutEffect 替换 useEffect。详情见useLayoutEvent章节。