---
sidebar-position: 5
title: Scheduler 调度普通任务
date: 2024-05-05
authors: gsemir
tags: [react, schedule, task queue]
---


# Scheduler 调度普通任务

Scheduler 核心源码在[这里](https://github.com/facebook/react/blob/main/packages/scheduler/src/forks/Scheduler.js)

## [scheduleCallback](https://github.com/facebook/react/blob/main/packages/scheduler/src/forks/Scheduler.js#L322)

```ts
// 有两个队列分别存储普通任务和延时任务
// 其中采用了最小堆的算法，保证每次从队列中取出来的任务都是优先级最高的
var taskQueue: Array<Task> = [];
var timerQueue: Array<Task> = [];

// 获取当前时间（performance.now 或者 Date.now)
let getCurrentTime: () => performance.now()

var maxSigned31BitInt = 1073741823;

// timeout
export const userBlockingPriorityTimeout = 250;
export const normalPriorityTimeout = 5000;
export const lowPriorityTimeout = 10000;

function unstable_scheduleCallback(
  priorityLevel: PriorityLevel, // 优先级等级
  callback: Callback, // 本次任务回调
  options?: {delay: number}, // 是否要有延时的时间
): Task {
  var currentTime = getCurrentTime();

  // 初始化任务开始时间 startTime，默认是当前时间，有延时就加上延时
  var startTime;
  if (typeof options === 'object' && options !== null) {
    var delay = options.delay;
    if (typeof delay === 'number' && delay > 0) {
      startTime = currentTime + delay;
    } else {
      startTime = currentTime;
    }
  } else {
    startTime = currentTime;
  }

  // 根据优先级等级初始化 timeout
  var timeout;
  switch (priorityLevel) {
    case ImmediatePriority:
      // Times out immediately
      timeout = -1;
      break;
    case UserBlockingPriority:
      // Eventually times out
      timeout = userBlockingPriorityTimeout;
      break;
    case IdlePriority:
      // Never times out
      timeout = maxSigned31BitInt;
      break;
    case LowPriority:
      // Eventually times out
      timeout = lowPriorityTimeout;
      break;
    case NormalPriority:
    default:
      // Eventually times out
      timeout = normalPriorityTimeout;
      break;
  }

  // 计算出过期时间
  var expirationTime = startTime + timeout;

  var newTask: Task = {
    id: taskIdCounter++,
    callback,
    priorityLevel,
    startTime,
    expirationTime,
    sortIndex: -1, // 用于最小顶堆排序的 index，默认为 -1
  };
  if (enableProfiling) {
    newTask.isQueued = false;
  }
	
  // 如果手动设置了延时，出现了 startTime 小于当前时间的情况
  if (startTime > currentTime) {
    // 说明这是一个延时任务，设置排序索引后，push 进 timerQueue
    newTask.sortIndex = startTime;
    push(timerQueue, newTask);
    if (peek(taskQueue) === null && newTask === peek(timerQueue)) {
      // taskQueue 中的任务是空的，且 timerQueue 的第一个任务就是当前任务
      if (isHostTimeoutScheduled) {
        // Cancel an existing timeout.
        cancelHostTimeout();
      } else {
        isHostTimeoutScheduled = true;
      }
      // 针对延时任务，调用 requestHostTimeout 来调度
      requestHostTimeout(handleTimeout, startTime - currentTime);
    }
  // 普通任务的情况
  } else {
    newTask.sortIndex = expirationTime;
    // 设置排序索引后，push 到 taskQueue
    push(taskQueue, newTask);
    if (enableProfiling) {
      markTaskStart(newTask, currentTime);
      newTask.isQueued = true;
    }
    // Schedule a host callback, if needed. If we're already performing work,
    // wait until the next time we yield.
    if (!isHostCallbackScheduled && !isPerformingWork) {
      isHostCallbackScheduled = true;
      // 针对普通任务，调用 requestHostCallback 来调度
      requestHostCallback();
    }
  }

 	// 最后返回任务
  return newTask;
}
```

共有两个任务队列，分别是 `taskQueue` 和 `timerQueue`，taskQueue 存放**普通任务**，timerQueue 存放**延时任务**。

任务队列内部用到了**最小堆算法**，通过 `peek` 取出任务时，始终取出的是时间优先级最高的那个任务

**优先级策略**：根据传入不同的 priorityLevel 初始化 timeout，以区分任务在任务队列中的的优先级顺序

不同的任务，最终调用的函数不同

- 针对普通任务，调用 `requestHostCallback` 来调度
- 针对延时任务，调用 `requestHostTimeout` 来调度

我们继续研究普通任务的调度过程

## [requestHostCallback](https://github.com/facebook/react/blob/main/packages/scheduler/src/forks/Scheduler.js#L549C1-L549C5) & [schedulePerformWorkUntilDeadline](https://github.com/facebook/react/blob/main/packages/scheduler/src/forks/Scheduler.js#L516)

```ts
function requestHostCallback() {
  if (!isMessageLoopRunning) {
    isMessageLoopRunning = true;
    schedulePerformWorkUntilDeadline();
  }
}

let schedulePerformWorkUntilDeadline; // undefined
if (typeof localSetImmediate === 'function') {
  // Node.js and old IE.
  schedulePerformWorkUntilDeadline = () => {
    localSetImmediate(performWorkUntilDeadline);
  };
} else if (typeof MessageChannel !== 'undefined') {
  // 大多数情况下使用 MessageChannel 构造任务
  const channel = new MessageChannel();
  const port = channel.port2;
  channel.port1.onmessage = performWorkUntilDeadline;
  schedulePerformWorkUntilDeadline = () => {
    port.postMessage(null);
  };
} else {
  // 使用 setTimeout 作为兜底的
  schedulePerformWorkUntilDeadline = () => {
    localSetTimeout(performWorkUntilDeadline, 0);
  };
}
```

requestHostCallback 主要就是调用了 `schedulePerformWorkUntilDeadline` 来开启 React 的任务调度

`schedulePerformWorkUntilDeadline` 就是根据运行环境，确定任务以哪种方式（setImmediate、MessageChannel、setTimeout）被注册为（宏）任务，从而参与到宿主环境的事件循环过程

`performWorkUntilDeadline` 就是 React 任务调度的核心逻辑

## [performWorkUntilDeadline](https://github.com/facebook/react/blob/main/packages/scheduler/src/forks/Scheduler.js#L488)

```ts
let startTime = -1
const performWorkUntilDeadline = () => {
  if (isMessageLoopRunning) {
    const currentTime = getCurrentTime();
    // 记录当前时间作为开始时间，计算主线程被阻塞了多久，也就是任务执行了多久
    startTime = currentTime;

    // 先假设有更多的工作要做
    let hasMoreWork = true;
    try {
      // 运行 flushWork 函数来处理工作，这个函数返回一个布尔值，告诉我们是否还有更多的工作要做
      hasMoreWork = flushWork(currentTime);
    } finally {
      // 最终如果仍然有更多的任务，则调用 schedulePerformWorkUntilDeadline
      // 利用 MessageChannel 安排下一个 message 事件的执行，就是将任务放入任务队列中，
      // 等待下次事件循环时段执行
      if (hasMoreWork) {
        schedulePerformWorkUntilDeadline();
      } else {
        isMessageLoopRunning = false;
      }
    }
  }
};
```

这个方法会在当浏览器有空闲时间时被调用，检查是否有待执行的任务，如果有，就利用这段空闲时间执行。每次执行一个任务后，它会检查是否还有时间继续执行下一段任务，或者是否还有更多的任务需要执行。

一旦当前的工作分片完成，如果确认还有更多的工作要做（而且当前浏览器帧有足够的时间），它会继续执行这些任务。否则，它将这些任务推迟到浏览器的下一个空闲时段

该方法主要是在调用 `flushWork`，这个函数返回一个布尔值，告诉我们是否还有更多的工作要做，如果有，就利用 MessageChannel 安排下一个 message 事件的执行，就是将任务放入任务队列中

该方法直到没有任务（或者到了期限）后会结束本次 messageLoop

继续研究 flushWork 是如何处理任务的执行的

## [flushWork](https://github.com/facebook/react/blob/main/packages/scheduler/src/forks/Scheduler.js#L144C10-L144C19) & [workLoop](https://github.com/facebook/react/blob/main/packages/scheduler/src/forks/Scheduler.js#L188)

```ts
function flushWork(initialTime: number) { // 任务开始执行的时间（调用 performWorkUntilDeadline 的时间）
  // ...

  try {
    if (enableProfiling) {
      try {
        return workLoop(initialTime);
      } catch (error) {
        if (currentTask !== null) {
          const currentTime = getCurrentTime();
          markTaskErrored(currentTask, currentTime);
          currentTask.isQueued = false;
        }
        throw error;
      }
    } else {
      // No catch in prod code path.
      return workLoop(initialTime);
    }
  } finally {
    // ...
  }
}
```

这个函数会进行一些判断逻辑，但始终会将入参原封不动地交给了 workLoop 函数并执行

workLoop 就是执行每个任务的具体逻辑了

```ts
function workLoop(initialTime: number) {
  let currentTime = initialTime;
  // 遍历 timerQueue，检查是否有已经到期的任务
  // 如果有，就将任务放入 taskQueue
  advanceTimers(currentTime);
  
 	// 从 taskQueue 取一个任务出来
  currentTask = peek(taskQueue);
  // 如果当前任务存在，进入循环
  while (
    currentTask !== null &&
    !(enableSchedulerDebugging && isSchedulerPaused)
  ) {
    if (currentTask.expirationTime > currentTime && shouldYieldToHost()) {
      // 当前任务还没有过期且应该归还主线程给宿主环境时，结束循环
      break;
    }
    // 当前任务到了过期时间，且暂时还不用归还线程给宿主环境
    // 那么就执行任务的回调函数
    const callback = currentTask.callback;
    if (typeof callback === 'function') {
      currentTask.callback = null;
      currentPriorityLevel = currentTask.priorityLevel;
      const didUserCallbackTimeout = currentTask.expirationTime <= currentTime;
      // 允许资料收集？
      if (enableProfiling) {
        markTaskRun(currentTask, currentTime);
      }
      const continuationCallback = callback(didUserCallbackTimeout);
      currentTime = getCurrentTime();
      if (typeof continuationCallback === 'function') {
        // If a continuation is returned, immediately yield to the main thread
        // regardless of how much time is left in the current time slice.
        currentTask.callback = continuationCallback;
        if (enableProfiling) {
          markTaskYield(currentTask, currentTime);
        }
        advanceTimers(currentTime);
        return true;
      } else {
        if (enableProfiling) {
          markTaskCompleted(currentTask, currentTime);
          currentTask.isQueued = false;
        }
        if (currentTask === peek(taskQueue)) {
          pop(taskQueue);
        }
        advanceTimers(currentTime);
      }
    } else {
      // callback 不是函数，直接弹出队列
      pop(taskQueue);
    }
    // 再取出一个任务，继续循环
    currentTask = peek(taskQueue);
  }
  
  // 函数最后返回是否还有更多的任务
  if (currentTask !== null) {
    return true;
  } else {
    // 说明此时 taskQueue 为空，那么就去 timerQueue 取延时任务
    const firstTimer = peek(timerQueue);
    if (firstTimer !== null) {
     	// 调用 requestHostTimeout 调度延时任务
      requestHostTimeout(handleTimeout, firstTimer.startTime - currentTime);
    }
    // 此时两个任务队列都空了，那么返回 false，表示没有更多任务需要执行了
    return false;
  }
}
```

flushWork 主要就是在调用 `workLoop`

workLoop 通过 `while` 循环，从任务队列不停地取任务出来**有条件**（任务是否存在、任务是否过期、是否应该归还主线程给宿主环境）地执行。同时稍微参与了一下延时任务队列的调度

以上就是 Scheduler 在调度普通任务的核心逻辑，下面顺便了解下 `shouldYieldToHost` 和 `advanceTimers`

## [shouldYieldToHost](https://github.com/facebook/react/blob/main/packages/scheduler/src/forks/Scheduler.js#L458)

```js
function shouldYieldToHost(): boolean {
  const timeElapsed = getCurrentTime() - startTime;
  // frameInterval 默认 10ms
  if (timeElapsed < frameInterval) {
    return false;
  }
  // Yield now.
  return true;
}
```

逻辑非常简单，就是通过在调用 performWorkUntilDeadline 方法时缓存的 `startTime`，即**本次调度任务**的开始时间，来计算出任务执行时间

然后与每帧的间隔时间 `frameInterval`（10ms） 作对比，如果任务执行时间比 frameInterval 久，说明主线程已经被阻塞了，那么就需要归还主线程给浏览器，反之则无需归还

## [advanceTimers](https://github.com/facebook/react/blob/main/packages/scheduler/src/forks/Scheduler.js#L103)

```js
function advanceTimers(currentTime: number) {
  // Check for tasks that are no longer delayed and add them to the queue.
  let timer = peek(timerQueue);
  while (timer !== null) {
    if (timer.callback === null) {
      // Timer was cancelled.
      pop(timerQueue);
    } else if (timer.startTime <= currentTime) {
      // Timer fired. Transfer to the task queue.
      pop(timerQueue);
      timer.sortIndex = timer.expirationTime;
      push(taskQueue, timer);
      if (enableProfiling) {
        markTaskStart(timer, currentTime);
        timer.isQueued = true;
      }
    } else {
      // Remaining timers are pending.
      return;
    }
    timer = peek(timerQueue);
  }
}
```

主要就是遍历检查 timerQueue，将无需延时的任务放到 taskQueue 里面

## 总结

- 使用 `scheduleCallback` **构造任务**，并根据任务类型将任务推入各自的任务队列，然后调用 `requestHostCallback/requestHostTimeout` 开启任务调度
  - requestHostCallback 实际上调用了 `schedulePerformWorkUntilDeadline` 来**开启任务调度**
- `schedulePerformWorkUntilDeadline` 根据不同环境，决定了 `performWorkUntilDeadline` 回调以何种方式**被包装为浏览器事件循环中的（宏）任务**
  - `performWorkUntilDeadline` 回调就是整个调度器的**核心**，当到达执行的时机，浏览器就会调用`performWorkUntilDeadline`，即进入 React 的调度工作。这个函数负责按照 React 的调度逻辑去执行任务，它会利用当前帧的剩余时间来执行优先级较高的任务，一旦到达截止时间（即没有足够的时间执行更多任务），它会将主线程控制权交还给浏览器，等待下一个机会继续执行剩下的任务
    - 而**实际执行任务**的处理逻辑是在`flushWork`和`workLoop` 中进行，通过 `while` 循环，从任务队列不停地取任务出来有条件（任务是否存在、任务是否过期、是否应该归还主线程给宿主环境）地执行。同时稍微参与了一下延时任务队列的调度