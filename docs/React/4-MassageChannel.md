---
sidebar-position: 4
title: MessageChannel
date: 2024-05-04
authors: gsemir
tags: [react, MessageChannel, event loop, raf]
---

# MessageChannel

React 在任务调度时利用 `MessageChannel` 实现非阻塞的异步任务调度，以便高效利用浏览器的主线程，避免影响用户交互和页面渲染的流畅度

## 回顾事件循环

事件循环的机制就是每一次循环，会从任务队列中取**一个**任务并执行。如果还没有到下一次*绘制*（rAF => Style => Layout => Paint）时间（16.66ms），那么就再循环一次，从任务队列里面再取一个任务来执行。以此类推，直到浏览器需要重新绘制页面，渲染完毕后，回到事件循环的流程。

`rAF` Api 是在浏览器每一次重新渲染之前执行，rAF 的执行频率与浏览器绘制页面的频率是一致的。在一个事件循环中，被`requestAnimationFrame`添加的回调函数会在下一次浏览器重绘之前执行一次。

每一帧所执行的任务个数是不一定的，如果某一帧执行任务时花费时间过长，那么就会占用下一帧的渲染时间，出现丢帧或掉帧的现象

区别于任务队列中的任务，还有一种任务类型为微任务。当微任务队列中存在任务，那么事件循环会在**一次**循环内，将整个微任务队列清空

## MessageChannel

MessageChannel API 是用来做**消息通信**的，基本使用如下

```html
<input type="text" id="content" />
<button id="btn1">给 port1 发消息</button>
<button id="btn2">给 port2 发消息</button>
<script>
	const channel = new MessageChannel()
  const port1 = channel.port1
  const port2 = channel.port2
  btn1.onclick = () => {
    port2.postMessage(content.value)
  }
  port1.onmessage = (e) => {
    console.log(`port1 收到了来自 port2 的消息：${e.data}`)
  }
</script>
```

**Scheduler** 在 React 中承担了任务调度的角色，负责决定什么时候执行任务，以及如何高效地利用浏览器的帧来执行这些任务以获得最佳的性能。

而实现任务的调度，需要满足一下两个条件

- 能够暂停 JS 的执行，将主线程还给浏览器
- 暂停后的 JS，能够在后续继续执行

因此可以利用浏览器事件循环机制，将没有执行完的 JS 放入任务队列，下一次事件循环继续执行。

React 使用 `MessageChannel` 作为一个指示器，它发送一个空消息让浏览器知道可以安排下一个任务了。当 `onmessage` 事件触发时，它真正开始执行任务。这就是所谓的异步调度，它和直接调用任务有着本质的区别：它允许浏览器有机会在发送消息和接收消息时执行其他操作，如UI渲染。

以下是 React 调度器如何使用 MessageChannel API 进行调度的步骤：

1. **创建 MessageChannel:** 调度器会创建一个 `MessageChannel` 实例。`MessageChannel` 包含两个端口，`port1` 和 `port2`，用于双向通信。
2. **调度任务:** 当需要调度一个任务时，调度器会将该任务包装在一个回调函数中，并将该回调函数注册为 `port1` `message` 事件的监听器。
3. **发送消息:** 当需要调度一个任务时，调度器会用 `port2` 发送一条**空消息**，让浏览器在合适的时间调用，从而触发 port1 的 omessage 事件，并执行之前注册的回调函数，从而执行相应的任务。
4. **异步执行:** 由于消息传递机制是异步的，因此任务会在下一个事件循环中执行，而不是阻塞当前的执行流程。

**代码示例：**

```js
const channel = new MessageChannel();
const port = channel.port2;

channel.port1.onmessage = () => {
  // 执行任务
};

// 调度任务
const scheduleTask = (task) => {
  port.postMessage(null);
};
```

### 为什么不选择 setTimeout

因为 setTimeout 在嵌套层级超过一定数量（一般是5）时，延时如果小于 4ms，那么会被强制设置为 4ms

### 为什么不选择 rAF

rAF 只能做到在每帧绘制前执行**一次**，而任务队列则是只要没到渲染一帧的时间，就可以一直执行下去

而且不同浏览器对于 rAF 的实现**存在差异**。比如 edge 和 safari 浏览器会在渲染一帧**后**执行，而 chrome 会在渲染一帧前执行

### 为什么不选择微任务

因为微任务队列会在清空整个队列后才结束，导致任务在页面重新绘制前一直执行，达不到将主线程还给浏览器的目的

## 将控制权移交给浏览器

这是基于 React 的**并发模式**（Concurrent Mode），它是通过使用浏览器的事件循环机制和自己内部的调度器（Scheduler）来实现的

React 并不会在一次事件循环中执行所有的渲染任务，而是将这些任务切成很多小的部分（称为"时间分片"），每个分片执行的时间不会超过 `5` 毫秒。在每个时间分片执行完后，React 会“主动让出”主线程的控制权，将主线程归还给浏览器，让它有机会去处理其他的任务，如用户交互事件、渲染UI等。然后，React 会等待浏览器空闲的时候，再继续执行剩余的渲染任务。

这种让出控制权的方式是通过浏览器 `MessageChannel` API实现的。当 React 完成一个时间分片的工作后，会将剩余任务通过这些 API **注册为回调函数**，在浏览器空闲时再进行执行。如此循环反复，就可以在高效渲染的同时，保证主线程的响应性。