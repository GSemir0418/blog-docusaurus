---
title: Tailwind 组件封装思路
date: 2024-07-12T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [css, tailwindcss, cva, clsx]
---

> 本文参考 shadcn-ui 的组件封装方案，提供了一种基于业务或者团队的 UI 设计方案，对 Tailwind CSS 组件的样式进行进一步的封装思路
>
> 有关于 shadcn-ui 的介绍，可以参考 《discord-clone 项目总结》一文

### 概述

Tailwind CSS 已经为开发者提供了非常丰富的基本样式类的封装，覆盖绝大部分的样式需求。主要具有如下优势

1. 不用思考命名
2. 不用担心 css 作用域的问题，从而可以避免使用 scss、less、css modules、css in js 等额外的技术方案
3. 不用频繁的额外单独创建一个 css 文件，可以直接在 html 或 jsx 中表达样式
4. 打包体积变小
5. 稍作修改，可以极大的提高项目的可维护性
6. 极大的提高了开发效率
7. 最重要的是开发变得更加顺畅，所见即所得，不用样式分离

下面以 Form Input 组件的封装为例，实现

- 基本的交互特效
- Form 响应式
- 支持 colSpan 属性
- 支持主题切换

### 工具库

shadcn-ui 组件的样式灵活性主要就是由 `clsx` 及 `cva` 库提供的

#### cva

> https://cva.style/docs

cva 可以**配置和生成预设样式库**，适用于组件的样式封装

`variant` 是 cva 的核心概念之一，可以理解为某套预设样式的别名，使组件样式可以适配不同的主题或场景，例如 Button 的 primary、ghost 等

变体的定义就是将预设样式与变体样式传入

```ts
import { cva } from "class-variance-authority";
 
const button = cva(["font-semibold", "border", "rounded"], {
  variants: {
    intent: {
      primary: [
        "bg-blue-500",
        "text-white",
        "border-transparent",
        "hover:bg-blue-600",
      ],
      // **or**
      // primary: "bg-blue-500 text-white border-transparent hover:bg-blue-600",
      secondary: [
        "bg-white",
        "text-gray-800",
        "border-gray-400",
        "hover:bg-gray-100",
      ],
    },
    size: {
      small: ["text-sm", "py-1", "px-2"],
      medium: ["text-base", "py-2", "px-4"],
    },
  },
  defaultVariants: {
    intent: "primary",
    size: "medium",
  },
});
```

调用这个函数，就会根据传入的 varient 返回样式字符串

#### clsx

> https://github.com/lukeed/clsx

clsx 是一个拼接 class 的库，用于**有条件地**构造 className 字符串。clsx 允许我们使用 `classname: boolean` 的形式，动态控制 TailwindCSS 类名，更方便的通过条件去控制样式的变化

使用 `tailwind-merge` 库用来处理 tailwind 样式冲突问题，它可以让写在后面的样式覆盖前面的样式，这样我们就不需要使用 !important 来覆盖样式了。

以上二者结合，可以作为 TailwindCSS 中的类名拼接方案

```ts
import { type ClassValue, clsx } from 'clsx'
import { twMerge } from 'tailwind-merge'

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
```

使用

```tsx
<div className={
    cn(
      "p-4 border border-indigo-700", 
      { "border-rose-700": theme === 'light' }
    )
}>
```

另外，clsx 非常适用于纯样式或者布局组件的封装，将 props 映射为相应的 className

```ts
import clsx from 'clsx'

export default function Flex(props) {
  const {children, start, end, around, between, className, center, col, ...other} = props

  const base = 'flex items-center flex-row'

  const cls = clsx(base, {
    ['flex-col']: col,
    ['justify-start']: start,
    ['justify-end']: end,
    ['justify-around']: around,
    ['justify-between']: between,
    ['justify-center']: center,
  }, className)

  return (
    <div className={cls}>{children}</div>
  )
}
```

### 组件封装

#### Form 响应式布局

使用 grid 来布局表单项，使用 Tailwind 提供的响应式类名实现响应式 grid 布局

```tsx
import { FC, ReactNode } from "react"

const Form: FC<{children: ReactNode}> = ({ children }) => {
  return (
    <form className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      {children}
    </form>
  )
}

export default Form
```

#### colSpan

Form Input 组件接收 colSpan 参数，从而动态调整自己在网格中的位置和跨度

```tsx
import { VariantProps } from 'class-variance-authority'

interface FormInputProps extends VariantProps<typeof containerStyles> {
  label: string
  name: string
  className?: string
}
```

这里要明确，`colSpan` 并非业务逻辑的参数，而是样式的 `variant`，所以我们使用 cva 来定义并管理这个 variant

```tsx
const containerStyles = cva(
  'w-full p-2 border rounded-md relative',
  {
    variants: {
      colSpan: {
        1: 'col-span-1',
        2: 'col-span-2',
        3: 'col-span-3',
      },
    },
    defaultVariants: {
      colSpan: 1,
    },
  }
)

const FormInput = forwardRef<HTMLInputElement, FormInputProps>(({ label, name, colSpan, className }, ref) => {
})
```

这里组件使用 `React.forwardRef` 方法包裹，目的是将父组件的引用（ref）传递到子组件内部的 DOM 元素上，方便 Form 组件统一管理子组件的 ref，例如操作表单 DOM 元素或者暴露组件内部引用等

> forwardRef 更适用多层嵌套传递 ref 的场景

#### 交互

Tailwind 提供了一些实用的**状态变体**或**伪类变体**。它们允许开发者根据元素的状态、兄弟元素的状态或父元素的状态来应用不同的样式

- **`peer`**：用于关联兄弟元素的状态。例如，当一个 `input` 元素聚焦时，可以改变与之相关的其他元素的样式。
- **`group`**：用于关联父元素的状态。例如，当一个父元素被悬停时，可以改变其子元素的样式。
- **`has-[]`**：用于根据某些条件来选择元素的状态。
- **`first`, `last`, `odd`, `even`** 等：用于选择元素在其父元素中的位置，并根据该位置应用样式。

这里实现 label 根据 input 聚焦自动缩放的效果

```html
<div className="w-full p-2 border rounded-md relative">
  <input
    type="text"
    name={name}
    id={name}
    placeholder=' '
    className="
    	block 
      mt-3 
      w-full 
      appearance-none 
      focus:outline-none 
      focus:ring-0 
      peer
    "
  />
  <label
    htmlFor={name}
    className="
      absolute
      text-sm 
      font-medium
      duration-300
      z-10
      origin-[0]
      -translate-y-3
      scale-75
      top-4
      left-2
      peer-placeholder-shown:scale-100
      peer-placeholder-shown:translate-y-0
      peer-focus:scale-75
      peer-focus:-translate-y-3
      peer-focus:text-zinc-400
    "
  >
    {label}
  </label>
</div>
```

#### 主题切换

定义主题的 context hook 及 Provider 组件，向子组件提供 `theme` state 和 `toggleTheme` 方法

```tsx
import { createContext, FC, ReactNode, useContext, useState } from 'react'

interface ThemeContextType {
  theme: 'light' | 'dark'
  toggleTheme: () => void
}
const ThemeContext = createContext<ThemeContextType>({theme: 'light', toggleTheme: () => {}})

export const ThemeProvider:FC<{children: ReactNode}> = ({ children }) => {
  const [theme, setTheme] = useState<ThemeContextType['theme']>('light')

  const toggleTheme = () => {
    setTheme((prevTheme) => (prevTheme === 'light' ? 'dark' : 'light'))
  }

  return (
    <ThemeContext.Provider value={{ theme, toggleTheme }}>
      {children}
    </ThemeContext.Provider>
  )
}

export const useTheme = () => useContext(ThemeContext)
```

子组件中通过 `useTheme` hook 获取 theme 数据，并将 theme 属性使用 cva 作为 `variant` 封装

```tsx
const containerStyles = cva(
  'w-full p-2 border rounded-md relative',
  {
    variants: {
      colSpan: {},
      theme: {
        light: 'bg-slate-100 has-[:focus]:bg-slate-200',
        dark: 'bg-slate-700 text-white',
      },
    },
    defaultVariants: {
      colSpan: 1,
      theme: 'light',
    },
  }
)

const inputStyles = cva(
  "block mt-3 w-full appearance-none focus:outline-none focus:ring-0 peer",
  {
    variants: {
      theme: {
        light: 'bg-slate-100 focus:bg-slate-200',
        dark: 'bg-slate-700',
      },
    },
    defaultVariants: {
      theme: 'light',
    },

  }
)

const FormInput = forwardRef<HTMLInputElement, FormInputProps>(({ label, name, colSpan, className }, ref) => {
  
  const { theme } = useTheme()

  return (
    <div className={cn(containerStyles({ colSpan, theme }), className)}>
      <input className={cn(inputStyles({ theme }))} />
      <label>{label}</label>
    </div>
  )
})

export default FormInput
```

附：Tailwind 多主题配置

使用 CSS 变量和 Tailwind 的扩展配置

定义 CSS 变量

```css
/* theme.css */
.theme-light {
  --color-main-bg: #ffffff;
  --color-main-text: #000000;
}

.theme-warm {
  --color-main-bg: #d8d1c5;
  --color-main-text: #474b52;
}

/* main.css */
@import url(./theme.css)
```

扩展或自定义 Tailwind 主题配置

```js
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        mainBg: 'var(--color-main-bg)',
        mainText: 'var(--color-main-text)'
      },
    },
  },
}
```

使用

```jsx
// 在最外层例如 Layout 或者 Provider 的 div 上加上主题名称即可
export const Layout = () => {
  const { theme } = useTheme()
  
  return (
  	<div className={`theme-${theme}`}></div>
  )
}
```

