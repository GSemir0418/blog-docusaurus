---
title: 手写bind/call
date: 2024-03-24T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [javascript, call, bind, apply, this]
---

#### 解释

在 JavaScript 中，`call`、`bind`和`apply`都是 `Function.prototype` 上的方法，它们可以用来**设置函数调用时的 `this` 值**，即函数执行时的上下文。

**call()**
`call` 方法可以让你明确地指定函数的`this`值，还可以在调用函数时传递给函数参数列表

```javascript
func.call(thisArg, arg1, arg2, ...)
```

**apply()**
`apply` 方法的功能与 `call` 相似，但是它**接受一个数组**（或类数组对象）作为调用函数时的参数列表

```javascript
func.apply(thisArg, [argsArray])
```

**bind()**
`bind` 方法创建一个新函数，你可以将一个值设置为在新函数中调用原始函数时的 `this` 值。不同于`call`和`apply`，`bind` 不会立即执行函数，而是**返回**一个新的函数

```javascript
const newFunc = func.bind(thisArg[, arg1[, arg2[, ...]]])
```

#### 手写 bind

```js
Function.prototype.myBind = function (ctx, ...args) {
  const func = this
  return function (...restArgs) {
    if (new.target) {
      return new func(...args, ...restArgs)
    } else {
      return func.apply(ctx, [...args, ...restArgs])
    }
  }
}

function originFunc(a, b, c, d) {
  console.log('fun 执行了')
  console.log('args', a, b, c, d)
  console.log('this', this)
}

const boundFunc = originFunc.myBind('boundThis', 1, 2)
console.log(new boundFunc(3, 4))
```

- 有一个小细节：boundFunc 如果是通过 `new` 关键字调用的（`new.target`），我们也要使用原函数作为构造函数，并返回这个实例；否则返回使用 call 或 apply 修改其 this 后的函数

#### 手写 call

- 处理新的 this 为对象
  - 使用 `Object()` 和 `globalThis` 关键字

```js
Function.prototype.myCall = function (ctx, ...args) {
  const func = this
  // 处理新的 this 为对象
  // Object 会将基本类型的数据转为对应的包装类实例
  ctx = ctx === null || ctx === undefined ? globalThis : Object(ctx)
  
  // 将原函数作为 ctx 的一个属性
  // 通过对象方法调用，从而改变原函数的 this 指向（为新 ctx）
  ctx._func = func
  ctx._func(...args)
}

```

- 但是会导致新的 this 对象额外多了一个可枚举属性 `_func`，并且可能会出现属性重名的情况
  - 使用 `Object.defineProperty` 定义不可枚举的 `Symbol` 属性

```js
Function.prototype.myCall = function (ctx, ...args) {
  const func = this
  ctx = ctx === null || ctx === undefined ? globalThis : Object(ctx)
  
  const key = Symbol()
  Object.defineProperty(ctx, key, {
    value: func,
    enumerable: false
  })
  ctx[key](...args)
}

function originFunc(a, b) {
  console.log('args', a, b)
  console.log('this', this)
}

originFunc.myCall('boundedThis', 1, 2)
console.log('==========')
originFunc.call('boundedThis', 1, 2)
```

手写 apply 思路与 call 一致，只需修改入参类型为数组即可

