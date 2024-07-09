---
title: TailwindCSS Tips
date: 2024-07-01T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [css, tailwindcss]
---
tailwindcss 虽然写起来很爽，心智负担非常小，但组件样式过长，难以维护等问题也会随着项目复杂度的提升而暴露出来

#### 如何在实际项目中是管理和组织样式类，以确保代码的可读性和可维护性？

解决方案 **通过 @apply 命令复用样式**

可以将重复样式抽离为一个类

使用 `@apply` 命令可以在 css 类中应用 tailwind 的类名

```css
.custom-class {
  @apply bg-rose-500 text-2xl shadow-xl
}
```

#### 如何自定义样式

有时 tailwind 内置的预设样式不能很好地适配项目需求，那么就需要扩展一些自定义样式

```js
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      // 自定义颜色
      colors: {
        'custom-blue': '#007bff',
        'custom-gray': '#6c757d',
      },
      // 自定义字体大小
      fontSize: {
        'xs': '.75rem',
        'sm': '.875rem',
        'tiny': '.875rem',
        'base': '1rem',
        'lg': '1.125rem',
        'xl': '1.25rem',
        '2xl': '1.5rem',
        '3xl': '1.875rem',
        '4xl': '2.25rem',
        '5xl': '3rem',
        '6xl': '4rem',
        '7xl': '5rem',
      },
      // 自定义间距
      spacing: {
        '128': '32rem',
        '144': '36rem',
      },
      // 自定义边框半径
      borderRadius: {
        'xl': '.75rem',
      },
      // 自定义阴影
      boxShadow: {
        'custom': '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1)',
      },
      // 自定义过渡时间
      transitionDuration: {
       '0': '0ms',
       '2500': '2500ms',
      },
      // 自定义动画
      animation: {
       spin: 'spin 3s linear infinite',
       ping: 'ping 1s cubic-bezier(0, 0, 0.2, 1) infinite',
      },
      // 自定义键盘帧
      keyframes: {
        wiggle: {
          '0%, 100%': { transform: 'rotate(-3deg)' },
          '50%': { transform: 'rotate(3deg)' },
        },
      },
      // 自定义 z-index
      zIndex: {
        '100': '100',
        '110': '110',
        // 更多自定义层级
      },
      // 自定义断点
      screens: {
        'sm': '640px',
        'md': '768px',
        'lg': '1024px',
        'xl': '1280px',
        '2xl': '1536px',
      },
    },
  },
  plugins: [],
}
```