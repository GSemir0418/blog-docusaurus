---
title: Reflect
date: 2024-03-14T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [javascript, reflect]
---

#### 概念

`Reflect` 提供了**调用对象基本操作（内部方法）**的接口

> - ECMA-262 官方文档对于对象的 [Internal Methods](https://262.ecma-international.org/14.0/?_gl=1*ts491n*_ga*MTI4NjU0NzkwNS4xNzEwNzM4OTUz*_ga_TDCK4DWEPP*MTcxMDczODk1My4xLjEuMTcxMDczOTg5Mi4wLjAuMA..#table-essential-internal-methods) 有详细描述，比如 `[[Get]]`、`[[Set]]`、`[[OwnPropertyKeys]]`、`[[GetPrototypeOf]]` 等
>
> - MDN 文档对于内部方法的映射，在 [Proxy](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy) 文档中也有详细说明

也就是说，对象语法层面的操作（对象声明，属性定义与读取等）最终都是通过调用**内部方法**来完成的

而 Reflect 允许我们直接调用这些内部方法

```js
const obj = {}
obj.a = 1
// 相当于
Reflect.set(obj, 'a', 1)
```

#### Why Reflect

当我们使用某个语法或某个 api 来「**间接**」操作对象时，与直接调用内部方法还是有区别的

也就是说，除了直接调用内部方法以外，这个语法或 api 还会进行一些额外的操作

```js
const obj = {
	a: 1,
	b: 2, 
	get c(){
		return this.a + this.b
	}
}
```

当我们要用 `obj.c` 读取属性时，返回了 3，符合我们的预期

但实际上，内部方法 `[[Get]]` 是需要额外接收 resolver 用来确定 this 指向的

这就说明 `obj.c` 在读取属性的过程中，一定不只是直接调用内部方法 `[[Get]]`，而是先把 obj 定义为 `this`，再调用内部方法 `[[Get]](obj, 'c', obj)`，从而获取到 c 属性的值

#### 应用

- 配合 Proxy 使用

封装代理对象，需要读取某个属性时，this 应该指向代理对象而不是原始对象

```js
const proxy = new Proxy(obj, {
	get(target, key) {
		console.log('read', key)
		// return target[key] // read c
    return Reflect.get(target, key, proxy) // read c read a read b
	}
})

proxy.c
```

- 读取对象的全部属性名

使用 `Object.keys(obj)`

虽然一开始调用了内部方法 `[[OwnPropertyKeys]]` 获取到了对象全部的 keys，但紧接着对于**不可枚举或 Symbol 类型**的属性进行了排除

因此更严谨的获取对象全部属性名的方法就是直接调用内部方法 `Reflect.ownKeys(obj)`

