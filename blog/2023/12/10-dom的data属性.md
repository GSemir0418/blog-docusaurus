---
title: data-* 属性
date: 2023-12-10T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
---
data-* 属性允许我们在标准、语义化的 HTML 元素中存储额外的信息，而不需要使用类似于非标准属性或者 DOM 额外属性之类的技巧。

所有在元素上以data-开头的属性为数据属性。比如说你有一篇文章，而你又想要存储一些不需要显示在浏览器上的额外信息。

你可以使用getAttribute()配合它们完整的 HTML 名称去读取它们，但标准定义了一个更简单的方法：DOMStringMap你可以使用dataset读取到数据。

为了使用dataset对象去获取到数据属性，需要获取属性名中data-之后的部分 (要注意的是破折号连接的名称需要改写为骆驼拼写法 (如"index-number"转换为"indexNumber"))。

```
var article = document.querySelector("#electriccars");

article.dataset.columns; // "3"
article.dataset.indexNumber; // "12314"
article.dataset.parent; // "cars"
```

比如你可以通过generated content使用函数attr()来显示 data-parent 的内容：
article::before {
  content: attr(data-parent);
}

你也同样可以在 CSS 中使用属性选择器根据 data 来改变样式：
article[data-columns="3"] {
  width: 400px;
}
article[data-columns="4"] {
  width: 600px;
}