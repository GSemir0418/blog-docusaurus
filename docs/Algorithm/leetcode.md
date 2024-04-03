---
title: Leetcode
date: 2024-03-18T10:29:00+08:00
sidebar-position: 4
authors: gsemir
tags: [algorithm, leetcode]
---

[1] 两数之和

```js
/**
 * @param {number[]} nums
 * @param {number} target
 * @return {number[]}
 */
var twoSum = function (nums, target) {
  const m = new Map()
  for (let i = 0; i < nums.length; i++) {
    if (m.has(target - nums[i])) {
      return [i, m.get(target - nums[i])]
    }
    m.set(nums[i], i)
  }
};
```

二分法模板

任何数和自己做异或运算，结果为 000，即 a⊕a=0a⊕a=0a⊕a=0 。
任何数和 000 做异或运算，结果还是自己，即 a⊕0=⊕a⊕0=⊕a⊕0=⊕。
异或运算中，满足交换律和结合律，也就是 a⊕b⊕a=b⊕a⊕a=b⊕(a⊕a)=b⊕0=ba⊕b⊕a=b⊕a⊕a=b⊕(a⊕a)=b⊕0=ba⊕b⊕a=b⊕a⊕a=b⊕(a⊕a)=b⊕0=b。

作者：御三五 🥇
链接：https://leetcode.cn/problems/single-number/solutions/655425/wu-tu-guan-fang-tui-jian-ti-jie-zhi-chu-2ttk9/
来源：力扣（LeetCode）
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
