---
title: 浏览器路由
date: 2023-08-04T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
---

Browser 路由和 Hash 路由等路由技术解析与实现

<!--truncate-->

路由是一种用来管理URL和页面之间关系的技术。通俗来说，它决定了当用户在浏览器中输入或点击一个特定的URL时，应该展示哪个页面。

## 浏览器路由技术发展

1. 原始的 `Browser`（浏览器）路由： 最初，前端应用主要使用传统的 URL 形式来进行导航，这种方式需要**向服务器请求新的页面**内容，因为浏览器刷新页面时会发送请求。这种路由方式也称为 Browser 路由。

2. `Hash`（哈希）路由： 随着前端技术的发展，由于传统的 URL 路由有**刷新页面**的问题，前端开发者采用了 Hash 路由作为一种替代方案。Hash 路由通过在 URL 中使用哈希部分（`#`）来标识不同的页面，这样切换页面时**不会向服务器请求新的资源**。这种方式适用于较旧的浏览器，并且简单易用，但 URL 中会带有 `#` 符号，看起来可能**不太美观**。

3. `History API` 路由（也称为 Browser 路由的现代实现）： 随着 HTML5 的发展，浏览器引入了 **`History API`**，使得前端开发者可以使用类似 Hash 路由的无刷新页面切换方式，但 URL 中**不再需要#**符号。History API 允许开发者**添加**（`pushState`）、**修改和替换**（`replaceState`）浏览器历史记录中的条目，从而实现前端页面导航。这种路由方式也称为 History 路由，它在 URL 中使用普通的路径，看起来更加美观。现代的**单页面应用**通常使用 History API 路由，**除非**要兼容旧版浏览器，才会考虑使用 Hash 路由。

- 前后端分离，所以将前端页面的渲染工作交给前端的 javascript 来控制，不再向服务端发起静态资源请求

下面针对这三种浏览器路由技术分别进行简要介绍

## 传统 Browser 路由

前端实现传统 Browser 路由有两种常见方案，分别是 a 标签跳转行为与 form 表单提交行为

```html
<a href="/home">home</a>
<form action="/home" method="GET">
  <button type="submit">Search</button>
</form>
```
浏览器此时会重新请求 /home 路由并渲染页面

## Hash 路由

> 关键api：`window.location.hash`

Hash 路由实现相对简单，我们可以使用 `window.location.hash` 来读取和设置 URL 中的哈希部分（#后面的部分），然后根据哈希部分的内容来进行页面切换和渲染。

```html
<a href="#/home">home</a>
<a href="#/about">about</a>
<div id="content"></div>
<script>
  // 监听所有链接的点击事件
  const links = document.querySelectorAll("a");
  links.forEach(function (link) {
    link.addEventListener("click", function (event) {
      event.preventDefault();
      // 当用户点击链接时，根据哈希部分来切换页面内容。
      const url = link.getAttribute("href").slice(1); // 去掉哈希部分的#符号
      loadPage(url);
      // 修改URL的哈希部分，实现页面切换
      window.location.hash = url;
    });
  });

  function loadPage (url) {
    // ajax 请求新页面内容过程省略
    const content = document.querySelector("#content");
    content.innerHTML = `<h2>${url}</h2>`
  }
</script>
```

打开控制台发现，没有任何请求触发，也没有页面刷新，但页面数据与 url 已经改变了

## History 路由

> 关键api：`popstate`，`history.pushState`

History 路由的实现主要依赖浏览器的 `history API`，通过监听 `popstate` 事件，获取路由并渲染页面，通过 `history.pushState` 同步更新 url。

```html
<a href="/home">home</a>
<a href="/about">about</a>
<div id="content"></div>
<script>
  // 这里使用History API来实现前端路由
  // 首先，我们在页面加载时添加一个事件监听器，监听URL的变化
  window.addEventListener("popstate", function (event) {
    loadPage(event.state.url);
  });

  // 然后，我们通过JavaScript监听链接的点击事件，
  // 当点击链接时，我们使用History API将新的URL加入浏览器的历史记录，
  // 同时也会更新页面内容。
  const links = document.querySelectorAll("a");
  links.forEach(function (link) {
    link.addEventListener("click", function (event) {
      event.preventDefault();
      const url = link.getAttribute("href");
      loadPage(url);
      history.pushState({ url: url }, "", url);
    });
  });

  // 这个函数用来通过AJAX请求获取对应页面的内容，
  // 然后将内容渲染到content div中。
  function loadPage(url) {
    // 这里省略了AJAX请求和页面渲染的实际逻辑
    // ...
    document.getElementById("content").innerHTML = `<h2>${url}</h2>`;
    // ...
  }
</script>
```
## 扩展：history 与 location

### 联系

1. location和history都是用于处理浏览器URL的相关操作，都是 window 对象的属性。

2. window.location主要用于获取和设置当前页面的URL，以及实现页面的重定向，而 history 主要用于控制浏览器的历史记录，实现前进、后退和导航功能。

3. 二者的 api 都不会使页面重新刷新或者发起请求

### 区别

1. window.location： 是一个表示当前浏览器URL的对象。它具有许多属性，如href、protocol、hostname、pathname、search、hash等，用于获取和设置URL的各个部分。通过window.location，我们可以读取当前页面的URL

2. window.history： 是一个表示浏览器历史记录的对象。它具有back()、forward()、go()等方法，以及length属性来获取历史记录中的条目数量。通过history对象，我们可以实现前进、后退和在历史记录中导航的功能。
