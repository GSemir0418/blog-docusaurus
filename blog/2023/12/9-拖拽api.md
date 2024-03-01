---
title: 拖拽 api
date: 2023-12-09T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
---

### 被拖拽元素

默认情况下，图片、链接和文本是可拖动的。HTML5 在所有 HTML 元素上规定了一个 `draggable` 属性， 表示元素是否可以拖动。图片和链接的 draggable 属性自动被设置为 true，而其他所有元素此属性的默认值为 false。

某个元素被拖动时，会依次触发以下事件:

- `ondragstart`：拖动开始，当鼠标按下并且开始移动鼠标时，触发此事件；整个周期只触发一次；
- `ondrag`：只要元素仍被拖拽，就会持续触发此事件；
- `ondragend`：拖拽结束，当鼠标松开后，会触发此事件；整个周期只触发一次。

### 可释放目标

当把拖拽元素移动到一个有效的放置目标时，目标对象会触发以下事件：

- `ondragenter`：只要一把拖拽元素移动到目标时，就会触发此事件；
- `ondragover`：拖拽元素在目标中拖动时，会持续触发此事件；
- `ondragleave` 或 `ondrop`：拖拽元素离开目标时（没有在目标上放下），会触发`ondragleave`；当拖拽元素在目标放下（松开鼠标），则触发`ondrop`事件。

> 目标元素默认是不能够被拖放的，即不会触发 `ondrop` 事件，可以通过在目标元素的 `ondragover` 事件中取消默认事件来解决此问题。
