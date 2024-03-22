---
title: 任务执行的洋葱模型
date: 2024-03-22T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [javascript, task, koa]
---

#### 题目

```js
const t = new TaskPro()
t.addTask(async (next) => {
	console.log(1, 'start')
	await next()
	console.log(1, 'end')
})
t.addTask(() => {
	console.log(2)
})
t.addTask(() => {
	console.log(3)
})
t.run() // 1 start, 2, 3, 1 end
```

#### 分析

t 是 TaskPro 的实例，有 run 和 addTask 两个实例方法

其中 addTask 方法接受一个函数（同步或异步），函数具有唯一参数 next，是一个异步函数

调用 next 可以跳过当前位置之后的代码，直接执行下一个任务

调用 run 方法正式开始执行任务队列中的任务

与 koa 中间件的洋葱模型同理

#### 思路

1. 准备实例方法和私有属性

```js
class TaskPro {
  #taskList = [] // 任务队列
  #isRunning = false // 标识是否正在执行
  
  // 添加一个任务到任务队列
  addTask(task) {
    this.#taskList.push(task)
  }
  
  // 执行任务队列
  async run() {
  	// 防止多次重复执行 run
    if (this.#isRunning) {
      return
    }
    this.#isRunning = true
    // ...
  }
}
```

2. 执行任务就是在任务队列取出一个任务来执行，这里抽离为一个私有方法 `runTask`

```js
class TaskPro {
  // ...
  #currentTaskIndex = 0 // 记录当前执行任务的下标

  async run() {
  	// ...
    this.#runTask()
  }
  
  async #runTask() {
    // 边界情况，收尾工作
    if (this.#currentTaskIndex >= this.#taskList.length) {
      this.#isRunning = false
      this.#currentTaskIndex = 0
      this.#taskList = []
      return 
    }
    // 根据当前执行任务的下标取出任务
    const task = this.#taskList[this.#currentTaskIndex]
    // 执行任务
    await task()
  }
}
```

3. 处理 next 参数，next 方法实际上就是将 currentTaskIndex 加1，重复执行 runTask方法

```js
class TaskPro {
  // ...
  async #runTask() {
    // ...
    // 由于我们在使用中是直接调用的 next，导致 next 函数中用到的 this 为 {}
    // 所以使用 bind 绑定好 this 再传到 task 中
    await task(this.#next.bind(this))
  }
  
  // 下标加1，继续执行任务
  async #next() {
    this.#currentTaskIndex++
    await this.#runTask()
  }
}
```

4. 默认调用 next

```js
class TaskPro {
  // ...
  async #runTask() {
    // ...
    // 记录执行任务之前的 index
    const i = this.#currentTaskIndex
    await task(this.#next.bind(this))
    // 与 await task 之后的下标对比，如果没改变，说明用户没有手动调用 next
    if (this.#currentTaskIndex === i) {
      // 默认执行 next
      await this.#next()
    }
  }
}
```

#### 源码及测试用例

```js
class TaskPro {
  #taskList = []
  #isRunning = false
  #currentTaskIndex = 0
  addTask(task) {
    this.#taskList.push(task)
  }
  async run() {
    if (this.#isRunning) {
      return
    }
    this.#isRunning = true
    await this.#runTask()
  }
  async #runTask() {
    if (this.#currentTaskIndex >= this.#taskList.length) {
      this.#isRunning = false
      this.#currentTaskIndex = 0
      this.#taskList = []
      return 
    }
    const task = this.#taskList[this.#currentTaskIndex]
    const i = this.#currentTaskIndex
    await task(this.#next.bind(this))
    if (this.#currentTaskIndex === i) {
      await this.#next()
    }
  }
  async #next() {
    this.#currentTaskIndex++
    await this.#runTask()
  }
}

const t = new TaskPro()

t.addTask(async (next) => {
  console.log(1, 'start')
	await next()
	console.log(1, 'end')
})
t.addTask(async (next) => {
  console.log(2, 'start')
  await next()
  console.log(2, 'end')
})
t.addTask(() => {
  console.log(3)
})
t.run()
```

