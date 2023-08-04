# Umi & CSS-In-JS

表面上，React 的写法是 HTML、CSS、JavaScript 混合在一起。但是，其本质是用 JavaScript 在写 HTML 和 CSS。

> 相关阅读：
> 
> CSS Preprocessor CSS 预处理器是一个能让你通过预处理器自己独有的语法来生成 CSS 的程序。市面上有很多 CSS 预处理器可供选择，且绝大多数 CSS 预处理器会增加一些原生 CSS 不具备的特性，例如代码混合，嵌套选择器，继承选择器等。这些特性让 CSS 的结构更加具有可读性且易于维护。 
>
> —— 《MDN / CSS 预处理器》

React 在 JavaScript 里面实现了对 HTML 和 CSS 的封装，我们通过封装去操作 HTML 和 CSS。也就是说，网页的结构和样式都通过 JavaScript 操作。

React 对 HTML 的封装是 JSX 语言；对 CSS 封装非常简单，就是沿用了 DOM 的 style 属性对象。

由于 CSS 的封装非常弱，导致了一系列的第三方库，用来加强 React 的 CSS 操作。它们统称为 CSS in JS，意思就是使用 JS 语言写 CSS。

本文就 CSS in JS 三种方案在 Umi 框架下的应用与配置进行讨论。

## 1 CSS Modules

Umi 内置了 CSS Modules 支持。

### 1.1 安装与使用

默认引入 style 对象，将其内部属性作为 className 属性传递给组件：

```tsx
// src/page/home1.tsx
import style from "./home1.less";
const Home1 = () => {
  return <div className={style.container}>Home1</div>;
};
export default Home1;
// src/page/home1.less
.container {
    color: red
}
```

### 1.2 处理多个类名

多个类名共同作用于单个组件时，可以使用 `join(' ')` 方法处理：

```tsx
// src/page/home1.tsx
import style from "./home1.less";
const Home1 = () => {
  return <div className={[style.container, style.box].join(" ")}>Home1</div>;
};
export default Home1;
```

也可以使用 `classnames` 库。 `pnpm add classnames` 安装：

```tsx
// src/page/home1.tsx
import style from "./home1.less";
import classnames from "classnames";
const Home1 = () => {
  return <div className={classnames(style.container, style.box)}>Home1</div>;
};
export default Home1;
```

### 1.3 嵌套样式

可以正常使用 sass 或 less 的嵌套语法

```tsx
// src/page/home1.tsx
import style from "./home1.less";
const Home1 = () => {
  return (
    <div className={style.father}>
        <div className={style.child>}>Home1</div>
    </div>
  );
};
export default Home1;
// src/page/home1.less
.father {
    .child { color: red }
}
```

### 1.4 固定类名

1. 指定固定类名：利用 `classnames` 整合 module 类名与固定类名字符串即可

2. 指定固定类名的样式：利用 `:global()` 包裹固定类名，单独指定其样式，这样 CSS Modules 就不会对该类名进行处理：

```less
:global(.fix_class) {
  background: red;
}
```

## 2 Styled Components

> https://styled-components.com/

### 2.1 安装

`pnpm add styled-components @types/styled-components`

### 2.2 使用

使用 styled 的某个属性（例如 `styled.div`）定义一个元素，后紧跟样式字符串，支持 less 等语法；

在函数组件中以组件形式使用即可：

```tsx
import styled from "styled-components";
const Text = styled.div`
  color: red;
  &:hover {
    background: red;
  }
`;
const home2 = () => {
  return <Text>home2</Text>;
};
export default home2;
```

样式复用：将复用的组件样式传入 `styled()` 中，后紧跟新的样式字符串（无法对 React Component 进行样式复用）：

```tsx
import styled from "styled-components";
const Text = styled.div`
  color: red;
  &:hover {
    background: red;
  }
`;
const TextWithBorder = styled(Text)`
  border: 1px solid red;
`;
const home2 = () => {
  return <TextWithBorder>home2</TextWithBorder>;
};
export default home2;
```

传递参数：样式属性可以定义为回调函数，从而获取组件 props 中的数据：

```tsx
import { useState } from "react";
import styled from "styled-components";

const Button = styled.button`
  color: ${(props) => props.color};
`;
const home2 = () => {
  const [color, setColor] = useState<"red" | "green">("red");
  const onClick = () => {
    setColor(color === "red" ? "green" : "red");
  };
  return (
    <div>
      <Button onClick={onClick} color={color}>
        change color
      </Button>
    </div>
  );
};
export default home2;
```

安装 vscode-styled-components 插件以获取 VSCode 代码提示支持

总结：

- 类名完全随机

- 无需新建 css 文件，符合组件化封装思想

- 组件提示可维护性，但可读性较差

- 适合纯样式组件

## 3 UnoCSS

UnoCSS 属于原子化 CSS 的架构。它倾向于小巧且用途单一的 class，并且会以视觉效果进行命名。

### 3.1 由来

- Tailwind CSS

  - 优势：写起来很爽

  - 缺陷：会先加载所有类名的样式文件，导致 CSS 文件过于臃肿，造成资源浪费（目前已经实现 JIT 解决了这个问题）

- WindiCSS

  - 优势：提出属性化模式，使得类名可以作为元素属性传入；基于 JIT，实现了按需生成样式文件，从而解决了 Tailwind CSS 最大的缺陷（目前 Tailwind CSS 也支持 JIT 编译）

- UnoCSS

  > https://github.com/unocss/unocss

  - 作者 antfu 来自 WindiCss 团队，UnoCSS 是一个原子化 CSS 引擎，而非一款框架，所有功能可以通过预设和内联配置提供，也就是说，上面提到的两种框架都可以作为插件从而得到兼容。将作为下一代 WindiCSS 的引擎

### 3.2 安装与配置

1. 安装 `pnpm add -D unocss`

2. 在 `src/layout/index.tsx` 中引入样式

```tsx
import "uno.css";
```

3. 在 `.umirc.ts` 中配置 Webpack：

```ts
import { defineConfig } from "umi";
import UnoCss from "@unocss/webpack";

export default defineConfig({
  // ...
  chainWebpack(memo) {
    memo.plugin("UnoCss").use(UnoCss);
    return memo;
  },
});
```

4. 最外层目录下创建 `umo.config.ts`：

```ts
import {
  defineConfig,
  presetAttributify,
  presetIcons,
  presetTypography,
  presetUno,
  transformerAttributifyJsx,
} from "unocss";
export default defineConfig({
  theme: {},
  shortcuts: {},
  safelist: [],
  presets: [
    // 必须引用的
    presetUno(),
    // 支持属性化
    presetAttributify(),
    // 预设图标类样式
    presetIcons({
      extraProperties: { display: "inline-block", "vertical-align": "center" },
    }),
    // 预设板式
    presetTypography(),
  ],
  transformers: [
    // jsx支持属性化
    transformerAttributifyJsx(),
  ],
});
```

5. 安装 `UnoCSS` VSCode 插件

6. 处理 flex 等属性类型报错问题：

```ts
import "umi/typings";
import type { AttributifyAttributes } from "unocss/preset-attributify";
declare module "react" {
  interface HTMLAttributes<T> extends AttributifyAttributes {
    flex?: boolean;
    // 如果还有属性报错，就在这里添加属性类型即可
  }
}
```

### 3.3 使用

1. 三栏布局

```tsx
const home3 = () => {
  return (
    <div flex justify-center items-center w="100%" h-100px>
      <div w-100px bg-red></div>
      <div flex-1 bg-yellow></div>
      <div w-100px bg-blue></div>
    </div>
  );
};
export default home3;
```

2. 修改默认样式

UnoCSS 会有一些预设的样式参数变量，当我们要修改预设样式的属性时，可以在全局 css 文件中修改对应的 css 变量即可

```less
// src/global.scss
:root {
  --un-shadow-color: red;
}
```
