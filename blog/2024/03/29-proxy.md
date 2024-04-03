---
title: Proxy
date: 2024-03-29T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [javascript, proxy, reflect, toPrimitive]
---

完成这个表达式：`add[1][2][3] + 4 => 10`

1. 链式读取 add 对象的属性，并且累加 key

2. 在隐式类型转换时，要将内部的累加结果作返回

```js
const add = new Proxy(
	{ value: 0 },
	{
		get(target, key, receiver) {
      // 对象 => 原始，会先调用对象的 Symbol.toPrimitive 方法
			if (key === Symbol.toPrimitive) {
				return () => Reflect.get(target, 'value')
			}
			target.value += Number(key)
      // 支持链式读取，所以返回这个 proxy 本身
			return receiver
		}
	}
)

console.log(add[1][2][3] + 4) // 10
```