---
title: 'Web Workers'
date: '2023-06-06T13:28:00+08:00'
tags: ["workers"]
sidebar-position: 2
authors: gsemir
---

# Web Workers

- 概念
  - Web Workers 是一种运行在后台线程中的 JavaScript 程序，它可以在主线程之外执行耗时操作，从而提高 Web 应用程序的响应性能。
  - 由于 Web Worker 与主线程运行在不同的上下文环境中，它们之间无法直接共享数据，必须通过消息传递机制来进行通信。

- 优势
  - 通过将任务放入 worker 中，可以避免阻塞页面渲染或用户交互，同时也可以利用多核 CPU 提高并发处理能力。

- 用途

  - Web Workers 通常用于处理大量数据的计算、网络请求、图像处理等任务，以及运行其他语言编写的代码（如 wasm 等）。

- API

  - 创建 worker 实例

  ```js
  const myWorker = new Worker(aUrl, options?)
  ```

  - 实例方法

  ```js
  // postMessage
  // 可以通过实例调用，向 worker 传递数据
  // main.js
  worker.postMessage(data)
  
  // 也可以在 worker 中直接调用，将结果传回主线程
  // worker.js
  postMessage(result)
  
  // onmessage 或 message 事件监听器
  // 可以通过实例赋值，也可以在 worker 中直接赋值
  // 通过 message 事件实例的 data 属性拿到数据
  worker.onmessage = (event) => { console.log(event.data) }
  onmessage = () => { process.. }
  ```

- 示例1：计算斐波那契数列前 n 项和

  - worker.js

    ```js
    function fibonacci(n) {
    	if(n <= 2) return 1
    	else return fibonacci(n - 1) + fibonacci(n - 2)
    }
    
    onmessage = (event) => { postMessage(fibonacci(event.data)) }
    ```

  - Index.html

    ```html
    <!DOCTYPE html>
    <html lang="en">
    
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Document</title>
        <style>
            #time,
            #workerTime {
                color: red
            }
        </style>
    </head>
    
    <body>
        <label for="num">计算斐波那契数列的前</label>
        <input type="number" id="num" min="1" max="100" value="10">
        项和
        <button onclick="calculateWithWebWorker()">web worker计算</button>
        <button onclick="calculate()">直接计算</button>
        <p id="result"></p>
        <p>
            直接计算用时<span id="time">0</span>ms
        </p>
        <p>
            WebWorker用时<span id="workerTime">0</span>ms
        </p>
    </body>
    <script>
      function calculateWithWebWorker() {
        const start = new Date().getTime()
        const num = document.querySelector("#num").value;
        const worker = new Worker("./worker.js");
        worker.postMessage(num); // 将数据传入 Worker
        worker.onmessage = function (event) { // 接收 Worker 返回的结果
          document.querySelector("#result").textContent = event.data;
          document.querySelector("#workerTime").textContent = (new Date().getTime() - start)
        };
      }
      function calculate() {
        const start = new Date().getTime()
        const num = document.querySelector("#num").value;
        function fibonacci(n) {
          if (n <= 2) {
            return 1;
          } else {
            return fibonacci(n - 1) + fibonacci(n - 2);
          }
        }
        document.querySelector("#result").textContent = fibonacci(num)
        document.querySelector("#time").textContent = (new Date().getTime() - start)
      }
    </script>
    </html>
    ```

  - 结论

    - 22位之前，直接计算甚至用不到1ms
    - 当计算至31位后，Web Worker的优势就逐渐体现出来了
    - 具体位数与计算机硬件配置相关
    - 计算量越大，直接计算的卡顿越明显，而Web Worker不会阻塞渲染主进程

- 示例2：执行异步操作

  - 
