---
title: Leetcode
date: 2024-03-18T10:29:00+08:00
sidebar-position: 4
authors: gsemir
tags: [algorithm, leetcode]
---

### 大数相加、字符串相加

以长的为准，转成数组，不够填零，遍历按位相加，注意边界

```js
// 转成数组
const arr1 = Array.from(num1).reverse()
// 不够填零
if(arr1.length < maxString) arr1.push(...new Array(maxString - arr1.length).fill(0))
// 按位相加
for(let i = 0; i < maxString; i++) {
  // 按位相加
  const sum = Number(arr1[i]) + Number(arr2[i])
  // 如果大于 10 且下一位有数据
  if(sum >= 10 && arr1[i + 1] !== undefined) {
    // 结果 -10
    result = result + sum - 10
    // 下一位 +10（模拟进位）
    arr1[i + 1] = Number(arr1[i + 1]) + 1
  } else {
    result = result + sum
  }
}
```

### 无重复字符的最长子串

中间数组，用于边记录边更新结果，

记录之前先找中间数组有没有这个字符，如果有就**删掉这个重复字符及之前的全部**字符，相当于重新统计

```js
for (let i = 1; i < s.length; i++) {
  const index = mArr.indexOf(s[i])
  if (index > -1) {
    // 如果 mArr 中存在该字符，说明找到了重复字符
    // 删除重复字符及之前的全部字符，相当于重新开始
    mArr.splice(0, index + 1)
  }
  mArr.push(s[i])
  result = Math.max(result, mArr.length)
}
```

### Z 字形变换

准备二维数组

```
// DBUGBEFSMC
[
[D,G,F,C],
[B,B,S],
[U,E,M]
]
```

两个变量，y 表示第几行，down 表示方向，

反复横跳，到底就改变方向并 y++，到顶就改变方向并 y--

```js
if (down) {
  // 如果到达最底部，改变方向
  if (y === numRows - 1) {
    down = false;
    y--;
  } else {
    y++;
  }
} else {
  // 如果到达最顶部，改变方向
  if (y === 0) {
    down = true;
    y++;
  } else {
    y--;
  }
}
```

### 回文数

头尾两个指针ij，遍历这个数字字符串数组

如果字符相等 一个++一个--继续遍历，继续遍历前判断 ij，如果j--之后小于 i，直接返回true。否则直接返回 false

### 罗马

先定义数字与字符的映射关系

规则：如果下一个字符比当前字符数字大，结果就要减去这位数，否则就正常加

```js
for (let i = 0; i < s.length; i++) {
  let cur = m.get(s[i]);
  let next = m.get(s[i + 1]);
  // 如果下一位比这位大，要减去这位数
  // 如果下一位比这位小，就正常加
  if (next > cur) {
    res -= cur
  } else {
    res += cur
  }
}
```

### 最长公共前缀

两个循环，一个循环最外层的单词，另一个循环单词中的字符

以第一个单词为准，其中每一位字符都与剩余其他单词对应位置的字符进行比较

### 有效的括号

定义括号的映射

利用栈收集左括号，遇到右括号就 pop 一次

pop之前还要检查要弹出的（最后一项）是不是跟这个左括号对应的

### 合并有序链表

初始化两个链表 result => -1 <= cur

遍历，对比 l1 和 l2，cur.next 指向较小的节点，同步更新较小的那个链表 l = l.next，然后更新 cur = cur.next，开始下一次遍历。直到 l1 或 l2 指向 null

然后把 cur.next 指向某个有剩余节点的链表即可

最后返回 result.next

```js
var mergeTwoLists = function (list1, list2) {
  // 初始化结果链表头节点
  const result = new ListNode(-1);

  // 结果链表的指针
  let cur = result;
  // 直到其中一个链表遍历到终点
  while (list1 != null && list2 != null) {
    // 把 prev 指向值小的那个节点
    // 然后小的节点指针前移
    if (list1.val <= list2.val) {
      cur.next = list1;
      list1 = list1.next;
    } else {
      cur.next = list2;
      list2 = list2.next;
    }
    // 更新节点指针，继续下一次遍历
    cur = cur.next;
  }

  // 合并后 l1 和 l2 最多只有一个还未被合并完，直接将链表末尾指向未合并完的链表即可
  cur.next = list1 === null ? list2 : list1;

  // 返回除了头节点的链表
  return result.next;
};
```

### 原地删除有序数组中的重复项

快慢指针，快指针持续向前走，而慢指针相当于在统计不同的数据的数量（slow + 1)

若快指针的值与慢指针的值相同，说明遇到重复的了，则更新慢指针的位置，继续遍历；否则继续，相当于快的继续走，慢的停一次

删除的话，就是当遇到不重复的值时，将 slow ++ 后的位置的值替换成当前 fast 位置的新值即可

```js
var removeDuplicates = function(nums) {
  let slow = 0
  
  for (let fast = 1; fast < nums.length; fast++) {
    if (nums[fast] !== nums[slow]) {
      // 不相等才动 slow，否则继续 fast 遍历
      slow += 1
      // 实现删除的效果：将（+1后的） slow 位置的值替换成当前 fast 位置遍历的值
      nums[slow] = nums[fast]
    }
    // 相等就继续
  }

  return slow + 1
};
```

### 原地移除数组某个元素

使用 splice 移除元素会造成 index 错位，导致跟遍历的 i 对不上，所以这里使用倒序遍历

### 找出字符串中第一个匹配项的下标

while 双指针

i 表示匹配项 needle 的下标；j 表示字符串 haystack 的下标，同时也是返回的结果

while (i < needle.length && j < haystack.length) 遍历

此时 i + j 就是 haystack 的遍历 index，因为每次循环都会 i++ 或 j++

比较 haystack[i + j] 与 needle[i]，一致则 i++ ，否则 i 置为 0，j++ 继续遍历 haystack

如果循环结束，needle 完全遍历完了，说明找到了完全匹配的字符，返回 j 即可；否则返回 -1

### 排序数组查找元素出现（第一个和最后一个）位置，

排序，查找 => 二分法

1. 定义左右指针
2. while(left < right)
3. 每次遍历找到中间指针 mid，然后根据中间值与目标值的大小，更新 left 或 right 指针为 mid + 1 或 mid - 1

```js
/**
 * 二分查找模板
 * @param {number[]} nums - 有序数组
 * @param {number} target - 目标值
 * @return {number} - 目标值在数组中的索引，若不存在则返回 -1
 */
const binarySearch = (nums, target) => {
  let left = 0;
  let right = nums.length - 1;

  while (left < right) {
    let mid = Math.floor((right - left) / 2);

    if (nums[mid] === target) {
      return mid; // 目标值等于中间值，返回索引
    } else if (nums[mid] < target) {
      left = mid + 1; // 目标值在右半部分，更新左指针
    } else {
      right = mid - 1; // 目标值在左半部分，更新右指针
    }
  }

  return -1; // 未找到目标值，返回-1
};
```

### 找第一个和最后一个位置

那就找两次，第一次找 left 即第一次出现的位置，然后重置 right 进行第二次找 right

区别在于循环中对于**中间索引取值**的逻辑以及 **left 和 right 的处理**逻辑

- 中间索引取值公式：

  - 第一次出现的位置（左边界）
    - `let mid = Math.floor((right + left) / 2);`
    - floor 会让 `mid` 偏向左边。

  - 最后一次出现的位置（右边界）
    - `let mid = Math.floor((left + right + 1) / 2);`
    - 这样计算会让 `mid` 偏向右边

- left 和 right 的处理逻辑

  - 第一次出现的位置（左边界）
    - 要使中间值始终**大于等于**目标值，等号放在大于的地方，然后不断矫正右指针为 mid
  - 最后一次出现的位置（右边界）
    - 要使中间值始终**小于等于**目标值，等号放在小于的地方，然后不断矫正左指针为 mid

```js
const binarySearchFirst = (nums, target) => {
  let left = 0;
  let right = nums.length - 1;

  while (left < right) {
    // mid 偏右
    let mid = Math.floor((right + left) / 2);

    if (nums[mid] >= target) {
      // 中间值大于等于目标值，说明目标值第一次出现的位置在左半部分
      // 更新右指针
      right = mid
    } else {
      // 更新左指针，
      // 因为确定了 mid 不是目标值的位置，所以 + 1
      left = mid + 1
    }
  }

  if(nums[left] === target) {
    return left
  }

  return -1
}
```

最后一次出现的位置就要从 right 指针下手

```js
const binarySearchLast = (nums, target) => {
  let left = 0;
  let right = nums.length - 1;

  while (left < right) {
    // mid 偏右
    let mid = Math.floor((left + right + 1) / 2);

    if (nums[mid] <= target) {
      // 中间值小于等于目标值，说明目标值在右半部分
      // 更新左指针为 mid
      left = mid
    } else {
      // 更新右指针，
      // 因为确定了 mid 不是目标值的位置，所以 - 1
      right = mid - 1
    }
  }

  if(nums[right] === target) {
    return right
  }

  return -1
}
[0,1,2,3] 
3-0 / 2 = 1 偏左
3+0+1 / 2 =2 偏右
[0,1,2]
2-0 / 2 = 1 正好
2+0+1 / 2 = 1 正好
```

### 平方根

求平方根也可以用二分法，因为平方根问题可以转化为在一维有序数列上查找特定值的问题

初始化 left 和 right 为 `let left = 1, right = Math.floor(x / 2);`

对于任何数 `x` 大于等于 1，其平方根都不可能超过 `x / 2`。例如，16 的平方根是 4，而不是 8。因此，将右边界设为 `Math.floor(x / 2)` 可以减少查找范围，加快二分查找速度。

while 循环条件是 left <= right，最后返回 right

### 螺旋二维数组

定义坐标及步长，步长的正负表示方向

定义是否转向的辅助判断函数：下一位置的值是否有效

使用 while 死循环，当转向后，再次判断下一位置是否有效，无效则退出

转向逻辑：

- 横向要改成竖向，交换 iStep 和 jStep，然后 jStep 纵向步长置为 0

- 竖向要改成横向：交换 jStep 和 iStep，因为从竖到横就开始反向运动了，直到下一次从竖到横，所以在这里变号，然后 iStep 横向步长置为 0

```js
var spiralOrder = function (matrix) {
  const result = []

  // 定义坐标及步长（正负号表示方向）
  let i = 0, j = 0, iStep = 0, jStep = 1

  // 下一坐标是否越界
  function _isBlock() {
    return matrix[i + iStep] === undefined || matrix[i + iStep][j + jStep] === undefined
  }

  while (1) {
    result.push(matrix[i][j])
    // 置为 undefined 方便后续判断是否越界或 break
    matrix[i][j] = undefined

    // 如果越界了，要改变方向
    if (_isBlock()) {
      // 横向要改成竖向；竖向要改成横向
      if (iStep === 0) {
        // iStep 为 0，说明之前一直在横向移动，要改成竖向了
        // 横 => 竖，交换 iStep 和 jStep，然后 jStep 纵向步长置为 0
        iStep = jStep
        jStep = 0
      } else {
        // iStep 不为 0，说明之前一直在竖向移动，要改成横向了
        // 竖 => 横，交换 jStep 和 iStep，这里要将 jStep 置为负的，
        // 因为从竖到横就开始反向运动了，直到下一次从竖到横，所以在这里变号
        // 然后 iStep 横向步长置为 0
        jStep = -iStep
        iStep = 0
      }
      // 退出条件：如果改了方向后的下一步仍然越界，说明到头了，所有字段都被处理为 undefined 了
      if (_isBlock()) {
        break
      }
    }

    // 移动至下一步
    i += iStep
    j += jStep
  }
  return result
}
```



树的遍历

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
```js
/**
 * 二分查找模板
 * @param {number[]} nums - 有序数组
 * @param {number} target - 目标值
 * @return {number} - 目标值在数组中的索引，若不存在则返回 -1
 */
const binarySearch = (nums, target) => {
  let left = 0;
  let right = nums.length - 1;

  while (left <= right) {
    let mid = left + Math.floor((right - left) / 2);

    if (nums[mid] === target) {
      return mid; // 目标值等于中间值，返回索引
    } else if (nums[mid] < target) {
      left = mid + 1; // 目标值在右半部分，更新左指针
    } else {
      right = mid - 1; // 目标值在左半部分，更新右指针
    }
  }

  return -1; // 未找到目标值，返回-1
};
```
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

