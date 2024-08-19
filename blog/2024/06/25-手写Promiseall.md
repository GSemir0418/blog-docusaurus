---
title: 手写 Promise 工具函数
date: 2024-06-25T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [promise, all, race]
---

### Promise.all

1. 不是原型方法，所以写在 Promise 构造函数中。返回值是一个 promise

```js
Promise.myAll = function (proms) {
  return new Promise((resolve, reject) => {
  })
}
```

2. 处理边界情况。Promise.all 接收的是**任意的可迭代对象**，不能单纯使用 length 或 size 来判断参数长度。这里利用 for of 来遍历并计数

```diff
Promise.myAll = function (proms) {
  return new Promise((resolve, reject) => {
+   let i = 0
+   for (const prom of proms) {
+     i++
+   }
+   if (i === 0) { resolve([]) }
  })
}
```

3. 遍历执行。将参数中每个任务包装为子 Promise，当某个子 Promise 报错时，整个 Promise 置为 reject 状态

```diff
Promise.myAll = function (proms) {
  return new Promise((resolve, reject) => {
    let i = 0
    for (const prom of proms) {
      i++
+     Promise.resolve(prom)
+     	.catch(e => {
+       	reject(e)
+     	})
    }
    if (i === 0) { resolve([]) }
  })
}
```

4. 维护结果数组，在每个子 Promise 返回结果后，将结果放入结果数组的对应项

```diff
Promise.myAll = function (proms) {
  return new Promise((resolve, reject) => {
    let i = 0
    const result = []
    for (const prom of proms) {
    	// 缓存 index 位置
+     let index = i
      i++
      Promise.resolve(prom)
+     	.then(r => {
+       	result[index] = r
+     	})
      	.catch(e => {
        	reject(e)
      	})
    }
    if (i === 0) { resolve([]) }
  })
}
```

5. 每当一个任务结束，就执行 i--，直到任务全部处理完，整个 Promise resolve 即可
   - 因为当代码执行到 then 回调时，for 循环已经结束，i 已经完成任务计数，所以不会与 i++ 发生冲突

```diff
Promise.myAll = function (proms) {
  return new Promise((resolve, reject) => {
    let i = 0
    const result = []
    for (const prom of proms) {
      let index = i
      i++
      Promise.resolve(prom)
      .then(r => {
        result[index] = r
+       i--
+       if (i === 0) {
+         resolve(result)
+       }
      })
      .catch(e => {
        reject(e)
      })
    }
    if (i === 0) { resolve([]) }
  })
}
```

### Promise.race

同样接受一个 promise 可迭代对象，返回最快的那个 promise 的结果或错误即可

```js
Promise.myRace = function (proms) {
  // 同样返回 promise
  return new Promise((resolve, reject) => {
    let i = 0
    for (const p of proms) {
      i++
      // 遍历，只要某个子 promise 有结果了，就作为整体 Promise 的结果 resolve 或 reject
      Promise.resolve(p)
        .then((result) => {
          resolve(result)
        })
        .catch((err) => {
          reject(err)
        })
    }
    // 边界情况
    if(i === 0) resolve([])
  })
}
```

### Promise.allSettled

allSettled 与 all 的区别在于对错误的处理方式

- 只要有错，all 就直接返回错误，而 allSettled 会将错误也作为结果
- allSettled 结果的数据结构为 `{ status: 'fulfilled' | 'rejected', [value | reason]: any }`

```diff
Promise.myAllSettled = function (proms) {
  return new Promise((resolve, reject) => {
    let i = 0
    const result = []
    for (const prom of proms) {
      let index = i
      i++
      Promise.resolve(prom)
      .then(r => {
-     	result[index] = r
+       result[index] = { status: 'fulfilled', value: r }
        i--
        if (i === 0) {
          resolve(result)
        }
      })
      .catch(e => {
-     	reject(e)
+       result[index] = { status: 'rejected', reason: e }
+       i--
+       if (i === 0) {
+         resolve(result)
+       }
      })
    }
    if (i === 0) { resolve([]) }
  })
}
```

