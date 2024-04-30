---
title: Leetcode
date: 2024-03-18T10:29:00+08:00
sidebar-position: 4
authors: gsemir
tags: [algorithm, leetcode]
---

```js
let v1 = version1.split('.')
let v2 = version2.split('.')
// 如果一次循环需要遍历多个数组
// 那么遍历限制条件就需要找到两者最大的
// 然后不够的补充上 或者给默认值
const len = Math.max(v1.length, v2.length)
while (v1.length < len) v1.push('0')
while (v2.length < len) v2.push('0')
for (let i = 0; i < len; i++) {}
```

二分法模板

任何数和自己做异或运算，结果为 000，即 a⊕a=0a⊕a=0a⊕a=0 。
任何数和 000 做异或运算，结果还是自己，即 a⊕0=⊕a⊕0=⊕a⊕0=⊕。
异或运算中，满足交换律和结合律，也就是 a⊕b⊕a=b⊕a⊕a=b⊕(a⊕a)=b⊕0=ba⊕b⊕a=b⊕a⊕a=b⊕(a⊕a)=b⊕0=ba⊕b⊕a=b⊕a⊕a=b⊕(a⊕a)=b⊕0=b。

链表遍历

```
var removeElements = function (head, val) {
  let pre = new ListNode(0, head);
  let cur = pre
  while (cur.next) {
    if (cur.next.val === val) {
      cur.next = cur.next.next
    } else {
      cur = cur.next;
    }
  }
  // 只判断 cur.next 而不是 cur 本身的好处在于
  // 无需额外定义 pre 指针
  return pre.next
};
```

如果需要两个指针 pre 和 cur， 那么就将 pre 的初始值设置为 new ListNode(-1, head)

