---
sidebar-position: 3
title: Fiber与双缓冲
date: 2024-05-03
authors: gsemir
tags: [react, fiber]
---

# Fiber与双缓冲

## Fiber

Fiber 可以从三个方面去理解

- Fiber 作为一种**架构**，在 React v16 之前的版本中，Reconciler 采用的是递归的方式，因此被称之为 Stack Reconciler，到了 16 版本之后引入了 Fiber，Reconciler 也从 Stack Reconciler 变为了 `Fiber Reconciler`，各个 FiberNode 之间通过链表的形式串联（`return`、`child`、`sibling`）了起来

```js
function FiberNode(tag, pendingProps, key, mode) {
	// ...
  
  // 周围的 FiberNode 通过链表的形式进行关联
	this.return = null
	this.child = null
	this.sibling = null
	this.index = 0
  
  // ...
}
```

- Fiber 作为一种**数据模型**：FIber 本质上也是一个**对象**，是之前 VDOM 对象（React 元素，createElement 的返回值）的一种**升级版本**，每个 Fiber 对象里面会包含 React 元素的类型，周围链接的 FiberNode，DOM 相关信息（stateNode）等

> 在React的Fiber架构中，`FiberNode`是每一个React元素的内部数据结构表示：
>
> - `tag`属性用来区分 **Fiber 的类型**，比如：是class组件(`ClassComponent`)、函数组件(`FunctionComponent`)、宿主组件（如`div`、`span`等DOM元素，对应`HostComponent`），或者其他类型，便于React正确处理不同类型的元素。
> - `type`属性则存储着对应React元素的**具体类型信息**，例如宿主组件的字符串（如'div'、'span'），或者函数/类组件的实际函数或类。
> - `flags`属性记录着当前Fiber和其子树中需要进行的**操作类型**，比如插入(`Placement`)、更新(`Update`)或删除(`Deletion`)等，告诉Reconciler如何协调和提交更改到DOM上。
>
> 在React源码中，这些属性是如何定义、更新和使用的核心环节，决定了组件的行为和最终更新到DOM中的方式。简单来说，`tag`决定了处理方式，`type`决定了具体是什么，而`flags`告诉React接下来要做哪些更新操作。

```js
function FiberNode(tag, pendingProps, key, mode) {
	// 类型
	this.tag = tag
	this.key = key
	this.elementType = null
	this.type = null
	this.stateNode = null // 映射真实DOM
  
  // ...
}
```

- FiberNode 作为**动态的工作单元**：在每个 FiberNode 中，保存了本次更新中该 React 元素变化的数据、要执行的工作（增、删、改、更新 Ref）以及副作用等信息

```js
function FiberNode(tag, pendingProps, key, mode) {
	// ...
	
	// 副作用相关
	this.flags = NoFlags
	this.subtreeFlags = NoFlags
	this.deletions = null
	// 与调度优先级有关
	this.lanes = NoLanes
	this.childLanes = NoLanes
}
```

> 为什么指向父 FiberNode 的字段叫做 `return` 而非 `parent`
>
> 因为作为一个动态的工作单元，return 指代的是 FiberNode 执行完 `completeWork` 后返回的下一个 FiberNode，这里会有一个**返回的动作**，因此通过 return 来指代父 FiberNode

## 双缓冲工作原理

Fiber 架构中的双缓冲工作原理类似与*显卡*的工作原理

显卡分为前缓冲区和后缓冲区，首先，前缓冲区会显示图像，之后，合成的新图像会被写入到后缓冲区，一旦后缓冲区写入图像完毕，就会前后缓冲区进行一个互换，这种将数据保存在缓冲区再进行互换的技术，就被称之为双缓冲技术

Fiber 架构同样用到了这个技术，在 Fiber 架构中，同时存在**两颗 Fiber Tree**，一颗是真实 UI 对应的 `Current Fiber Tree`，可以被类比为显卡的前缓冲区；另外一颗是在内存中构建的 `WorkInProgress Fiber Tree`，可以类比为显卡的后缓冲区，两棵树的 FiberNode 会通过 `alternate` 属性相互指向。

接下来我们从首次渲染和更新这两个阶段来看一下 FiberTree 的形成以及双缓存机制

### mount 阶段

首先最顶层有一个 FiberNode，称之为 `FiberRootNode`，该 FiberNode 会有一些自己的任务

- Current Fiber Tree 与 WIP Fiber Tree 之间的切换
- 应用中的过期时间
- 应用的任务调度信息

以如下代码为例

```jsx
<body>
	<div id="root"></div>
</body>

function App() {
  const [num, add] = useState(0)
  return (
  	<p onClick={() => add(num + 1)}>{num}</p>
  )
}
const rootElement = document.getElementById("root")
ReactDOM.createRoot(rootElement).render(<App />)
```

当执行 `ReactDOM.createRoot` 的时候，会创建如下的结构

![image-20240504203427115](.\images\react-32.png)

此时会基于 root div 生成一个 `HostRootFiber`，FiberRootNode 通过 `current` 来指向 HostRootFiber

接下来进入到 `mount` 流程，该流程会基于每个 React 元素以深度优先的原则依次生成 WIP FiberNode，并且每一个 WIP FiberNode 会连接起来，如下图所示，**右侧为 WIP Fiber Tree**

![image-20240504202306168](.\images\react-31.png)

生成的 WIP Fiber Tree 里面的每一个 FiberNode 会和 Current Fiber Tree 里面的 FiberNode 进行关联，关联的方式就是通过 `alternate` 属性。但是目前左侧的 Current Fiber Tree 里面只有一个 HostRootFiber，因此就只有这个 HostRootFiber 进行了 alternate 关联

当 WIP Fiber Tree 生成完毕后，也就意味着 Render 阶段完毕了，此时 FiberRootNode 就会被传递给 Renderer，进入 Commit 阶段。渲染工作完毕后，浏览器中就显示了对应了 UI，此时 `FiberRootNode.current` 就会指向这颗 WIP Fiber Tree，也就是说，曾经的 WIP Fiber Tree 就成为了 Current Fiber Tree，完成了第一次的双缓冲

![image-20240504203842923](.\images\react-33.png)

### update 阶段

点击 p 元素，会触发更新，这一操作就会开启 `update` 流程，此时就会生成一颗新的 WIP Fiber Tree（如图左）。新的 WIP Fiber Tree 里面的每一个 FiberNode 和 Current Fiber Tree 的每一个 FiberNode 通过 `alternate` 属性进行关联

![image-20240505000937514](.\images\react-34.png)

当 WIP Fiber Tree 生成完毕后，FiberRootNode 会被传递给 Renderer 进行 Commit 阶段的 UI 渲染，此时宿主环境所渲染出来的真实 UI 对应的就是左边 WIP Fiber Tree 所对应的 DOM 结构，`FiberRootNode.current` 就会指向左边这棵树，右边的树就再此成为了新的 WIP Fiber Tree

### 总结

所谓 Fiber 双缓冲树，指的是在内存中构建两棵树，并直接在内存中进行替换的技术。

在 React 中使用 `Wip Fiber Tree` 和 `Current Fiber Tree` 这两颗树来实现更新的逻辑。Wip Fiber Tree 在内存中完成更新，而 Current Fiber Tree 是最终要渲染的树，两棵树通过 `alternate` 指针相互指向，**这样在下一次渲染的时候，直接复用 Wip Fiber Tree 作为下一次的渲染树，而上一次的渲染树又作为新的 Wip Fiber Tree**，这样可以**加快 DOM 节点的替换与更新效率**