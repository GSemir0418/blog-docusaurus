---
sidebar-position: 7
title: React 中的位运算
date: 2024-05-07
authors: gsemir
tags: [react, binary, fiber]
---

# React中的位运算

## 位运算

| 十进制   | 0    | 1    | 2    | 3    | 4    | 5    | 6    | 7    | 8    | 9    | 10   | 11   | 12   | 13   | 14   | 15   |
| -------- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
| 二进制   | 0000 | 0001 | 0010 | 0011 | 0100 | 0101 | 0110 | 0111 | 1000 | 1001 | 1010 | 1011 | 1100 | 1101 | 1110 | 1111 |
| 八进制   | 0    | 1    | 2    | 3    | 4    | 5    | 6    | 7    | 10   | 11   | 12   | 13   | 14   | 15   | 16   | 17   |
| 十六进制 | 0    | 1    | 2    | 3    | 4    | 5    | 6    | 7    | 8    | 9    | A    | B    | C    | D    | E    | F    |

基于二进制的位运算能够很方便的表达「增」、「删」、「改」、「查」

例如后台管理系统中的**复杂权限控制**就可以使用二进制来表示与操作；还有 linux 的文件权限系统

### 与二进制有关的运算

- 与（`&`）：有 0 就是 0

```js
1 & 0 = 0
0000 0001
0000 0000
---------
0000 0000
```

- 或（`|`）：有 1 就是 1

```js
1 | 0 = 1
0000 0001
0000 0000
---------
0000 0001
```

- 非（`~`）：0 1 互换

```js
~1 = -2
0000 0001
---------
1111 1110
```

- 异或（`^`）：同为 0，异为 1

```js
1 ^ 0 = 1
0000 0001
0000 0000
---------
0000 0001
```

> 所有这些操作除了按位非（`~`）会将操作数视为32位，其他操作会按JavaScript中的数字类型来进行操作，通常是视为32位的有符号整数来运算。需要注意的是，因为JavaScript中的数字都是以64位浮点数形式存储的，位运算符会将其操作数转换为32位整数，进行位运算后再转换回64位浮点数。

### 位运算在权限系统中的应用

| 下载 | 打印 | 查看 | 审核 | 详情 | 删除 | 编辑 | 创建 |
| ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
| 0    | 0    | 0    | 0    | 0    | 0    | 0    | 0    |

如果对应的位置是 0，说明没有对应权限

例如 0000 0001 表示只有创建的权限；0010 0111 说明有增删改查的权限

**添加权限**

使用`或（|）`来添加权限，例如给 0000 0001 添加删除和编辑的权限：

```js
0000 0001
0000 0110
---------
0000 0111
```

**删除权限**

使用`异或（^）`来删除权限，例如给 0010 0111 删除创建的权限

```js
0010 0111
0000 0001
---------
0010 0110
```

**判断是否有某权限**

使用`与（&）`来判断是否有某权限，例如判断 0010 0111 是否有删除的权限

```js
0010 0111
0000 0100
---------
0000 0100
// 结果与删除权限一致，说明有删除权限
// 结果为 0，说明没有
```

## React 中的位运算

- Fiber 的 flags 属性
- lane 模型
- 上下文

### Fiber 的 flags 属性

使用二进制标记 fiber 操作的 flags

```js
export const NoFlags = /*                      */ 0b0000000000000000000000000000;
export const PerformedWork = /*                */ 0b0000000000000000000000000001;
export const Placement = /*                    */ 0b0000000000000000000000000010;
export const DidCapture = /*                   */ 0b0000000000000000000010000000;
export const Hydrating = /*                    */ 0b0000000000000001000000000000;
```

这些 flags 就是用来标记 fiber 状态的

针对一个 fiber 的操作，可能有增加、删除、修改。当状态变更时，不直接进行操作，而是使用二进制数字给这个 fiber 标记一个 flag，在后续流程中**统一**对这个 fiber 进行操作

通过位运算，就可以很好地解决一个 fiber 有多个 flag 标记的问题，方便**合并**（新增）多个状态

```js
// 初始化 flags
const NoFlags = /*                      */ 0b0000000000000000000000000000;
const PerformedWork = /*                */ 0b0000000000000000000000000001;
const Placement = /*                    */ 0b0000000000000000000000000010;

let flag = NoFlags

// 使用或运算合并（新增）状态
flag = flag | PerformedWork | Placement

// 使用与运算判断是否具有某个状态
if(flag & PerformedWork) {
  // 执行 performedWork
}
```

### lane 模型

lane 模型也是一套优先级的机制，相比与 Scheduler，lane 模型能够对任务进行更细粒度的控制

```js
export const NoLane: Lane = /*                          */ 0b0000000000000000000000000000000;

export const SyncLane: Lane = /*                        */ 0b0000000000000000000000000000010;

export const InputContinuousHydrationLane: Lane = /*    */ 0b0000000000000000000000000000100;
export const InputContinuousLane: Lane = /*             */ 0b0000000000000000000000000001000;
```

例如在 React 源码中，从一套 lanes 中分离出优先级最高的 lane

```js
function getHighestPriorityLanes(lanes) {
	switch (getHignestPriorityLane(lanes)) {
		case SyncLane:
			return SyncLane
		case InputContinuousLane:
			return InputContinuousLane
		// ...
	}
}
// 从一套 lanes 中分离出优先级最高的 lane（假设 1 越靠近右侧，表示优先级越高）
export function getHighestPriorityLane(lanes) {
  return lanes & -lanes
}

// 假设我们现在针对这两个 lane 进行合并
export const SyncLane = 0b0000000000000000000000000000001;
export const InputContinuousLane = 0b0000000000000000000000000000100;

0b0000000000000000000000000000001
0b0000000000000000000000000000100
---------------------------------
0b0000000000000000000000000000101

// 对结果取负值
-lanes => 0b1111111111111111111111111111011
// 再对本身做与操作
0b1111111111111111111111111111011
0b0000000000000000000000000000101
---------------------------------
0b0000000000000000000000000000001

// 得到的结果就是最高优先级的 lane
```

### 上下文

在 React 源码内部，有多个上下文

```js
// 未处于 React 上下文
export const NoContext = 0b000
// 处于 render 阶段
export const RenderContext = 0b010
// 处于 commit 阶段
export const CommitContext = 0b100
```

当执行流程到了 Render 阶段，就会切换上下文，切换到 RenderContext

```js
let executionContext = NoContext
executionContext |= RenderContext
```

在执行方法的时候，就会有一个判断，判断当前处于哪一个上下文

```js
// 是否处于 RenderContext 中
(executionContext & RenderContext) !== NoContext
// 是否处于 CommitContext 中
(executionContext & CommitContext) !== NoContext
```

## 总结

位运算可以很方便地**标记某种状态**（例如复杂权限控制），且**增删改查**的操作也比较**简洁高效**

在 react 内部，像 fiber 的 **flags**（fiber 状态标记与合并）、**优先级**（getHighestPriorityLane）、**上下文**环境等都使用到了位运算