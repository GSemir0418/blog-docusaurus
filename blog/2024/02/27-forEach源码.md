---
title: forEach 源码
date: 2024-02-27T13:24:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [javascript, forEach]
---

>提前拿到了原数组的 `len`，使用 `while(k < len)` 循环遍历，下标 k 不存在（`in`）的话就不会做处理，继续遍历

### 现象

在日常开发使用 forEach 遍历对象的过程中，会出现一些奇怪的现象：

- 比如一边遍历，一边 push 新元素，结果并没有陷入死循环，可以正常输出结果

```js
const arr = [1, 2, 3]

arr.forEach((item, index) => {
  arr.push(6)
  console.log('item', item) // item 1 item 2 item 3
})

console.log('arr', arr) // arr [1, 2, 3, 6, 6, 6]
```

- 比如一边遍历，一边 splice 元素，结果只循环了两次，结果还只剩一项

```js
const arr = [1, 2, 3]

arr.forEach((item, index) => {
  arr.splice(index, 1)
  console.log('item', item) // item 1 item 3
})

console.log('arr', arr) // arr [2]
```

- 再比如 arr 是一个稀疏数组 `[, , 3]`，则只会遍历一次

```js
const arr = [, , 3]

arr.forEach((item) => {
  console.log('item', item) // item 3
})

console.log('arr', arr) // arr [ <2 empty items>, 3 ]
```

-----

### 源码

要想准确解释以上的现象，需要查阅 ECMA 关于 [forEach](https://262.ecma-international.org/14.0/#sec-array.prototype.foreach) 的介绍

> This method performs the following steps when called:
>
> 1. Let O be ? [ToObject](https://262.ecma-international.org/14.0/#sec-toobject)(this value).
>
> 2. Let len be ? [LengthOfArrayLike](https://262.ecma-international.org/14.0/#sec-lengthofarraylike)(O).
>
> 3. If [IsCallable](https://262.ecma-international.org/14.0/#sec-iscallable)(callbackfn) is false, throw a TypeError exception.
>
> 4. Let k be 0.
>
> 5. Repeat, while k < len,
>
>    ​	a. Let Pk be ! [ToString](https://262.ecma-international.org/14.0/#sec-tostring)([𝔽](https://262.ecma-international.org/14.0/#𝔽)(k)).
>
>    ​	b. Let kPresent be ? [HasProperty](https://262.ecma-international.org/14.0/#sec-hasproperty)(O, Pk).
>
>    ​	c. If kPresent is true, then
>
>    ​		i. Let kValue be ? [Get](https://262.ecma-international.org/14.0/#sec-get-o-p)(O, Pk).
>
>    ​		ii. Perform ? [Call](https://262.ecma-international.org/14.0/#sec-call)(callbackfn, thisArg, « kValue, [𝔽](https://262.ecma-international.org/14.0/#𝔽)(k), O »).
>
>    ​	d. d. Set k to k + 1.
>
> 6. Return undefined.

根据上面行文逻辑，试着还原 `Array.prototype.forEach` 的源码

```js
Array.prototype.myForEach = function (callback) {
  // 处理 this 为当前数组
  let o = this
  // 拿到 this 的长度
  let len = o.length
  if (typeof callback !== 'function') {
    throw new TypeError(callback + 'is not a function')
  }
  // 当前元素下标
  let k = 0
  // while 循环
  while (k < len) {
    const pk = String(k)
    // 如果下标存在于当前数组，则执行 callback
    if (pk in o) {
      const kValue = o[pk]
      callback.call(o, kValue, k, o)
    }
    k++
  }
}
```

### 解释

现在我们来分别解释上面的三个现象

1. forEach 的同时 push 新元素，没有陷入死循环
   - 因为遍历的**次数**在一开始就确定为了**数组的初始长度**

2. forEach 的同时 splice 元素，遍历次数与结果与预期不符
   - splice 删除元素，相当于一直在**改变 this** 的值，而循环的次数 len 与下标 k 是一定的，这就导致了最终遍历次数与预期不符

3. 稀疏数组，会跳过空元素的遍历

   - 稀疏数组的稀疏项既不是 undefined 也不是 null，我们通过 Object.keys(arr) 也读取不到稀疏项对应的 index

   - 而在循环逻辑中只有 `pk in o` 为 `true` 的情况下才会执行 callback，所以遇到稀疏项会自动跳过