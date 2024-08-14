---
title: CJS 与 ESM
date: '2024-08-14T15:42:00+08:00'
tags: ["JavaScript", require, commonjs, esmodule]
sidebar-position: 10
authors: gsemir
---

## CommonJS

- **社区**标准
- 使用**函数**实现
- 仅 **node** 环境支持
- **动态**依赖（需要代码运行后才能确定依赖）
- 动态依赖**同步**执行（阻塞）

原理详见 blog 《CommonJS》一文

核心在于 `require` 函数的实现过程：辅助函数、构造 module 空对象、辅助函数调用参数（`this`, `exports`, `require`, `module`, `__filename`, `__dirname`）、返回 `module.exports` 对象，以及模块缓存

## ES Module

- **官方**标准
- 使用**新语法** import/export 实现
- **所有**环境均支持
- 同时支持**静态**依赖和**动态**依赖
- 动态依赖是**异步**的
- **符号绑定/引用传递**
  - 导入的符号与导出的符号，并不是简单的赋值关系，而是**共享了同一块内存空间**，可以看做引用传递

关于符号绑定

```js
// module a.js
export var a = 1
export function changeA() {
  a = 2
}

// index.js
// 使用 as 也不会影响结果
// 同时也证明了 import 不是对导出对象做简单的解构
import { a as aa, changeA } from './a'
console.log(aa) // 1
changeA()
console.log(aa) // 2
```

## 面试题

1. CommonJS 和 ESM 的区别

> 1. CJS 是社区标准，ESM 是官方标准
> 2. CJS 是使用函数实现的模块化，ESM 是使用新语法实现的模块化
> 3. CJS 仅在 node 环境支持，ESM 各种环境均支持
> 4. CJS 是动态的依赖，同步执行，ESM 及支持动态，也支持静态，动态依赖是异步执行的
> 5. ESM 导入时有符号绑定，CJS 只是普通函数调用与赋值

2. export 和 export default 的区别

> - export 为普通导出，又叫做具名导出，它导出的数据必须带有命名，比如变量定义、函数定义等。在导出的模块对象中，命名即为模块对象的属性名，在一个模块中可以有多个具名导出
> - export default 为默认导出，在模块对象中名称固定为 default，因此无需命名，通常导出一个表达式或字面量。在一个模块中只能有一个默认导出

3. 下面的模块导出了什么结果

```js
exports.a = 'a'
module.exports.b = 'b'
this.c = 'c'
module.exports = {
  d: 'd'
}
```

> `{ d: 'd' }`

4. 下面的代码输出了什么结果

```js
// module counter
var count = 1
export { count }
export function increase() { count++ }

// module main
import { count, increase } from './counter'
import * as counter from './counter'
// 解构出来的 c 断开了与上一模块的绑定
const { count: c } = counter
increase()
console.log(count)
console.log(counter.count)
console.log(c)
```

> 2 2 1