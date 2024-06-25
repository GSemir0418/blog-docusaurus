---
title: Tab组件封装
date: 2024-06-24T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [react, css, scroll, intersection observer]
---

组件源码：https://github.com/GSemir0418/account-app-vite/tree/main/src

### 综述

使用 [CSS Scroll Snap](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_scroll_snap) 和 [Intersection Observer API](https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API) 实现移动端的 Tab 页签移动效果

本质上就是将 Tab 页面横向排列，使用原生的滚动效果实现页签的切换，使用以上两种技术来处理交互

### 类型定义

接受 `tabList` 列表，每一项分别是一个 tab 页面与按钮属性的配置

接受 `defaultKey` 作为默认展示的 tab，这里使用泛型限制 defaultKey 要属于 tab.key 属性的集合

```typescript
interface TabProps<T extends React.Key> {
  tabList: {
    key: T
    label1: string
    label2: string
    className: string
    value: TagSummary[]
  }[]
  defaultKey: T
}
```

### 布局

整体为 flex 上下布局，上面是 tab 按钮，剩下是 tab 页面

```html
<div className="flex flex-col">
  <div className="w-full">
    tab 按钮栏
  </div>
  <div className="flex-1 w-full relative">
    tab 页面
  </div>
</div>
```

- 页面横向排列，触发横向滚动

这里将外部 tab 容器设置为 flex 布局，支持滚动，内部页面设置最小宽度为 100 % 

```jsx
<div className="flex-1 w-full relative flex overflow-auto">
  {tabList.map(tab => (
    <div key={tab.key} className="h-full min-w-full">
这里是 tab 内容
    </div>
  ))}
</div>
```

- 设置 **CSS Snap Scroll**

```jsx
<div className="flex-1 w-full relative flex overflow-auto snap-x snap-mandatory">
  {tabList.map(tab => (
    <div key={tab.key} className="h-full min-w-full snap-center snap-normal">
这里是 tab 内容
    </div>
  ))}
</div>
```

其中父元素的 `scroll-snap-type: x mandatory;` 表示父容器内的滚动操作（仅限水平方向）应当强制与子元素的某个对齐点对齐

>除了 `x`，`scroll-snap-type` 还可以设置为 `y` 以应用于垂直滚动，或者 `both` 来同时应用于水平和垂直滚动
>
>与 `mandatory` 相对的还有一个值 `proximity`，`proximity` 不强制滚动停止时进行对齐，只是在合适时尝试对齐，提供更灵活的用户体验。

子元素设置 `scroll-snap-align: center;` 来指定这些元素应当在滚动捕捉时居中对齐。也就是说，当用户停止滚动后，这些子元素会自动调整位置，以使其位于滚动容器的中心位置。在实现轮播图、画廊等功能时非常有用，它确保了用户在滑动结束时总能看到完整的项目而不是部分被截断的内容；

而 `scroll-snap-stop: normal` 指定元素在滚动捕捉点时应当保持正常的滚动行为。换句话说，当元素滚动接近捕捉点时，滚动不会被强制停止在捕捉点上，而是允许用户在捕捉点周围进行自由的滚动

### 交互

主要用来处理 tab 页与 tab 按钮之间的联动

- 页面 => 按钮

使用 Intersection Observer API + useRef + useEffect 实现，注意要给 tab 页面设置 id

```tsx
export function Tab<T extends React.Key>(props: TabProps<T>) {
  const { defaultKey, tabList } = props
  const [activeKey, setActiveKey] = useState(defaultKey)
  // 使用 ref 维护 observer 实例
  const observer = useRef<IntersectionObserver>()
  useEffect(() => {
    // 初始化 IntersectionObserver 实例，监听元素交叉状态
    observer.current = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          // 将交叉的元素设置为当前活动的 key
          if (entry.isIntersecting)
            setActiveKey(entry.target.id as T)
        })
      },
      // 监听元素可见度达到 50% 时触发回调
      { threshold: 0.5 },
    )
		// 根据 id 查找并监听每个 tab 元素的交叉情况
    tabList.forEach((tab) => {
      observer.current?.observe(document.getElementById(tab.key as string)!)
    })

    // 清理，释放
    return () => {
      observer.current?.disconnect()
      observer.current = undefined
    }
  }, [])

  return (
    <div className="...">
      <div className="...">
        {tabList.map(tab => (
          <span
            key={tab.key}
            className={`${activeKey === tab.key ? '...' : '...'}`}
          >
            {tab.label1}
            <span className={`${tab.className} text-sm`}>{tab.label2}</span>
          </span>
        ))}
      </div>
      <div className="...">
        {tabList.map(tab => (
          <div key={tab.key} id={tab.key} className="...">
      			这里是 tab 内容
    			</div>
        ))}
      </div>
    </div>
  )
}
```

- 按钮 => 页面

给按钮绑定点击事件，传入 key，根据 id 找到改 tab 元素，执行 **scrollIntoView** 方法即可

```tsx
interface TabProps<T extends React.Key> {}

export function Tab<T extends React.Key>(props: TabProps<T>) {
 	// ...
  
  const handleTabClick = (key: T) => {
    // scrollIntoView
    document.getElementById(tabList.find(tab => tab.key === key)?.key as string)?.scrollIntoView({ behavior: 'smooth', block: 'end' })
    // 同步设置为当前活动的 key
    setActiveKey(key)
  }

  return (
    <div className="...">
      <div className="...">
        {tabList.map(tab => (
          <span
            key={tab.key}
            className={`...`}
            onClick={() => handleTabClick(tab.key as T)}
          >
            {tab.label1}
            <span className={`...`}>{tab.label2}</span>
          </span>
        ))}
      </div>
      <div className="...">
        {tabList.map(tab => (
          <div key={tab.key} id={tab.key} className="...">
      			这里是 tab 内容
    			</div>
        ))}
      </div>
    </div>
  )
}
```

至此，完成 Tab 组件的封装