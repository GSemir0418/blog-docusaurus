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

#### require 函数的实现

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

#### 问题：2.js 中 m 的值为？

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

#### require 与 import 区别

- **import**

1. `import` 是 ES6 (ECMAScript 2015) 中引入的，用于**静态导入模块**。

2. 它允许使用**解构赋值**的方式来引入模块中的特定部分。

3. `import`具有**提升**效果，无论在文件的哪个部分使用，都会被**提升到文件顶部**。

4. `import`语句只能在**模块的顶层作用域**中使用，不能在条件语句中。

5. 它与ES6模块系统配合使用，支持模块的**静态分析**和**树摇操作**（tree-shaking），有助于实现**按需加载**。

- **require**

1. `require`是 CommonJS 规范中引入的，用于在 Node.js 中**同步导入模块**。

2. 使用`require`时，你直接获取到一个模块的导出对象

3. `require` 在运行时调用，意味着可以根据条件的不同**动态地加载不同的模块**。

4. 可以在代码的**任何地方**使用`require`，包括在函数或条件语句中。

5. `require` 通常**不支持无用代码移除**和**按需加载**，因为它是动态加载的。

- **区别**

1. `import` 是静态的，支持编译时优化；`require`是动态的，适用于条件加载和运行时的计算路径。

2. `import`需要在模块顶部，且不能在代码块中使用；`require`则可以在模块的任何地方使用。

3. `import`语句可以让现代的JS打包工具和引擎**优化**导入的模块；`require`则不支持这些优化功能。

4. `import`语句主要用于前端JavaScript模块化，而`require`则常用于Node.js的模块系统。

在实际开发中，如果使用的是Node.js，并且没有使用工具如Babel或Webpack对代码进行转换和打包，通常会使用`require`。如果开发的是现代的前端应用程序，并且项目配置了相应的JS打包工具，则推荐使用`import`语法来引入模块。随着Node.js对ES6模块的支持日益完善，`import`语句的使用变得越来越广泛。
