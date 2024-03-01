---
title: LocalStorage 实现过期功能
date: 2023-12-18T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
---

#### 思路

localStorage 本身是没有数据过期机制的，可以参考 cookie 过期的特性，通过其他手段来扩展，使其满足我们对数据过期的要求

- 存入数据时，要传入过期时间

- 获取数据时，判断是否过期，过期返回 undefined，否则正常返回数据

> localStorage 和 sessionStorage 都继承自 Storage 对象，我们可以扩展 Storage 原型方法

#### API 设计

- `setItemWithAge(key, value, age)`

- `getItemWithAge(key)`

```js
Storage.prototype.setItemWithAge = (key, value, age) => {
  if (isNaN(Number(age)))
    throw new Error("age must be a number");
  const obj = {
    data: value,
    time: Date.now(),
    maxAge: Number(age)
  }
  localStorage.setItem(key, JSON.stringify(obj))
}

Storage.prototype.getItemWithAge = (key) => {
  if (localStorage.getItem(key)) {
    const { data, time, maxAge } = JSON.parse(localStorage.getItem(key))
    if (time + maxAge < Date.now()) {
      localStorage.removeItem(key)
      return undefined
    }
    return data
  }
}
```

