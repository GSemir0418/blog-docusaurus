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

如果需要两个指针 pre 和 cur， 那么就将 pre 的初始值设置为 new ListNode(-1, head)

#### js

1. 为什么会出现变量提升

2. js的垃圾回收机制是怎么实现

3. 内存泄露有哪些情况

   通过开发者工具中的`Performance`模块，可以对页面加载和执行流程进行录制，之后在录制快照里查看内存的使用情况。如果发现有内存异常，则可以进一步缩小排查范围，最终找到引发内存泄露的代码。

4. 有哪些技术手段可以用来监控内存泄露

5. NodeJS中模块的循环引用会出现什么效果

6. CommonJS的导入规则和导入时的代码执行流程

7. 为什么要用setTimeout

8. 说一说Promise的实现
9. 分析结果及原因

```
结果和原因
var foo = 1;
function fn() {
    foo = 3;
    return;
    funciton foo() {
        // todo
    }
}
fn();
console.log(foo);
```

#### web安全

浏览器同源策略：

1. 现代浏览器以及`HTTPS`会对非同源的请求进行拦截以保证安全
2. 若请求链接中的协议、主机名、端口、方法等任何一个不一样，都是不同源请求

CSP：

1. 内容安全策略，可以在HTML中的`meta`标签或者服务端返回的`Content-Secrity-Policy`头中进行设置
2. 可以指定资源的请求域、资源的加载方式等

XSS：

1. `跨站脚本攻击`，分为了持久型XSS、反射型XSS和DOM型XSS
2. 持久型XSS是最常见的XSS攻击，主要通过输入框、富文本等组件输入一些恶意的脚本代码，存储到服务端之后，当其他用户打开页面加载该脚本时便出现攻击行为
3. 反射型XSS是需要用户点击黑客提供的恶意链接，该恶意链接会在跳转到正常页面的同时执行黑客脚本
4. DOM型XSS存在于一些第三方插件中，如浏览器插件去恶意修改页面DOM等方式
5. 对于XSS的防范主要是防范持久型XSS，在页面的输入框和富文本提交时对字符串做过滤处理，同时在页面中只对可信的HTML文本做解析

CSRF：

1. `跨站请求伪造`，当用户在正常的网站登录之后，由于同源请求会默认携带Cookie，因此黑客可以在自己的网站中向正常网站发送伪造请求来冒充用户自己的操作
2. 攻击方式主要包含通过标签的src属性、href属性以及form的action属性等，通常是伪造`GET`请求
3. 防范方式包含使用`POST`请求处理资源、服务端验证请求的`Referer`、禁止第三方网站请求携带Cookie以及最后在请求时增加`csrftoken`字段做校验

#### 管理

1. 聊一聊管理上做的事情

> 招聘：
>
> 1. 招聘的话比较简单，主要就是找人、然后面试等

> 业务：
>
> 1. 需求评审之前：根据每个人的时间情况和需求内容，完成需求的分配
> 2. 需求评审之后：由开发同学进行任务的拆解、估时，之后我会对估时进行二次确认
> 3. 开发过程中：定时或在关键节点检查任务进度，了解当前开发过程有无风险
> 4. 提测之前：要求开发同学编写自测case，在提测之前需要先把自测case走通

> 技术：
>
> 1. 了解当前业务中的一些疑难问题以及开发流程中低效的部分，提出对应的技术手段以解决该问题
> 2. 指导低级别同学参与到技术项目中，并对其技术方案进行review
> 3. 调研业内技术方案及最新技术，组织团队分享和新技术尝试

2. 遇到管理上比较棘手的事情是什么

> 产品投诉开发质量问题，解决方案有以下：
>
> 1. 在提测之前要求先提供自测用例，并需要自己完整通过用例后才能提测给QA
> 2. 对同学进行引导和提示，强调开发质量的重要性
> 3. 了解同学的能力边界，对于无法胜任复杂项目的同学进行换岗，使其完成自己能力之内的事情
> 4. 若上面的手段都不行，那就只能最终劝退

3. 如何评判团队成员的绩效

> 本身团队不大，所有人的绩效都由老板管理，自己不参与团队成员的绩效。

4. 作为前端负责人在前端基础设施做了哪些事情

5. 在团队提效上做了哪些事情

6. 如何保证项目质量，有没有在质量和稳定性上做一些事情

> 保证项目质量主要考虑两个方面，一个是代码质量，一个是交付质量。 
>
> 代码质量问题最多，也是最容易去做的，主要是通过`Jest`去做代码的单测以及通过`Cypress`去做UI的自动化测试。这一块就不详细展开了，具体的使用方式就是看官方文档，然后编写对应的测试用例。 
>
> 交付质量这一块通常是与开发同学的个人意识和对需求的理解程度有关，之前经常会出现开发同学提测之后，QA发现主流程都走不通的情况。为了解决这个问题，我有两种措施，一个是需求提测前我会主动去过一遍需求的主流程看是否有问题，第二个则是要求开发同学自己写一份需求测试用例，在提测前需要自测通过该用例。

7. 做过哪些技术推动业务的事情

<hr>
#### react

1. 介绍一下React的合成事件

> 先讲了一下React合成事件的优势：
>
> 1. 抹平不同浏览器直接的差异，提供统一的API使用体验
> 2. 通过事件委托的方式统一绑定和分发事件，有利于提升性能，减少内存消耗

> 之后详细说了一下合成事件的绑定及分发流程：
>
> 1. React应用启动时，会在页面渲染的根元素上绑定原生的DOM事件，将该根元素作为委托对象
> 2. 在组件渲染时，会通过JSX解析出元素上绑定的事件，并将这些事件与原生事件进行一一映射
> 3. 当用户点击页面元素时，事件会冒泡到根元素，之后根元素监听的事件通过`dispatchEvent`方法进行事件派发
> 4. `dispatchEvent`会根据事件的映射关系以及DOM元素找到React中与之对应的fiber节点
> 5. 找到fiber节点后，将其绑定的合成事件函数加到一个函数执行队列中
> 6. 最后则依次执行队列中的函数完成事件的触发流程

2. 介绍一下React的patch流程

> 一开始面试官说让讲一下`批处理`，我还一脸懵，又确认了一下发现是React的更新流程。也是抱着举一反三的态度，完整的讲了一下React的渲染流程。
>
> 1. React新版架构新增了一个`Scheduler调度器`主要用于调度Fiber节点的生成和更新任务
> 2. 当组件更新时，`Reconciler协调器`执行组件的render方法生成一个`Fiber节点`之后再递归的去生成`Fiber节点`的子节点
> 3. 每一个`Fiber节点`的生成都是一个单独的任务，会以回调的形式交给`Scheduler`进行调度处理，在`Scheduler`里会根据任务的优先级去执行任务
> 4. 任务的优先级的指定是根据`车道模型`，将任务进行分类，每一类拥有不同的优先级，所有的分类和优先级都在React中进行了枚举
> 5. `Scheduler`按照优先级执行任务时，会异步的执行，同时每一个任务执行完成之后，都会通过`requestIdleCallBack`去判断下一个任务是否能在当前渲染帧的剩余时间内完成
> 6. 如果不能完成就发生中断，把线程的控制权交给浏览器，剩下的任务则在下一个渲染帧内执行
> 7. 整个`Reconciler`和`Scheduler`的任务执行完成之后，会生成一个新的`workInProgressFiber`的新的节点树，之后`Reconciler`触发`Commit阶段`通知`Render渲染器`去进行`diff`操作，也就是我们说的`patch`流程

> React的`Diff算法`可以分为`单节点Diff`和`多节点Diff`，其中单节点Diff相对简单，包含以下流程：
>
> 1. 首先会判断老的Fiber树上有没有对应的Fiber节点，若没有则说明是新增操作，直接在老Fiber树上新增节点并更新DOM
> 2. 若老Fiber节点也存在，则判断节点上的`key`值是否相同，若不同则删除老节点并新增新节点
> 3. 若`key`值相同，则判断节点的`type`是否相同，若不同则删除老节点并新增节点
> 4. 若`type`值也相同，则认为是一个可复用的节点，直接返回老节点就行

> 多节点的Diff操作主要用于map返回多个相同节点的情况下，可以分为三种情况：新增节点、删除节点以及节点移动，React采用双重遍历的方式来进行三种情况的判断，流程如下：
>
> 1. 第一轮遍历会依次将 children[i] 和 currentFiber 以及 children[i++] 和 currentFiber.sibling 进行对比，当发现节点不可复用时提前结束遍历
> 2. 当第一轮遍历无提前结束时，说明所有节点都可以复用，直接返回老节点
> 3. 若children遍历完成，currentFiber未完成，则说明是删除操作，需要对未完成的 currentFiber 兄弟节点标记删除
> 4. 若children遍历未完成，currentFiber完成，则说明是新增操作，需要生成新的workInProgressFiber节点
> 5. 若children和currentFiber都未完成，则说明是节点位置发送了变更，那就对剩余的currentFiber进行遍历，并通过key值找到每一个节点在children中对应的老节点，并将老节点中的位置替换为新节点的

3. 讲一下setState之后发生了哪些事情

> 先讲`React`的架构，包含了`Renderer`、`Scheduler`和`Reconciler`三部分，然后具体说了每一部分大概是做什么，之后讲`setState`其实就是触发组件的一次渲染过程，具体过程如下：
>
> 1. `setState`会生成一份新的组件内状态数据并重新执行`Reconciler`中的`render`方法
> 2. `render`方法会根据`JSX`和最新的数据去创建一个新的`fiber`节点树，每一个树节点的创建都是`Reconciler`中的一个工作单元
> 3. 所有的创建`fiber`节点工作单元生成后，这些工作单元的执行和调度会由`Scheduler`中的任务队列来执行
> 4. 任务队列每次取出一个创建`fiber`节点的任务执行，执行完成之后会调用浏览器的`requestIdeCallback`方法来判断当前刷新帧剩余时间是否够执行下一个任务
> 5. 如果时间够就执行下一个创建`fiber`节点任务，不够的话就先将创建任务暂停，等下一个刷新帧继续执行
> 6. 当所有的创建任务都执行完成之后，就生成了一棵新的`fiber`节点树，之后就是通过新旧两棵树去做`diff`算法获得要更新的树，后面的`diff`和渲染部分这里就不多介绍了

#### 开放

1. 介绍一下最近工作经历中架构上比较复杂的项目

2. 在以往的工作经历中有哪些最有成就感的项目

3. 画一个自己做过的最复杂项目的架构图

4. 如何理解业务的

#### 工程化

1. Vite的热更新原理是什么

2. babel的转换流程是什么样的

3. babel包含哪几个部分，核心包有哪些

#### 手写

1. 实现一个React的useState hook

2. 实现一个拼手气抢红包算法

提供了一个`RedPackage`的类，初始化时传入红包金额和个数，需要实现一个`openRedPackage`方法，每调一次都进行一次“抢红包”，并以console.log的形式输出抢到的红包金额

3. 实现一个同步的sleep方法

调用方式：(new LazyLog()).log(1).sleep(1000).log(2)
输出：先输出1，延迟1秒后输出2

4. 实现一个实时搜索框组件

> 这道题没有什么特殊的要求，就如题目所示，通过`React`实现一个实时搜索框组件即可，剩下的就是自由发挥了。

```jsx
const SearchBox = ({ onChange }) => {
    const lockRef = useRef(0)
    const [searchList, setSearchList] = useState([])

    const onInput = async e => {
        lockRef.current += 1
        const temp = lockRef.current
        try {
            const res = await fetch("/api/search", e.target.value)
            //  处理竞态条件
            if (lockRef.current !== temp) return
            setSearchList(res.json())
        } catch (error) {
            console.log(error)
        }
    }

    return (
        <div className="search-wrapper">
            <input type="text" onInput={onInput} />
            <ul className="complete-list">
                {searchList.map(item => (
                    <li key={item.value} onClick={onChange(item)}>
                        {item.label}
                    </li>
                ))}
            </ul>
        </div>
    )
}
```

#### 算法

1. 盛最多水的容器

2. 按照版本号由小到大排序

样例输入：versions = ['0.1.1', '2.3.3', '0.302.1', '4.2', '4.3.5', '4.3.4.5']
输出：['0.1.1', '0.302.1', '2.3.3', '4.3.4.5', '4.3.5']

3. 数字格式化

4. 大数相加

输入：num1 = '1234567890', num2 = '987654321'
输出：'2222222211'

5. 按照Z字型打印矩阵

输入：[[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12], [13, 14, 15, 16]]
输出：1 2 5 9 6 3 4 7 10 13 14 11 8 12 15 16

6. 查找有序数组中数字最后一次出现的位置

> 输入：nums = [5,7,7,8,8,10], target = 8 
> 输出：4

```js
//  最简答的方式就是直接遍历然后根据有序的条件找到当前值等于目标且下一个值不等于目标的结果
//  写出来之后面试官问了时间复杂度，这个就是单层循环的 O(N)，最坏情况就是刚好最后一个值是目标值
const findLast = (nums, target) => {
    for (let i = 0; i < nums.length; i++) {
      if (target === nums[i] && target !== nums[i + 1]) {
        return i;
      }
    }
    return -1;
};

//  问有没有更好的方式，就想到了二分查找，对于已经有序的数组，只需要通过双指针不断更新左右边界位置就行
//  二分法最主要的就是寻找二分结束的边界条件，这里选择所有的查找最后都只剩两个值
//  然后对这两个值再额外判断一下是否符合结果
//  面试官继续追问二分法的时间复杂度，这个我有点懵，不过考虑跟递归差不多，所以就回答了O(logN)，应该是没错
//  二分查找最坏的情况是刚好第一个值或者最后一个值，或者中间值是目标值
const findLast2 = (nums, target) => {
    let left = 0;
    let right = nums.length - 1;
    while (right > left + 1) {
        const mid = Math.floor((left + right) / 2);
        if (nums[mid] > target) {
            right = mid - 1;
        } else {
            left = mid;
        }
    }
    if (nums[right] === target) {
        return right;
    }
    if (nums[left] === target) {
        return left;
    }
    return -1;
};
```
