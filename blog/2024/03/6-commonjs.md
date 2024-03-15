---
title: CommonJS
date: 2024-03-06T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [javascript, commonjs, require]
---

整个 commonjs 的运行都依托于 require 函数的执行机制，所以研究 commonjs 的关键就在于理解 require 函数的本质

- require 函数的实现

require 函数接收模块路径作为参数

根据模块路径，得到模块完整的绝对路径，将其标识为该模块的id

根据 id 判断缓存中是否存在，如果存在直接返回缓存的模块数据

模块内部代码实际是在一个**辅助函数**中执行的，辅助函数接收 `exports`、`require`函数自身、`module`、`__filename` 以及 `__dirname` 作为参数

> 这也就解释了为什么模块能够隔离变量，不会造成全局污染；并且在模块中可以直接使用 `exports module __dirname __filename require` 等属性或方法

准备这个辅助函数所需的参数后，使用 `call` 执行辅助函数，并将 module 对象的 exports 属性作为上下文传入辅助函数

> 这就意味着在模块代码中，`this === exports === module.exports`，三者默认指向同一个对象

最后缓存并返回 `module.exports` 即可

- 伪代码

```js
function require(modulePath) {
  // 1. 根据传递的模块路径，得到模块完整的绝对路径作为id
  var moduleId = getModuleIds(modulePath)
  // 2. 判断缓存
  if (cache[moduleId]) {
    return cache[moduleId]
  }
  // 3. 真正运行模块代码的辅助函数
  function _require(exports, require, module, __filename, __dirname) {
    // 目标模块的代码在这里
    // 也就是说我们的模块代码都是在一个函数环境中执行的
    // 这也就解释了为什么 commonjs 能够隔离变量，不会造成全局污染
    
    // 我们在模块中可以直接使用 exports module __dirname __filename require 等属性或方法
    // 原因就在于他们都是这个函数的参数
  }
  // 4. 准备并运行辅助函数
  var module = {
    exports: {}
  }
  var exports = module.exports
  // 得到文件模块的绝对路径
  var __filename = moduleId
  // 得到模块所在目录的绝对路径
  var __dirname = getDirname(__filename)
  // 使用 call 执行函数，绑定上下文为 exports
  // 这就意味着在模块中，this === exports === module.exports
  __require.call(exports, exports, require, module, __filename, __dirname)
  
  // 5. 缓存 module.exports
  cache[moduleId] = module.exports
  // 6. 返回 module.exports
  return module.exports
}
```

- 问题：2.js 中 m 的值为？
- 牢记模块代码中的 **this、exports 和 module.exports 默认指向同一个对象**

```js
// 1.js
this.a = 1
exports.b = 2
exports = {
  c: 3
}
module.exports = {
  d: 4
}
exports.e = 5
this.f = 6

// 2.js
const m = require('./1.js')
```

| Code                        | this                   | module.exports   | exports          |
| --------------------------- | ---------------------- | ---------------- | ---------------- |
| `this.a = 1`                | `{ a: 1 }`             | `{ a: 1 }`       | `{ a: 1 }`       |
| `exports.b = 2`             | `{ a: 1, b: 2 }`       | `{ a: 1, b: 2 }` | `{ a: 1, b: 2 }` |
| `exports = { c: 3 }`        | `{ a: 1, b: 2 }`       | `{ a: 1, b: 2 }` | `{ c: 3 }`       |
| `module.exports = { d: 4 }` | `{ a: 1, b: 2 }`       | `{ d: 4 }`       | `{ c: 3 }`       |
| `exports.e = 5`             | `{ a: 1, b: 2 }`       | `{ d: 4 }`       | `{ c: 3, e: 5 }` |
| `this.f = 6`                | `{ a: 1, b: 2, f: 6 }` | `{ d: 4 }`       | `{ c: 3, e: 5 }` |

require 函数最终返回的是 module.exports 对象，因此变量 m 的值为 `{ d: 4 }`
