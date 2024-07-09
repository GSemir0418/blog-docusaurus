---
title: WeakMap 与 WeakSet
date: 2024-05-17T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [javascript, weakmap, weakset]
---

`Map` 和 `Set` 都是 ES6 中引入的表示**集合**的数据结构

- Map 表示「**键值对**」的集合
  - **有序**，插入的顺序
  - 支持 set get has size delete clear
  - 键为**任意类型**的值
  - **可以遍历**

- Set 表示「**不重复值**」的集合
  - **元素唯一**，**无序**
  - 支持 add has delete clear
  - **可以遍历**

`WeakMap` 和 `WeakSet` 类似与 Map 和 Set

- WeakMap 
  - 键**必须为对象**
  - 键名都是**弱引用**
  - **不能遍历**
- WeakSet
  - 元素**必须为对象**
  - 成员都是**弱引用**
  - **不能遍历**

> **「弱」主要体现在垃圾回收机制面前的地位**

如果一个对象有引用，那么垃圾回收器就不会被回收

而 WeakMap 中的键（对象）以及 WeakSet 中的元素（对象）这两种引用方式，都不在垃圾回收机制考虑范围内，该回收照样会被回收

这也是为什么 WeakMap 和 WeakSet 不支持遍历的原因（键或元素可能会被垃圾回收掉）