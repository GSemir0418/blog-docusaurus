---
title: null与undefined
date: 2024-03-18T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [javascript, 'null', undefined]
---

参考文章：[阮一峰：undefined与null的区别](https://www.ruanyifeng.com/blog/2014/03/undefined-vs-null.html)

`undefined` 与 `null` 都表示**「无」**，但 `null` 无的**更具体**，`undefined` 无的**不具体**

`null` 表示**无对象**，转为数值时为 `0`；`undefined` 表示**无（原始）值**，转为数值时为 `NaN`

>undefined 表示「缺少值」，就是此处应该有一个值，但是还没有定义 
>
>（1）变量被声明了，但没有赋值时，就等于 undefined。
>
>（2) 调用函数时，应该提供的参数没有提供，该参数等于 undefined。
>
>（3）对象没有赋值的属性，该属性的值为 undefined。
>
>（4）函数没有返回值时，默认返回 undefined。
>
>null 表示「没有对象」，即该处不应该有值。
>
>（1） 作为函数的参数，表示该函数的参数不是对象。
>
>（2） 作为对象原型链的终点。

