---
title: async和await
date: 2024-03-23T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [javascript, async, await, generator]
---

使用 `async` 关键字声明的函数将返回一个 `Promise` 对象，而在这个异步函数中，你可以使用 `await` 关键字等待一个异步操作的结果，就像编写同步代码一样。

`async/await` 实际上可以看作是 `Generator` 函数及 `Promise` 的语法糖。

在 `async/await` 出现之前，开发者可以通过 `Generator` 函数加上 `yield` 关键字以及适当的执行器（例如使用库如`co`）来处理异步操作，实现类似 `async/await` 的功能。