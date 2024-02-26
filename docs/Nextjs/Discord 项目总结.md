---
title: Discord-clone 项目总结
date: 2024-02-06T10:29:00+08:00
sidebar-position: 2
authors: gsemir
tags: [Nextjs, TailwindCSS, Prisma, React, TypeScript, WebSocket, Clerk]

---

## 项目简介

基于 React、NextJS、TailwindCSS 以及 Prisma 的全栈项目，实现包括服务器、频道、实时通信、视频通话、音频通话、编辑和删除消息以及邀请成员等 Discord App 的基本功能。

- 源码：https://github.com/GSemir0418/discord-clone
- 网址：http://gsemir2.tpddns.cn:3000

### 技术栈/工具库

- [Nextjs14](https://nextjs.org/)
- [Clerk](https://clerk.com/)
- [SocketIO](https://socket.io/)
- [MySQL](https://www.mysql.com/)
- [React-Query](https://tanstack.com/query/latest/docs/framework/react/overview)
- [Zustand](https://github.com/pmndrs/zustand)
- [TailwindCSS](https://tailwindcss.com/)
- [ShadcnUI](https://ui.shadcn.com/docs)
- [Prisma](https://www.prisma.io/)
- [Livekit](https://livekit.io/)
- [Emoji](https://github.com/missive/emoji-mart)
- [UploadThing](https://uploadthing.com)

### Features

- 使用 Socket.io 进行实时通信
- 使用 UploadThing 实现文件上传与静态资源管理
- 成员信息支持实时删除和编辑
- 创建文本、音频和视频通话频道
- 成员之间的一对一对话与视频通话
- 成员管理（踢出、角色更改为访客/管理员）
- 通过邀请码及链接邀请成员
- 消息的滚动加载功能
- 服务器的创建和定制
- 使用 TailwindCSS 和 ShadcnUI 实现用户界面与响应式开发
- Websocket备用方案：使用警报进行轮询
- Typescript & NextJS 初始化
- 利用 Prisma 连接 MySQL
- 利用 Clerk 实现用户管理与鉴权
- 数据库设计
- 使用 Zustand 进行状态管理

### 项目结构

```sh
.
├── Dockerfile
├── README.md
├── app
│   ├── (auth)
│   │   ├── (routes)
│   │   │   ├── sign-in
│   │   │   │   └── [[...sign-in]]
│   │   │   │       └── page.tsx
│   │   │   └── sign-up
│   │   │       └── [[...sign-up]]
│   │   │           └── page.tsx
│   │   └── layout.tsx
│   ├── (invite)
│   │   └── (routes)
│   │       └── invite
│   │           └── [inviteCode]
│   │               └── page.tsx
│   ├── (main)
│   │   ├── (routes)
│   │   │   └── servers
│   │   │       └── [serverId]
│   │   │           ├── channels
│   │   │           │   └── [channelId]
│   │   │           │       └── page.tsx
│   │   │           ├── conversations
│   │   │           │   └── [memberId]
│   │   │           │       └── page.tsx
│   │   │           ├── layout.tsx
│   │   │           └── page.tsx
│   │   └── layout.tsx
│   ├── (setup)
│   │   └── page.tsx
│   ├── api
│   │   ├── channels
│   │   │   ├── [channelId]
│   │   │   │   └── route.ts
│   │   │   └── route.ts
│   │   ├── direct-messages
│   │   │   └── route.ts
│   │   ├── livekit
│   │   │   └── route.ts
│   │   ├── members
│   │   │   └── [memberId]
│   │   │       └── route.ts
│   │   ├── messages
│   │   │   └── route.ts
│   │   ├── servers
│   │   │   ├── [serverId]
│   │   │   │   ├── invite-code
│   │   │   │   │   └── route.ts
│   │   │   │   ├── leave
│   │   │   │   │   └── route.ts
│   │   │   │   └── route.ts
│   │   │   └── route.ts
│   │   └── uploadthing
│   │       ├── core.ts
│   │       └── route.ts
│   ├── favicon.ico
│   ├── globals.css
│   └── layout.tsx
├── components
│   ├── action-tooltip.tsx
│   ├── chat
│   │   ├── chat-header.tsx
│   │   ├── chat-input.tsx
│   │   ├── chat-item.tsx
│   │   ├── chat-messages.tsx
│   │   ├── chat-video-button.tsx
│   │   └── chat-welcome.tsx
│   ├── emoji-picker.tsx
│   ├── file-upload.tsx
│   ├── media-room.tsx
│   ├── mobile-toggle.tsx
│   ├── modals
│   │   ├── create-channel-modal.tsx
│   │   ├── create-server-modal.tsx
│   │   ├── delete-channel-modal.tsx
│   │   ├── delete-message-modal.tsx
│   │   ├── delete-server-modal.tsx
│   │   ├── edit-channel-modal.tsx
│   │   ├── edit-server-modal.tsx
│   │   ├── initial-modal.tsx
│   │   ├── invite-modal.tsx
│   │   ├── leave-server-modal.tsx
│   │   ├── members-modal.tsx
│   │   └── message-file-modal.tsx
│   ├── mode-toggle.tsx
│   ├── navigation
│   │   ├── navigation-action.tsx
│   │   ├── navigation-item.tsx
│   │   └── navigation-sidebar.tsx
│   ├── providers
│   │   ├── modal-provider.tsx
│   │   ├── query-provider.tsx
│   │   ├── socket-provider.tsx
│   │   └── theme-provider.tsx
│   ├── server
│   │   ├── server-channel.tsx
│   │   ├── server-header.tsx
│   │   ├── server-member.tsx
│   │   ├── server-search.tsx
│   │   ├── server-section.tsx
│   │   └── server-sidebar.tsx
│   ├── socket-indicator.tsx
│   ├── ui
│   │   ├── avatar.tsx
│   │   ...
│   │   ├── sheet.tsx
│   │   └── tooltip.tsx
│   └── user-avatar.tsx
├── components.json
├── eslint.config.js
├── hooks
│   ├── use-chat-query.ts
│   ├── use-chat-scroll.ts
│   ├── use-chat-socket.ts
│   ├── use-modal-store.ts
│   └── use-origin.ts
├── lib
│   ├── conversation.ts
│   ├── current-profile-pages.ts
│   ├── current-profile.ts
│   ├── db.ts
│   ├── initial-profile.ts
│   ├── uploadthing.ts
│   └── utils.ts
├── middleware.ts
├── next-env.d.ts
├── next.config.js
├── pack.sh
├── package-lock.json
├── package.json
├── pages
│   └── api
│       └── socket
│           ├── direct-messages
│           │   ├── [directMessageId].ts
│           │   └── index.ts
│           ├── io.ts
│           └── messages
│               ├── [messageId].ts
│               └── index.ts
├── postcss.config.js
├── prisma
│   └── schema.prisma
├── public
│   ├── next.svg
│   └── vercel.svg
├── setup.sh
├── tailwind.config.ts
├── tsconfig.json
└── types.ts
```

前后端路由结构与文件结构一致，所见即所得

## Nextjs 14

### 初始化

`npx create-next-app@latest discord-clone --typescript --tailwind --eslint`

### 路由

Nextjs 支持约定式路由，无论是 app 模式还是 pages 模式，都可以根据目录生成前后端的实际路由

#### (routes)

用于组织路由代码结构的目录，不会影响实际路由映射，可以利用这个特性，根据页面的布局对路由文件进行分类

#### [serverId]

动态路由目录

#### [[...sign-in]]

动态路由目录，可以捕获多个路由参数

#### layout.tsx

共享布局，作用于当前目录下的全部有效路由页面

#### page.tsx

前端路由页面代码

#### route.ts

app 模式下后端 api 代码

#### index.ts

pages 模式下的后端 api 代码

### 渲染

组件和布局代码要**默认导出**

服务端渲染（SSR）是指在服务器端生成完整的HTML内容并将其发送到客户端。这样可以提高性能，加快初始加载时间，并有利于搜索引擎优化（SEO）

客户端渲染（CSR）是指在客户端浏览器中使用JavaScript渲染网页，这样可以实现高度交互性和动态性。

#### 区别

1. 代码：服务端渲染的函数组件一般为 async 异步函数；客户端渲染的函数组件第一行使用 `use client` 关键字标注
2. 动态路由参数：服务端渲染的函数组件，动态路由的参数（文件夹存在中括号的，通常是id）在页面中用 props 取即可；而客户端渲染的组件需要使用 useParams hook 获取
3. 路由重定向：服务端渲染的组件/页面使用 next/navigation 提供的 redirect 方法，客户端渲染的组件使用 useRouter hook

#### 如何选择

| 用例                                                         | Server Component | Client Component |
| ------------------------------------------------------------ | ---------------- | ---------------- |
| 获取数据                                                     | ✅                | ❌                |
| 访问后端资源（直接）                                         | ✅                | ❌                |
| 将敏感信息保存在服务器上（访问令牌、API 密钥等）             | ✅                | ❌                |
| 在服务器上保留较大的依赖项/减少客户端 JavaScript             | ✅                | ❌                |
| 添加交互性和事件侦听器（ `onClick()` 、 `onChange()` 等）    | ❌                | ✅                |
| 使用状态和生命周期效果（ 、 `useState()` 、 `useReducer()` `useEffect()` 等） | ❌                | ✅                |
| 使用仅限浏览器的 API                                         | ❌                | ✅                |
| 使用 React 类组件                                            | ❌                | ✅                |

### 接口开发

#### app 模式

具名导出请求方法

```ts
import { NextResponse } from 'next/server'
export async function DELETE(req, { params }) {
  try {
    // 鉴权 ...
    if (!profile)
      return new NextResponse('Unauthorized', { status: 401 })
    // 取路由参数
    const { searchParams } = new URL(req.url)
    const serverId = searchParams.get('serverId')
    // 取动态路由参数
    params.channelId
    // 取请求体数据
    const body = await req.json()
    // 取表单提交数据
    const formData = await request.formData()
  	const name = formData.get('name')
  	const email = formData.get('email')
    // 返回 NextResponse 实例
    return NextResponse.json(server)
  } catch (err) {
    console.log('[XXX_ERROR]', err)
    return new NextResponse('Internal Error', { status: 500 })
  }
}
```

#### pages 模式

pages 模式默认导出接口处理函数，没有细分请求方法（需要手动区分）

```ts
import type { NextApiRequest, NextApiResponse } from 'next'

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse,
) {
  // 区别请求方法
  if (req.method !== 'DELETE' && req.method !== 'PATCH')
    res.status(405).json({ error: 'Method not allowed' })
  try {
    // 鉴权 ...
    if (!profile)
      return res.status(401).json({ error: 'Unauthorized' })
		// 取路由参数 (包括动态路由参数)
    const { messageId, serverId, channelId } = req.query
		// 取请求体数据
    const { content } = req.body
    if (req.method === 'DELETE') {}
    if (req.method === 'PATCH') {}
    // 返回 json 数据
    return res.status(200).json(message)
  }
  catch (error) {
    console.log('[XXX_ERROR]', error)
    return res.status(500).json({ error: 'Internal Error' })
  }
}
```

### 其他

`e.stopPropagation()` 来阻止其触发父元素的单击事件
`e.stopPropagation()` 是一个事件方法，用于阻止事件在捕获和冒泡阶段的进一步传播。它可以阻止事件冒泡到父元素或其他事件处理程序。

`rel='noopener noreferrer'` 是一种用于增强网站安全性的 HTML 属性。它可以防止新打开的页面获取对原始页面的访问权限，并且隐藏了引荐信息，使得在 Google Analytics 中无法追踪到引荐流量。这个属性对 SEO 没有直接影响，

## Prisma & MySQL

### 基本使用

- Prisma

安装：`npm i -D prisma`

初始化：`npx prisma init`

更新：`npx prisma generate`，用于安装 @prisma/client 包并生成 自定义的 Prisma Client。Prisma Client 是一个根据你的数据库模式自动生成的数据库客户端。它允许你在应用程序中创建数据库连接，并提供读写操作；

同步数据库：`npx prisma db push`

可视化：`npx prisma studio`  或者安装 mysql 插件

根据 prisma schema 生成类图：`AbianS.prisma-generate-uml`

唯一连接：使用全局变量解决 hot reload 导致的 prisma 连接被多次创建的问题

重置数据库：`npx prisma migrate reset`，然后再 generate 和 db push

- MySQL on Mac：

官网下载安装，设置 root 密码，环境变量 `export PATH=$PATH:/usr/local/mysql/bin`

显示全部数据库：`show databases;`

创建数据库 `create database discord_clone_db;`

查看 mysql 端口号 `SHOW GLOBAL VARIABLES LIKE 'PORT';`

- prisma 连接 MySQL

> https://www.prisma.io/docs/orm/overview/databases/mysql

构建连接字符串 `mysql://USER:PASSWORD@HOST:PORT/DATABASE?CONFIG`

在 .env 中定义连接字符串：`DATABASE_URL="mysql://root:xxxx@localhost:3306/discord_clone_db?schema=public"`

### 数据库设计

- 数据库表设计如下图：

![prisma](/Users/gsemir/Downloads/prisma.svg)

- Prisma Schema￼

```prisma
// 定义枚举
enum MemberRole {
  ADMIN
  MODERATOR
  GUEST
}

// 定义表结构
model Member {
	// 作为唯一标识符，使用 uuid() 函数生成默认值
  id   String     @id @default(uuid())
  role MemberRole @default(GUEST)

	// 字符串类型，用于关联 Profile 模型的 id 字段
  profileId String
  // Profile 类型，与 Profile 模型建立关联，关联字段为 profileId，引用字段为 id，级联删除
  profile   Profile @relation(fields: [profileId], references: [id], onDelete: Cascade)

  serverId String
  server   Server @relation(fields: [serverId], references: [id], onDelete: Cascade)

  messages       Message[]
  directMessages DirectMessage[]

	// Conversation 类型数组，表示成员发起的对话，使用 "MemberOne" 关联
  conversationInitiated Conversation[] @relation("MemberOne")
  conversationReceived  Conversation[] @relation("MemberTwo")

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

	// 为 profileId 字段创建索引，提高查询性能
  @@index([profileId])
  // 为 serverId 字段创建索引，提高查询性能
  @@index([serverId])
}
```

- 关联查询

include 用于指定在查询中要获取的关联数据，并允许你定义额外的选项，如排序规则等，用于在单个查询中获取与主模型（这里是 server）关联的其他模型（如 channels 和 members）的数据。

```js
const server = await db.server.findUnique({
  where: {
   id: serverId,
  },
  include: {
   channels: {
     orderBy: {
       createdAt: 'asc',
     },
   },
   members: {
     include: {
       profile: true,
     },
     orderBy: {
       role: 'asc',
     },
   },
  },
})
```

相当于

```sql
SELECT
server.*,
channels.*,
members.*,
profiles.*
FROM
server
LEFT JOIN
channels ON server.id = channels.serverId
LEFT JOIN
members ON server.id = members.serverId
LEFT JOIN
profiles ON members.profileId = profiles.id
WHERE
server.id = 'your_server_id'
ORDER BY
channels.createdAt ASC,
members.role ASC;
```

在使用 prisma 查询一条数据时，findFirst 和 findUnique 有啥区别，可以混用吗

## Shadcn UI

> https://juejin.cn/post/7324750282859528229?searchId=20240223165805DB547F57325B7BBBB68C

### 概述

Radix UI 是一个 Headless UI 库。也就是说，它有组件 API，但没有样式。Shadcn UI 建立在 Tailwind CSS 和 Radix UI 之上，目前支持 Next.js、Gatsby、Remix、Astro、Laravel 和 Vite，并且拥有与其他项目快速集成的能力

与常见的 UI 组件库（如 Ant desgin 和 Chakra UI）不同，Shadcn UI 实际上并不是组件库或 UI 框架。相反，它是可以根据文档“让我们**复制并粘贴**到应用程序中的可复用组件的**集合**”，可以将单个 UI 组件的源代码下载到项目源代码中（src 目录下），开发者可以自由的修改和使用想要的 UI 组件。

从前面的介绍能看出shadcn-ui和传统组件库有明显的差异， 我们也来看看它带来的显著优势：

- 开箱即用：任何具备 HTML、CSS、JavaScript 和一两个框架基础知识的人都可以快速开始使用 Shadcn UI。使用复制粘贴或 CLI 安装方法可以轻松访问其组件。同时它还具备良好的文档，可以查询组件说明。
- 可访问性：Shadcn UI 的组件完全可访问，并遵守 Web 内容可访问性指南 (WCAG) 标准。它支持屏幕阅读器、键盘导航和其他辅助功能。
- 细粒度控制和可扩展性：Shadcn UI 提供对每个组件源代码的直接访问，因此您可以轻松调整代码以适应独特的用例和应用程序需求。这种易于定制的特性有助于 Shadcn UI 在其他 UI 解决方案中脱颖而出，并使其使用起来很愉快。轻松访问组件代码还提高了灵活性，并使应用程序的扩展和维护变得更加容易

当然任何事情都是一把双刃剑，在看到这个优势的同时，我们也冷静的来看到一些问题：

- 额外的工作量：与其他组件库不同使用方式，会给开发者带来额外的手动操作工作量，虽然看似不多，但是在整个团队来说，积少也会成多。
- 代码膨胀：虽然直接访问组件的代码在模块化和可扩展性方面是有益的，但它也会导致更大的代码库和更多的代码行。
- 维护性：本身 shadcn-ui 就使用了 tailwind，所以也会面对和 tailwind 类似的问题，在大规模项目中，维护开支必然会有所增加。

> - cva 
>
> `Class Variance Authority` 的缩写，cva 是一个用于管理样式变体的库，用法类似于 clsx，支持传入配置项，将一个或多个类名作为属性值，属性名自定义，并最终将属性名映射为 props，从而帮助我们更好的组织样式变体，使得代码更加清晰，更加易于维护。
>
> - Slot 
>
> 来自 Radix UI，用于处理复杂组件封装时的 props 传递问题，通过 asChild 属性来判断是否启用 Slot，Slot 支持直接将 props 透传给内部的子组件
>
> - React.forwardRef 
>
> 也可以声明一个组件，但在 FC 的基础上强调了 ref 参数，虽然直接在组件的 props 类型中定义 ref 属性也可以传递 ref，但是使用 forwardRef 可以提供更清晰、更灵活、更易用的方式来处理 ref。

![shadcn](/Users/gsemir/Downloads/shadcn.png)

### 类名拼接


tailwind-merge 用来处理 tailwind 样式冲突问题，它可以让写在后面的样式覆盖前面的样式，这样我们就不需要使用!important来覆盖样式了。

clsx 允许我们使用 `classname: boolean` 的形式，动态控制 TailwindCSS 类名，更方便的通过条件去控制样式的变化

以上二者结合，可以作为 TailwindCSS 中的类名拼接方案

```ts
export function cn(...inputs: ClassValue[]) {
	return twMerge(clsx(inputs))
}

// 使用
className={clsx(
  "inline-flex rounded-lg font-medium disabled:opacity-20",
  {
    "bg-primary text-primary border-primary": type === "primary",
    "!rounded-full": shape === "round",
  }
)}

```

### 基本使用

初始化 shadcn 配置：`npx shadcn-ui@latest init`

根据命令行提示进行初始化配置，完成后会生成配置文件、基本样式和必要的工具函数。其中配置文件记录了该项目的开发环境配置以及一些文件目录等信息，方便 shadcn 下载合适的源代码及相关依赖到我们的项目中

添加组件：`npx shadcn-ui@latest add button`

### TailwindCSS

- 定位元素的布局

除了可以通过 `{top|bottom|right|left}-{size}` 来控制定位元素的布局，还有 `inset` 属性

`inset-x-0` 相当于 `left: 0px; right: 0px;`

`inset-y-0` 相当于 `top: 0px; bottom: 0px;`

- :focus

`:focus` 是通过鼠标点击元素获得焦点的伪类，而 :focus-visible 则是通过键盘使元素获得焦点时的伪类

`focus-visible:ring-0 focus-visible:ring-offset-0` 用于在用户使用键盘导航至该元素时，隐藏焦点环绕样式

实际作用的 css 属性就是 box-shadow 而已，ring 是元素外的环绕样式， border 是元素边框样式，仅仅为了提升用户体验

- 语义化元素

`kbd` Keyboard Input 元素，语义化元素之一，用于表示用户输入，例如

```
<kbd><kbd>CTRL</kbd>+<kbd>K</kbd></kbd>
```

`samp` Sample Output 元素，语义化元素之一，用于表示计算机程序输出，例如

```
<samp>Hello world</samp>
```

`pre` 元素，用于显示预格式化的文本，其中空格和换行符会保留原样，例如显示计算机代码

`<code>`元素用于显示短的计算机代码片段，也使用等宽字体显示

- 其他

`group-hover` 属性适用于根据父组件的状态（hover、focus、active）来声明样式

`gap-y-4` flex 或 grid 布局中，定义子元素垂直方向的间距

`ml-auto` 将该元素推到其父容器的最右边

`select-none` 用户无法选中

`text-muted-foreground` 用于设置文本的前景色，通常用于表示次要信息或者灰色文本

`line-clamp-1` 用于在指定的行数后截断文本，并添加省略号以指示文本已被截断。这个属性可以防止文本溢出其容器

## Clerk 认证

使用 Clerk 提供的服务、组件及鉴权中间件完成用户权限管理与登录注册功能

### 基本流程

https://clerk.com/ 注册账号

填写项目名称，选择权限提供商（这里选择 apple google 和 邮箱），点击创建即可

quickstarts 中选择 next.js，复制 API Keys 到项目根目录的 .env 文件下，记得 gitignore

点击 continue in docs，参考文档继续配置：

> https://clerk.com/docs/quickstarts/nextjs?_gl=1*vktqui*_gcl_au*Njg5NTcyMDM2LjE3MDM3NDI5NDg.*_ga*NTAxODYzNTE3LjE3MDM3NDI5NDg.*_ga_1WMF5X234K*MTcwMzc0Mjk0Ny4xLjEuMTcwMzc0MzQxOC4wLjAuMA..

安装 npm install @clerk/nextjs；

在最外层layout中使用 ClerkProvider 包裹 html；

创建鉴权的 middleware 作为路由守卫，复制示例代码；

创建页面：`app/(auth)/(routes)/sign-in/[[…sign-in]]/page.tsx`；`app/(auth)/(routes)/sign-up/[[…sign-up]]/page.tsx`，复制示例代码

Env 添加 url 配置，复制示例代码

启动项目，尝试注册登录

### 鉴权

app 模式下鉴权：

```ts
// lib/current-profile.ts
import { auth } from '@clerk/nextjs'
import { db } from './db'

export async function currentProfile() {
  const { userId } = auth()
  if (!userId)
    return null
  const profile = await db.profile.findUnique({
    where: {
      userId,
    },
  })
  return profile
}
```

pages 模式下鉴权

```ts
// lib/current-profile-pages.ts
import { getAuth } from '@clerk/nextjs/server'
import type { NextApiRequest } from 'next'
import { db } from './db'

export async function currentProfilePages(req: NextApiRequest) {
  const { userId } = getAuth(req)
  if (!userId)
    return null
  const profile = await db.profile.findUnique({
    where: {
      userId,
    },
  })
  return profile
}

```

- 中间件

```tsx
// middleware.ts
import { authMiddleware } from '@clerk/nextjs'

export default authMiddleware({
  // 其他 api 和 页面手动鉴权
  // 仅 /api/uploadthing 需要中间件介入鉴权
  publicRoutes: ['/api/uploadthing'],
})
```

## 文件上传

UploadThing 是全栈 TypeScript 应用中文件上传方案的最佳实践之一，支持文件托管、鉴权服务，并提供功能完善、开箱即用的前端上传组件

跟着文档走 https://docs.uploadthing.com/getting-started/appdir 安装依赖，添加环境变量，复制代码

创建 fileRouter，配置 serverImage 和 messageFile 两个上传端口的鉴权逻辑与上传选项

然后使用 createNextRouteHandler 将路由映射为 NextApiRouter 

```ts
import { auth } from '@clerk/nextjs'
import { type FileRouter, createUploadthing } from 'uploadthing/next'

const f = createUploadthing()

function handleAuth() {
  const { userId } = auth()
  if (!userId)
    throw new Error('Unauthorized')
  return { userId }
}

export const ourFileRouter = {
  serverImage: f({ image: { maxFileSize: '4MB', maxFileCount: 1 } })
    .middleware(() => handleAuth())
    .onUploadComplete(() => { }),
  messageFile: f(['image', 'pdf'])
    .middleware(() => handleAuth())
    .onUploadComplete(() => {}),
} satisfies FileRouter

export type OurFileRouter = typeof ourFileRouter
```

创建 file-upload 组件，作为 Form 的表单项，支持图片上传行为与预览

图片预览会报错，根据提示，需要在 next.config.js 添加 images 的 domains 配置

```js
const nextConfig = {
  images: {
    domains: [
      'uploadthing.com',
      'utfs.io',
    ],
  },
}
```

*TODO：后续计划使用 Golang 搭建一个本地的文件托管与上传服务*

## 弹窗

项目内部弹窗统一管理维护

### 设计

将 Modal 组件集中管理在 modal-provider 中 ，在 rootLayout 中统一以 Provider 组件的形式引入

```tsx
// components/providers/modal-provider.tsx
'use client'
import { useEffect, useState } from 'react'
// ...
import { DeleteMessageModal } from '@/components/modals/delete-message-modal'

export function ModalProvider() {
  const [isMounted, setIsMounted] = useState(false)

  useEffect(() => {
    setIsMounted(true)
  }, [])

  if (!isMounted)
    return null

  return (
    <>
      <CreateServerModal />
      // ...
      <DeleteMessageModal />
    </>
  )
}

// app/layout.tsx
export default function RootLayout({ children }) {
  return (
    <ClerkProvider>
      <html lang="en" suppressHydrationWarning>
        <body className="bg-white dark:bg-[#313338]">
          <ModalProvider />
        </body>
      </html>
    </ClerkProvider>
  )
}
```

使用基于 zustand 的 useModal hook 管理全局的 modal 状态，包括弹窗类型，弹窗数据，弹窗是否打开

```tsx
import type { Channel, ChannelType, Server } from '@prisma/client'
import { create } from 'zustand'

export type ModalType = 'createServer' | 'invite' | 'editServer' | 'members' | 'createChannel' | 'leaveServer' | 'deleteServer' | 'deleteChannel' | 'editChannel' | 'messageFile' | 'deleteMessage'

interface ModalData {
  server?: Server
  channel?: Channel
  channelType?: ChannelType
  apiUrl?: string
  query?: Record<string, any>
}

interface ModalStore {
  type: ModalType | null
  data: ModalData
  isOpen: boolean
  onOpen: (type: ModalType, data?: ModalData) => void
  onClose: () => void
}

export const useModal = create<ModalStore>(set => ({
  type: null,
  data: {},
  isOpen: false,
  onOpen: (type, data = {}) => set({ isOpen: true, type, data }),
  onClose: () => set({ isOpen: false, type: null }),
}))
```

### 使用

只需要一个 isOpen，配合 type 状态就可以控制全部 modal 的开启与关闭
具体实现：组件内部声明变量 isModalOpen = isOpen && type===‘createServer’ 作为 Modal 组件的 Open 属性 

```tsx
// components/modals/edit-channel-modal.tsx
'use client'
export function EditChannelModal() {
  const { isOpen, onClose, type, data } = useModal()
	// 弹窗打开
  const isModalOpen = isOpen && type === 'editChannel'
  // 弹窗数据
  const { channel, server } = data
  return (
    <Dialog open={isModalOpen} onOpenChange={handleClose}>
      ...
    </Dialog>
  )
}

// 使用
const { onOpen } = useModal()
const openModal = () => onOpen('deleteMessage', {
  apiUrl: `${socketUrl}/${id}`,
  query: socketQuery,
})}
```

> 为什么要用 isMounted 状态来解决 modal 组件导致的 hydration 错误？
>
> Next.js 项目的 Hydration 报错一般发生在服务器端渲染(SSR)和客户端渲染(CSR)中。在 React 中，改变某个页面组件的元素节点就被称为 Hydration。这个过程中，React 会试图通过将服务器端的 DOM 和客户端的 Virtual DOM 进行匹配来优化内容的加载。
>
> 因为 Hydration 需要确保服务器端 DOM 和客户端的 Virtual DOM 是一致的，否则就会报错。这就解释了为什么 Modal 组件容易引发这类错误，因为 Modal 组件往往是在特定条件（比如某个按钮点击）后才会呈现，这就导致了服务器端和客户端在渲染这个组件时的不一致。
>
> 在 Next.js 中，我们可以通过以下逻辑来规避一些 Hydration 错误：
>
> ```javascript
> const [isBrowser, setIsBrowser] = useState(false);
> 
> useEffect(() => {
>   setIsBrowser(true);
> }, []);
> 
> return isBrowser ? <Modal /> : null;
> ```
>
> 以上代码的逻辑是：我们使用 useState 和 useEffect 钩子初始化一个状态变量 `isBrowser`，并在组件挂在到 DOM 之后（即 useEffect 钩子执行后），将此变量设置为 true。然后在渲染 Modal 组件前，我们检查 `isBrowser` 的值，如果是 true 则渲染，否则返回 null。这样做的目的是延迟 Modal 组件的渲染，使其在浏览器环境中渲染，从而避免了服务器端和客户端的不一致情况。
>
> 因此，这个模式有效地解决了 Modal 组件可能导致的 Hydration 报错，因为它确保了 Modal 组件只在浏览器环境中渲染，避免了 SSR 和 CSR 的不一致。

## 邀请

服务器拥有者单击 `Invite People` 选项，打开 invite modal，通过 `origin + server.inviteCode` 拼接出邀请 url：`http://localhost:3000/invite/ead5fa1a-07cf-4f8d-9134-436e0f5ddb81` 供复制分享

支持刷新邀请码的操作，使用 Patch 方法调用 `/api/servers/${server?.id}/invite-code` 接口，通过 serverId 与 profileId 定位 server，重新生成其 `inviteCode` 字段值，刷新成功后，重新调用 onOpen 方法，将新的 server 数据传入即可

当邀请者登录账号并将打开邀请的 url 时，这个 url 对应页面的前端代码仅提供重定向逻辑，没有 dom 结构。首先鉴权，然后校验邀请码是否存在（且没有刷新过）。通过 `inviteCode` 以及 `profile.id` 查询此用户是否已经是该 server 的成员，如果是则直接重定向至对应 serverId 的页面即可；否则在 server 的成员中添加该用户，并重定向至对应 serverId 的页面即可。

**inviteCode** **就相当于** **server** **的动态** **id**

## 实时聊天

### Socket.io

- 初始化 socket io

`npm i socket.io socket.io-client`

- 使用 pages 模式开发 websocket 服务

App 模式下，`app/api/socket/io/routes.ts` 中只支持定义请求方法的同名方法，并以具名方式导出，这样才可以成功映射为 GET /api/socket/io 的后端路由。

但 socket io 服务是需要重写整个 `req/res handler` 的， 所以我们只能使用老版本（pages 模式）的写法来定义 socket 路由

两种模式都需要使用到，`app/api/messages` 提供 GET 方法，用于查询 message 数据；`pages/api/socket/messages` 提供 POST 方法，用于创建 message 数据，并触发 socket 响应

默认导出了 `ioHandler` 方法，在方法中把响应对象的 `res.socket.server.io` 指向了 socket io 服务端实例

```tsx
import type { Server as NetServer } from 'node:http'
import type { NextApiRequest } from 'next'
import { Server as ServerIo } from 'socket.io'
import type { NextApiResponseServerIo } from '@/types'

export const config = {
  api: {
    bodyParser: false,
  },
}

function ioHandler(req: NextApiRequest, res: NextApiResponseServerIo) {
  if (!res.socket.server.io) {
    const path = '/api/socket/io'
    const httpServer: NetServer = res.socket.server as any
    const io = new ServerIo(httpServer, {
      path,
      addTrailingSlash: false, // 控制是否在路径末尾添加斜杠
    })
    res.socket.server.io = io
  }
  res.end()
}

export default ioHandler
```

- Socket Context

使用 createContext 创建 SocketContext，储存 socket 客户端实例和连接状态；SocketContext.Provider 向全局提供这两个状态；结合 useSocket hook，使我们在组件代码中可以通过这个hook 获取这两个状态

```tsx
'use client'
import React, { createContext, useContext, useEffect, useState } from 'react'
import { io as ClientIO } from 'socket.io-client'

interface SocketContextType {
  socket: any | null
  isConnected: boolean
}

const SocketContext = createContext<SocketContextType>({
  socket: null,
  isConnected: false,
})

export function useSocket() {
  return useContext(SocketContext)
}

export function SocketProvider({ children }: { children: React.ReactNode }) {
  const [socket, setSocket] = useState(null)
  const [isConnected, setIsConnected] = useState(false)

  useEffect(() => {
    const socketInstance = new (ClientIO as any)(process.env.NEXT_PUBLIC_SITE_URL!, {
      path: '/api/socket/io',
      addTrailingSlash: false
    })

    socketInstance.on('connect', () => {
      setIsConnected(true)
    })

    socketInstance.on('disconnect', () => {
      setIsConnected(false)
    })

    setSocket(socketInstance)

    return () => {
      socketInstance.disconnect()
    }
  }, [])

  return (
    <SocketContext.Provider value={{ socket, isConnected }}>
      {children}
    </SocketContext.Provider>
  )
}
```

### Chat Header

用于显示当前频道名称/对话用户名称及头像、菜单显隐控制按钮和 socket  连接状态

- 入参

```tsx
interface Props {
  serverId: string // 传入 mobileToggle，渲染侧边栏导航组件
  name: string // 用户/频道名称
  type: 'channel' | 'conversation'
  imageUrl?: string // 用户头像url
}
```

- 移动端适配 `md:hidden`

屏幕尺寸小于 `md(768px)` 时，隐藏（`hidden`）侧边栏，显示 toggle 按钮，将侧边栏组件放入 sheet 组件中

### Chat Input

输入文字内容、Emoji或者上传附件（图片或pdf）

- 入参

```tsx
interface Props {
  apiUrl: string // 提交数据的 url
  query: Record<string, any> // 提交数据的 queryString（channelId serverId）
  name: string // placeholder 用
  type: 'conversation' | 'channel' // placeholder 用
}
```

在 pages/api/socket/messages.ts 中默认导出接口的 handler
第一行确认请求方法，然后 try catch 

- 创建 message

通过 req.body 在请求体中拿到消息内容或上传的url；通过 req.query 在查询字符串中拿到 serverId 和 channelId；鉴权、判断空值

首先根据 serverId 和 members 查询服务器数据，确定服务器存在以及当前用户数据该服务器的成员；关联查询服务器内部的 members 数据
其次根据 channelId 和 serverId 查询频道数据，确定服务器存在该频道

在 server 的 members 中找到当前用户的 memberId，用于创建 message

接口正常返回 200 前，通过 res?.socket?.server?.io?.emit(channelKey, message) 来向客户端发送消息；channelKey 用来标识 emit 的事件

- Message Attachment 消息附件

用 create server 弹窗改改，name去掉，弹窗取出 apiUrl 和 query 用于提交数据
在 file-upload 组件扩展出 pdf 文件上传及预览功能

- Emojibar

使用 emoji-mart/react 库完成 EmojiPicker 组件

`npx shadcn-ui@latest add popover`

`npm i emoji-mart @emoji-mart/data @emoji-mart/react`

### Chat Message

用于请求与渲染聊天内容

入参：

```tsx
interface Props {
  name: string // channel名称
  member: Member // 成员，传入 item 组件，用于做头像展示、点击跳转私聊等功能
  chatId: string // channelId，用来构造 queryKey，标记请求的key
  apiUrl: string 使用 // http 轮询请求聊天数据的 url
  socketUrl: string // 使用 socket 实时获取聊天数据的 url
  socketQuery: Record<string, string> // socket 查询对象，包括 serverId 和 channelId
  paramKey: 'channelId' | 'conversationId' // 查询对象的 key，用于动态区分 channel 和 conversation，用于 http 轮询的 param
  paramValue: string // 对应 paramKey 的 value
  type: 'channel' | 'conversation'
}
```

封装了三个 hooks ，分别用于轮询更新实时数据、连接 socket 同步更新数据以及滚动加载更多数据；其中，轮询方案除了初始查询之外，也作为了 socket 方案失败的兜底方案

```tsx
const { data, fetchNextPage, hasNextPage, isFetchingNextPage, status } = useChatQuery({
  queryKey,
  apiUrl,
  paramKey,
  paramValue,
})

useChatSocket({ queryKey, addKey, updateKey })

useChatScroll({
  chatRef,
  bottomRef,
  loadMore: fetchNextPage,
  shouldLoadMore: !isFetchingNextPage && !!hasNextPage,
  count: data?.pages?.[0]?.items.length ?? 0,
})
```

### cursor + InfiniteQuery 分页方案请求

使用 react-query 进行数据请求：`npm i @tanstack/react-query`

创建 query-provider，将 queryClient 实例状态提供给全局

- app 模式下的 http get message 逻辑：

从 searchParams 中拿到 cursor 和 channelId，每次查 10 条数据，如果有 cursor 标记，则从 cursor 标记的 id 开始查（skip 掉自己）；然后通过 messages.length 判断并计算 nextCursor，将 messages 和 nextCursor 做为响应体返回即可

react-query 提供了 `useInfiniteQuery` hook ，自带分页功能，其入参的 `getNextPageParam` 方法，将本次响应体数据作为参数，返回下次调用 queryFn 方法的入参，起到承上启下的作用，为本方案的核心方法

 queryFn 就是查询数据的方法，内部可以使用 fetch 也可以使用 axios

在 http get message api 中，处理并返回了 nextCursor id，所以在 getNextPageParam 中，将响应体的 nextCursor 数据设置为下次 queryFn 的参数，把这个参数作为 url params 调用接口，形成闭环

 useInfiniteQuery hook 返回了 data（响应数据）、fetchNextPage（发起下次请求的方法）、hasNextPage（下一页是否存在）、isFetchingNextPage（是否正在请求下页数据）、status（请求状态）

其中，hasNextPage 同样也是取决于 getNextPageParam 方法是否返回了有效的 nextCursor

```tsx
const {
  data,
  fetchNextPage,
  hasNextPage,
  isFetchingNextPage,
  status,
} = useInfiniteQuery({
  initialPageParam: undefined,
  queryKey: [queryKey],
  queryFn: fetchMessages,
  getNextPageParam: lastPage => lastPage?.nextCursor,
  refetchInterval: isConnected ? false : 1000,
})
```

### Chat socket hook

用于监听 socket 事件，同步更新聊天数据的 hook

我们通过 `api/socket/messages` 接口创建或修改 message 时，都会 emit 事件（`chat:[chatId]:messages` 或者 `chat:[chatId]:messages:update`）

所以在 chat socket hook 中，我们需要为 socket 添加对应的事件监听，并在事件触发时同步更新聊天数据

React-query 提供了 useQueryClient hook，返回 queryClient 实例。通过 queryClient 中的 setQueryData 方法可以同步修改某个查询（通过 queryKey 匹配）的（缓存）数据。这里通过 useChatQuery 中轮询的 queryKey 来匹配修改之前到获取的 message list

```tsx
export function useChatSocket({
  addKey,
  updateKey,
  queryKey,
}: Props) {
  const { socket } = useSocket()
  const queryClient = useQueryClient()

  useEffect(() => {
    if (!socket)
      return
    socket.on(updateKey, (message: MessageWithMemberWithProfile) => {
      queryClient.setQueryData([queryKey], (oldData: any) => {
        // ...
        return { ...oldData, pages: newData }
      })
    })

    socket.on(addKey, (message: MessageWithMemberWithProfile) => {
      queryClient.setQueryData([queryKey], (oldData: any) => {
        // ...
        return { ...oldData, pages: newData }
      })
    })

    return () => {
      socket.off(addKey)
      socket.off(updateKey)
    }
  }, [queryClient, addKey, queryKey, socket, updateKey])
}
```

### Chat scroll hook

接收 chat message div、bottom div（chat 最下方的空 div）、shouldLoadMore、loadMore 方法、count（数据总数）五个参数

shouldLoadMore：没有正在请求下页数据，并且存在下页数据时，可以加载更多

Hook 中主要有两个 useEffect 组成

第一个主要负责监控聊天框的滚动事件。当 chat div 的滚动条位于顶部（scrollTop = 0）且可以加载更多时，调用 loadMore 即可；

```tsx
useEffect(() => {
	const topDiv = chatRef?.current

	const handleScroll = () => {
		const scrollTop = topDiv?.scrollTop

		if (scrollTop === 0 && shouldLoadMore)
			loadMore()
	}

	topDiv?.addEventListener('scroll', handleScroll)

	return () => topDiv?.removeEventListener('scroll', handleScroll)
}, [shouldLoadMore, loadMore, chatRef])
```

第二个主要负责自动滚动聊天框以保持最新的消息可见。使用 hasInitialized state 作为标记，第一次渲染时将其设置为 true，并执行一次 autoScroll（以确保在初始化时自动滚动），autoScroll 就是将 bottom div scrollIntoView 即可。后续当 count 变化时，检查聊天框顶部与底部的距离。如果距离小于等于100像素，表示接近底部，此时执行 autoScroll（防止当用户在浏览历史信息时，突然滚动到最下方）

```tsx
const [hasInitialized, sethasInitialized] = useState(false)
useEffect(() => {
	const bottomDiv = bottomRef?.current
	const topDiv = chatRef.current
	const shouldAutoScroll = () => {
		if (!hasInitialized && bottomDiv) {
			sethasInitialized(true)
			return true
		}
		if (!topDiv)
			return false

		const distanceFromBottom = topDiv.scrollHeight - topDiv.scrollTop - topDiv.clientHeight
		return distanceFromBottom <= 100
	}

	if (shouldAutoScroll()) {
		setTimeout(() => {
			bottomRef.current?.scrollIntoView({
				behavior: 'smooth',
			})
		}, 100)
	}
}, [bottomRef, chatRef, count, hasInitialized])
```

### Chat Item

用于展示用户头像、聊天信息等，支持消息的编辑与删除功能，在频道中支持点击头像进入私聊页面

组件入参一览：

```tsx
interface Props {
  id: string // messageId
  content: string // messageContent
  member: Member & {
    profile: Profile
  } // message owner
  timestamp: string // 展示 message 的 createAt
  fileUrl: string | null
  deleted: boolean // 是否被删除
  currentMember: Member // 当前登录用户
  isUpdated: boolean // 是否被编辑过（updatedAt === createdAt）
  socketUrl: string 
  socketQuery: Record<string, string>
}
```


根据权限与content type分情况动态渲染

```tsx
const fileType = fileUrl?.split('.').pop()
const isAdmin = currentMember.role === 'ADMIN'
const isModerator = currentMember.role === 'MODERATOR'
const isOwner = currentMember.id === member.id
const canDeleteMessage = !deleted && (isAdmin || isModerator || isOwner)
const canEditMessage = !deleted && isOwner && !fileUrl
const isPDF = fileType === 'pdf' && fileUrl
const isImage = !isPDF && fileUrlnpm i date-fns 处理时间格式的库 https://date-fns.org/
```

## 视频通话

> https://livekit.io/

选择 cloud 使用 github 登录
setting => keys => add new key => 写描述，然后将生成的三个信息复制到 .env 中

```
LIVEKIT_API_KEY=xxx
LIVEKIT_API_SECRET=xxx
NEXT_PUBLIC_LIVEKIT_URL=xxx
```


之后跟着文档 https://docs.livekit.io/realtime/quickstarts/nextjs-13/

组件也都是 livekit 提供好的

## 部署

主要包括打包、初始化、docker 容器构建三个过程

### 服务器环境

服务器需要安装 docker 环境，并配置代理

### 打包

将整个项目除 `node_modules` 和 `.next` 外的全部文件压缩，将包上传至远程部署目录，在服务端解压缩，清理本地缓存。最后在服务端继续执行初始化脚本

```bash
# pack.sh
#!/bin/bash
function title {
  echo 
  echo "###############################################################################"
  echo "## $1"
  echo "###############################################################################" 
  echo 
}

user=ubuntu
ip=gsemir2.tpddns.cn

project_name=discord-clone
time=$(date +'%Y%m%d-%H%M%S')
current_dir=$(dirname $0)
deploy_dir=/home/$user/deploys/node/$project_name/$time

title '1 项目压缩'
tar -czf $project_name.tar.gz --exclude='node_modules' --exclude='.next' -C $current_dir .
title '2 创建远程目录'
ssh $user@$ip "mkdir -p $deploy_dir"
title '3 上传包至远程目录'
scp $project_name.tar.gz $user@$ip:$deploy_dir
title '4 解压缩'
ssh $user@$ip "tar -xzf $deploy_dir/$project_name.tar.gz -C $deploy_dir"
title '5 清理缓存'
rm $project_name.tar.gz
ssh $user@$ip "rm $deploy_dir/$project_name.tar.gz"
title '6 执行远程部署脚本'
ssh $user@$ip "export time=$time; /usr/bin/zsh $deploy_dir/setup.sh"

```

### DockerFile

node 环境，安装依赖，最后 `npm start` 启动项目即可

```dockerfile
FROM node:20.10.0
ENV NODE_ENV=production
# 创建工作路径
WORKDIR /usr/src/app
# 配置容器的 npm 源
RUN npm set registry http://registry.npmmirror.com
# 将本地的package.json复制到容器工作目录
# COPY package.json ./
# COPY package-lock.json ./
COPY . .
RUN npm install
RUN npm run build
# 将本地根目录下的全部文件都拷贝至容器工作目录
RUN npx prisma generate
RUN npx prisma db push
EXPOSE 3000
# 在容器运行启动命令
CMD [ "npm", "start"]
```

- Dockerfile 中的 CMD、RUN 和 ENTRYPOINT 是用于定义 Docker 镜像各个方面的指令。它们之间有一些区别和联系。

  - RUN 指令用于执行命令并创建新的镜像层。这意味着在构建镜像时执行的命令会在当前镜像的基础上创建一个新的镜像层。

  - CMD 指令用于设置容器启动后默认执行的命令及其参数。但是，CMD 可以被 docker run 命令行参数替换。

  - ENTRYPOINT 指令配置容器启动时要运行的命令，与功能角度上的 CMD 类似。它设置容器启动时要运行的命令，但是可以被 docker run 命令行参数替换。

  - 在 Dockerfile 中，通常会同时设置 ENTRYPOINT 和 CMD，以便在容器启动时定义要执行的命令，并设置默认参数。如果不正确地设置 CMD 而不是 ENTRYPOINT，用户可能无法直接通过 docker run 命令传递参数给二进制文件。

    因此，根据 Dockerfile 中的规则，应该将 ENTRYPOINT 设置为容器内要执行的进程的路径，将 CMD 设置为要传递给该命令的默认参数。

- ```dockerfile
  RUN apt-get install python3
  ENTRYPOINT ["echo", "Hello,"]
  CMD ["World"]
  ```

### 初始化

初始化脚本主要负责控制服务器中的 docker 容器启停与镜像构建

```bash
# setup.sh
#!/bin/bash
# 容器内运行的脚本

function title {
  echo 
  echo "###############################################################################"
  echo "## $1"
  echo "###############################################################################" 
  echo 
}

user=ubuntu
project_name=discord-clone
container_name=gsemir/discord-clone
deploy_dir=/home/$user/deploys/node/$project_name/$time

cd $deploy_dir
title '远程1 停止并删除旧容器'
docker stop $(docker ps -a -q --filter ancestor=$container_name)
docker rm $(docker ps -a -q --filter ancestor=$container_name)
title '远程2 构建镜像'
docker build -t $container_name .
title '远程3 启动容器'
docker run -p 3000:3000 -d $container_name
```

只需在本地环境执行 `sh pack.sh` 即可实现项目的打包部署

### 注意事项

- 浏览器不允许 http 站点访问用户的摄像头、麦克风等权限，导致项目的视频语音通话功能无法实现。此时需要访问 `chrome://flags`，将 `Insecure origins treated as secure` 选项启动，并输入我们的 http 站点即可

![image-20240219094903262](/Users/gsemir/Library/Application Support/typora-user-images/image-20240219094903262.png)