---
title: Math
date: 2024-03-28T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [javascript, math, parseInt]
---

JavaScript的`Math`对象提供了多种执行数学任务的方法，以下是一些常用的`Math`方法及其代码示例：

- `Math.round()` - 对一个数进行**四舍五入**到最接近的整数。

```javascript
console.log(Math.round(1.7))// 2
console.log(Math.round(2.5)) // 3
console.log(Math.round(-1.7)) // -2
console.log(Math.round(-2.5)) // -2
```

- `Math.floor()` - 向下取整（数轴负方向），返回**小于或等于**一个给定数字的最大整数。

```javascript
console.log(Math.floor(-1.7)) // -2
console.log(Math.floor(1.7)) // 1
```

- `Math.ceil()` - 向上取整（数轴正方向），返回**大于或等于**一个给定数字的最小整数。

```javascript
console.log(Math.ceil(-1.7)) // -1
console.log(Math.ceil(1.7)) // 2
```

- `Math.random()` - 返回一个介于`[0, 1)`之间的随机数。

```javascript
console.log(Math.random()); // 输出: 随机数
```

- `Math.max()` - 返回一组数中的最大值。

```javascript
console.log(Math.max(10, 20, 30)); // 输出: 30
```

- `Math.min()` - 返回一组数中的最小值。

```javascript
console.log(Math.min(10, 20, 30)); // 输出: 10
```

- `Math.sqrt()` - 返回一个数的平方根。

```javascript
console.log(Math.sqrt(64)); // 输出: 8
```

- `Math.abs()` - 返回一个数的绝对值。

```javascript
console.log(Math.abs(-4.7)); // 输出: 4.7
```

- `Math.pow()` - 返回基数（第一个给定的数）的指数（第二个给定的数）次幂。

```javascript
console.log(Math.pow(8, 2)); // 输出: 64
```

- `parseInt`

`Math.floor` 是向**下**取整，而 `parseInt` 是向**零**取整

因此二者在对正数处理时，返回的结果是一致的

但是在处理负数时，二者就出现了差别，此时 `parseInt` 与 `Math.ceil` 的结果是一致的

- **生成随机数**为什么使用 `Math.floor` 而不是 `parseInt` 或者 `Math.round` ?
  - 处理负数时的行为差别，导致随机数概率不均等

```js
function getRandom(min, max) {
  return Math.floor(Math.random() * (max + 1 - min) + min)
}
```

