---
title: requestAnimationFrame
date: 2024-03-25T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [javascript, requestAnimationFrame, animation, setInterval]
---

### 需求

实现 box 由左至右移动的动画

### 实现思路

#### CSS 

使用 `animation` 配合 `@keyframe` 属性

- 提供**简单的声明式语法**，**自动运行**，但对动画的控制相对限制，如暂停、重启等功能依赖于CSS的`animation-play-state`属性。
- 良好的浏览器支持，特别是在现代浏览器中，**性能通常非常好**，尤其是对于简单的动画效果。CSS动画可以由浏览器的合成器直接处理，**不需要回流和重绘**。
- 适合实现**简单**的动画效果，如过渡、2D平移、旋转、缩放等。
- 能够在没有 JavaScript 的情况下工作，可以更容易地由设计师创建和维护。

```css
#box1 {
  background: red;
  /* 方案1 使用 animation */
  animation: moveRight 1s forwards;
}

@keyframes moveRight {
to {
  transform: translateX(900px);
}
```

#### JS

##### setInterval

使用定时器实现动画

```js
const box = document.querySelectorAll(".box")[0];
let left = 0;
function boxMoving() {
  if (left > 200) {
    clearInterval(timer);
  } else {
    left++;
    box.style.left = left + "px";
  }
}
let timer = setInterval(boxMoving, 1000 / 120); // 120Hz
```

- 在 `CSS3` 动画出来以前，我们通常使用 `JS` 来实现动画效果，即使有了 `CSS` 动画，我们很多动画效果还是得依赖 `JS`。而 `JS` 实现动画得两大利器便是 `setTimeout` 和 `setInterval`，**因为我们动画的原理就是不停地刷新图像，而定时器可以帮我们做这一操作**。
- 代码很简单，就是让 `div` 元素向右移动 `1px`。然后我们开启定时器不断重复该函数，需要注意的是，我们将函数执行的频率（1000/120ms）调为了差不多和屏幕刷新率一样，即 `120Hz` 的屏幕刷新率。

##### 存在问题

- `setInterval` 是**异步**的，也就是意味着 `JS` 代码执行的时候会将它放入异步队列中，所以它的**执行时间并不确定**。
- 屏幕刷新率是不定的，现在各大厂家的屏幕刷新率有 `30Hz`、`60Hz`、`90Hz`、`120Hz` 等等，以后还会更多，但是我们传入 `setInterval` 的时间间隔是固定的，这就有可能造成**动画的执行与屏幕的刷新率不匹配**，从而导致在不同设备上的动画流畅度不同，产生跳帧或卡帧的现象
- `setInterval` 会**一直在后台执行**，即使我们访问其它页面时。

##### 解决

- 前面我们介绍的 `setInterval` 是我们使用 `JS` 实现动画常用的手段，不可否认，在以前确实可以这样使用，也是最好的办法。
- 但是我们也需要正面这些问题，特别是随着电子设备的不断更新换代，屏幕的刷新率也出现很多种的情况下，如果继续使用定时器来实现动画，很可能会造成**动画的卡顿**以及**性能的消耗**。
- `requestAnimationFrame API` 就非常完美的解决了定时器实现动画的各种问题。

##### requestAnimationFrame

- 是一个**原生API**，接收一个**回调函数**作为参数，返回一个ID，用于`cancelAnimationFrame(ID)`
- 回调函数会在**屏幕刷新**的时候调用，由系统来决定回调函数的执行时机
- **不会在后台一直执行**，它会在页面出现的时候才会执行，比如 `document.hide` 为 `true` 的时候，而我们的定时器是一直会执行的。可以节省 `CPU` 和 `GPU` 等等。

```js
const box = document.querySelectorAll(".box")[0];
let left = 0;
function boxMoving() {
	if (left > 200) {
		cancelAnimationFrame(timer);
	} else {
		left++;
		box.style.left = left + "px";
		// 请求动画帧，即屏幕刷新的时候再次执行
		requestAnimationFrame(boxMoving);
	}
}
let timer = requestAnimationFrame(boxMoving);
```

##### 问题

`requestAnimationFrame`（简称rAF）在**不同屏幕刷新率**下可能会导致**动画的体验有所不同**。这主要是因为 rAF 是与浏览器的重绘过程（也就是屏幕的刷新率）同步的。因此，动画的更新频率会与显示器的刷新频率一致。

如果一个显示器的刷新率是 60Hz，那么`requestAnimationFrame`大约每 16.67 毫秒被调用一次（1000ms/60），这意味着你的动画每秒钟会更新 60 次。如果显示器的刷新率更高，比如 120Hz，那么rAF将大约每 8.33 毫秒被调用一次，动画每秒更新 120 次，这会使动画更加平滑