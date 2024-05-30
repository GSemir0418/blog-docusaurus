---
title: BFC
date: 2024-05-23T10:29:00+08:00
sidebar-position: 6
authors: gsemir
tags: [css, bfc]
---

#### 概念

BFC 全称 `Block Formatting Contexts` 块级格式化上下文

BFC 就是**一个独立的布局环境，BFC 内部的元素布局与外部互不影响**

标准流中的 body 元素本身就是一个天然的 BFC

#### 触发（父元素） BFC 的常见方式

- 设置浮动

- `overflow` 设置为 `auto`、`scroll`、`hidden`

- `position` 设置为 `absolute`、`fixed`
- `display` 设置为 `inline-block`、`table-cell`

其他的方式见 [mdn](https://developer.mozilla.org/zh-CN/docs/Web/CSS/CSS_display/Block_formatting_context)

#### BFC 的应用

主要是解决一些布局问题

- 解决**浮动元素**令**父元素高度塌陷**的问题

- 解决非浮动元素被浮动元素**覆盖**的问题（**两栏布局**常见问题）

- 解决**外边距垂直方向重合**（取最大）的问题