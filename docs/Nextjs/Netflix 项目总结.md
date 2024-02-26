---
title: Netflix-clone 项目总结
date: 2023-06-14T15:19:00+08:00
sidebar-position: 1
authors: gsemir
tags: [Nextjs, TailwindCSS, Prisma, React, TypeScript]
---

## 项目简介

基于 React、NextJS、TailwindCSS 以及 Prisma 的全栈项目，实现 Netflix 官网的部分功能。

- 源码：https://github.com/GSemir0418/netflix-clone
- 网址：https://netflix-clone-sigma-swart-93.vercel.app/

### 技术栈

- [NextJS](https://nextjs.org/)
- [Next-Auth](https://next-auth.js.org/)
- [MongoDB](https://www.mongodb.com/atlas/database)
- [SWR](https://swr.vercel.app/zh-CN)
- [Zustand](https://github.com/pmndrs/zustand)
- [TailwindCSS](https://tailwindcss.com/)
- [Prisma](https://www.prisma.io/)

### Features

- Typescript & NextJS 初始化
- 利用 Prisma 连接 MongoDB
- 利用 NextAuth 实现前后端权限校验/路由守卫，实现 Google & Github 等第三方账户登录
- API 与 Controllers 设计与实现
- 使用 TailwindCSS 实现响应式布局及细节动效
- 使用 React SWR 进行数据请求与重新验证
- 使用 Zustand 进行状态管理（Modal 组件）

### Why Nextjs?

1. [官方力推](https://react.dev/learn/start-a-new-react-project#nextjs-app-router)
2. [大势所趋](https://2022.stateofjs.com/zh-Hans/libraries/rendering-frameworks/)
3. 开箱即用
4. SSR

## Prisma & MongoDB

### Prisma 初始化

1. 依赖安装
    - 安装 prisma cli：`npm install -D prisma`
    - 安装 prisma clent：`npm install @prisma/client`
    - 安装 VSCode 插件：`Prisma.prisma`

2. 运行 `npx prisma init --datasource-provider mongodb`，生成初始化文件，指定数据库为 mongodb
    - `prisma/schema.prisma`：prisma 配置及数据模型
    - `.env`：prisma 环境变量，例如 DATABASE_URL。同时也可以维护项目中用到的环境变量，例如 NEXTAUTH_SECRET

3. 创建 `libs/prismadb.ts` ，用于创建 Prisma Client 实例，供服务端调用。这里需要注意，在开发环境下热加载导致Prisma Client 实例会被重复多次创建，因此我们需要将实例挂载到 global 对象上，因为 global 对象不会受到热加载影响。

```ts
import { PrismaClient } from '@prisma/client'

const client = global.prismadb || new PrismaClient()
if (process.env.NODE_ENV === 'production')
  global.prismadb = client

export default client
```

### 定义 schema

- 由于本项目支持第三方账户登录，因此需要参考[文档](https://authjs.dev/reference/adapter/prisma)中，关于第三方账户登录所必须的 schema 字段，将其添加到我们自己的 `schema.prisma` 中。在此基础上，加上我们的业务数据表字段 Movie

- 每个表的 id 字段，对于 MongoDB 的连接，部分字段需要特殊配置
  - 映射为 `_id` 字段，在数据库中的数据类型为 ObjectId
  - `id String @id @default(auto()) @map("_id") @db.ObjectId`
  - 对于其他数据库的连接，由于 prismaDB 中数据类型的局限性，部分字段也需要根据实际情况做一些调整。例如在连接 MySQL 数据库时，`id_token` 字段如果使用 `String` 类型的话会出现字符长度不够的问题，这是因为 `Prisma.String` 映射的是 `varchar(191)`，因此建议显示指定数据字段类型为 `@db.Text` 来解决这个问题。

### 初始化 MongoDB 云数据库

1. 访问 [MongoDB Atlas](https://www.mongodb.com/cloud/atlas/register)

2. 创建用户，创建 project / cluster

3. 连接时设置 ip 地址，并选择 VSCode 连接方式；

4. 将 url 复制到 `.env` 文件的 `DATABASE_URL` 变量。url 示例如下

    `mongodb+srv://[USERNAME]:[PASSWORD]@cluster-netflix-clone.tnttogg.mongodb.net/[DATABASENAME]`

5. 执行 `npx prisma db push` 同步数据库，一般用于原型设计阶段初始化数据库时。

6. 若要修改数据库字段，可以使用迁移命令：`npx prisma migrate dev`，值得注意的是 MongoDB 不支持任何迁移命令，仅支持 `db push`

### Prisma Client API

> https://www.prisma.io/docs/reference/api-reference/prisma-client-reference

- `findUnique`: 查询单条数据，没查到返回 null
```js
const existingMovie = await prismadb.movie.findUnique({
  where: {
    id: movieId,
  },
})
```
- `findMany`: 查询多条数据
    - 利用 take 和 skip 属性实现分页需求
```js
const randomMovies = await prismadb.movie.findMany({
  take: 1,
  skip: randomIndex,
})
```
- `create`: 创建数据
```js
const user = await prismadb.user.create({
  data: {
    email,
    name,
    hashedPassword,
    image: '',
    emailVerified: new Date(),
  },
})
```
- `update`: 更新数据
```js
const user = await prismadb.user.update({
  where: {
    email: currentUser.email || '',
  },
  data: {
    favoriteIds: {
      // 数组类型支持 push, prepend, append, set
      push: movieId,
    },
  },
})
```

### Prisma 多环境配置

- 环境变量文件分为 `.env.dev` 与 `.env.test`

- 安装 `dotenv`：`npm install -g dotenv-cli`

- 在执行同步数据库命令前，使用 `dotenv` 工具指定环境变量文件即可:
    - `dotenv -e .env.test -- npx prisma migrate deploy`
    - `dotenv -e .env.dev -- npx prisma migrate dev`

- 生产环境的 .env.production 不应在本地维护

## API 开发

- 约定式路由，例如 pages/api/register.ts 会被映射为 `api/register`

- 默认导出名称为 `handler` 的异步函数，函数接收两个参数，分别是 request 和 response 对象

### Request

- `req.cookies` - request 中的 cookie 对象，默认 {}
- `req.query` - request 中的查询字符串对象，默认 {}
- `req.body` - 根据 content-type 解析出来的请求体对象 | null

### Response

- `res.status(code)` - 设置响应状态码
- `res.json(body)` - 发送 JSON 响应，并设置 Content-Type 头为 `application/json`，body 须是可序列化的对象
- `res.send(body)` - 发送 HTTP 响应，body 可以是任意类型的参数，数字、字符串、对象或 Buffer
- `res.end()` - 手动结束请求响应周期。json 和 send 方法自动结束，无需调用；而 write 或者 status 等方法则需要手动调用 end 方法结束相应周期
- res 方法均支持链式调用

### Favorite API

favorite api 提供“增加喜爱项”和“移除喜爱项”两个功能

参考 RESTFUL 规范，将 favorite 作为资源，通过请求方法（POST | PATCH）区分以上两种功能
```ts
export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  try {
    if (req.method === 'POST') {
      const { currentUser } = await serverAuth(req, res)

      const { movieId } = req.body

      const existingMovie = await prismadb.movie.findUnique({
        where: {
          id: movieId,
        },
      })
      if (!existingMovie)
        throw new Error('Invalid ID')

      const user = await prismadb.user.update({
        where: {
          email: currentUser.email || '',
        },
        data: {
          favoriteIds: {
            push: movieId,
          },
        },
      })

      return res.status(200).json(user)
    }

    if (req.method === 'PATCH') {
      const { currentUser } = await serverAuth(req, res)

      const { movieId } = req.body

      const existingMovie = await prismadb.movie.findUnique({
        where: {
          id: movieId,
        },
      })

      if (!existingMovie)
        throw new Error('Invalid ID')

      const updateFavoriteIds = without(currentUser.favoriteIds, movieId)

      const updatedUser = await prismadb.user.update({
        where: {
          email: currentUser.email || '',
        },
        data: {
          favoriteIds: updateFavoriteIds,
        },
      })

      return res.status(200).json(updatedUser)
    }

    return res.status(405).end()
  }
  catch (error) {
    console.error(error)
    return res.status(400).end()
  }
}
```

## TailwindCSS

- 原子化 CSS 框架（PostCSS 插件）

传统 css 写法是定义 class，然后在 class 内部写样式，而原子化 css 是预定义一些细粒度 class，通过组合 class 的方式完成样式编写。

### 优势

- 预设成熟的设计规范（Sizing/Color/Typography/Shadows）
- 按需生成 CSS，样式复用度高
- 强大的响应式
- 简化伪类状态（hover/focus）
- 灵活的主题、默认样式定义
- 完善的 IDE 支持

### 缺陷

- 可维护性差 => 注释

### 初始化配置

1. 创建 tailwind 配置文件

2. 开启 postcss 插件

3. global.css 中引入基础样式

```css
/* 使用Tailwind的基础CSS样式，包括重置浏览器默认样式、设置全局盒模型等 */
@tailwind base;
/* 使用Tailwind的组件CSS样式，包括按钮、表格、表单等常用UI组件的样式 */
@tailwind components;
/* 使用Tailwind的工具CSS样式，包括类似于margin、padding、text-align等常用CSS样式规则的快捷类名，可以直接应用在HTML标记上 */
@tailwind utilities;

body {
  @apply bg-zinc-900 h-full overflow-x-hidden;
}
```

### 常用属性

- transition

使元素样式切换更加平滑
```css
.transition {
  transition-property: color, background-color, border-color, text-decoration-color, fill, stroke, opacity, box-shadow, transform, filter, backdrop-filter;
  transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
  transition-duration: 150ms;
}
```

- group

group 标记，定义在父元素类名中，用于处理相互关联的元素的样式。可以使用伪类选择器（group-hover 或 group-focus）来联动切换子元素的样式
```js
<div className="group">
  <img
    className='group-hover:opacity-90 sm:group-hover:opacity-0'/>
</div>
```
- h-[56.25vw]

设置高度为视口宽度的56.25%
56.25%是为了创建一个固定宽高比（16：9）的元素 保证不同屏幕尺寸下的呈现效果

- drop-shadow-xl

在元素周围添加一个较大尺寸（xl）的 box-shadow

- object-cover

适用于图像或视频，根据父元素宽高比进行缩放或裁剪，以填满父元素
```css
.object-cover {
  object-fit: cover;
}
```

- origin-[0]

设置变换的原点为左上角 1 表示右上 4 表示中间

### 响应式

| Breakpoint prefix | Minimum width | CSS                                  |
| ----------------- | ------------- | ------------------------------------ |
| `sm`              | 640px         | `@media (min-width: 640px) { ... }`  |
| `md`              | 768px         | `@media (min-width: 768px) { ... }`  |
| `lg`              | 1024px        | `@media (min-width: 1024px) { ... }` |
| `xl`              | 1280px        | `@media (min-width: 1280px) { ... }` |
| `2xl`             | 1536px        | `@media (min-width: 1536px) { ... }` |

### 实践

- 清除input默认样式
```
appearance-none
focus:outline-none
// 聚焦时移除输入框的焦点环
focus:ring-0
```

- 响应式grid布局
```jsx
<div class="
  grid
  grid-cols-1
  sm:grid-cols-2
  md:grid-cols-3
  lg:grid-cols-4
  gap-4
  ">
    <div class="bg-gray-200 p-4">内容1</div>
    ...
    <div class="bg-gray-200 p-4">内容6</div>
</div>
```
- 长宽不等的网格布局：配合网格元素的 `col-span-x` 或 `row-span-x`
```jsx
<div class="grid grid-cols-3 grid-rows-2 gap-4">
  <div class="bg-gray-200 p-4">内容1</div>
  <div class="bg-gray-200 p-4">内容2</div>
  <div class="bg-gray-200 p-4 col-span-2 row-span-2">内容3</div>
  <div class="bg-gray-200 p-4">内容4</div>
</div>
```
如果不指定 col-span 后面的数量，以 tw 默认配置为准（1）

- 输入框标签上移效果

利用 peer (基于同级元素的状态应用标记) 来实现
```jsx
<>
  <input className="peer" />
  <label
    className="
      // 当 peer 元素的 placeholder 有值时，将本元素的缩放设置为原始大小
      peer-placeholder-shown:scale-100
      peer-placeholder-shown:translate-y-0
      peer-focus:scale-75
      // 当 peer 元素聚焦时，将本元素的垂直位移向上移动 3 个单位
      peer-focus:-translate-y-3
    "
  >
    {label}
  </label>
</>
```

- 展开图标动效

className中插入三元运算符，根据状态判断其 rotate 角度（180/0）
```
transition 
${visible ? 'rotate-180' : 'rotate-0'}
```

- Navbar 滚动透明

监听滚动事件，超过预设距离后，改变state，从而改变背景样式（className）
```tsx
useEffect(() => {
  const handleScroll = () => {
    if (window.scrollY >= TOP_OFFSET)
      setShowBg(true)
    else setShowBg(false)
  }
  window.addEventListener('scroll', handleScroll)
  return () => {
    window.removeEventListener('scroll', handleScroll)
  }
}, [])
// ...
// classname={`${showBg ? ' bg-zinc-900 bg-opacity-90' : ''}`}
```
- 建议将响应式内容写在一行

`w-[90%] md:w-[80%] lg:w-[50%]`

## Next-Auth

Nextjs 为我们提供了前后端鉴权的最佳实践方案之一，并封装为 Next-Auth 工具

### 前后端的权限校验流程

利用 next-auth 提供的 `getServerSession` 以及 `getSession` 方法来处理权限校验问题

#### 前：路由守卫

- 通过 getServerSideProps 守卫

`getServerSideProps => getSession(context) => session | null => return redirect | return props {}`

#### 后：接口 

- controller 最前加 getServerSession 方法 成功就继续 失败就400

`getServerSession(req, res, authOptions) => session | null => userInfo | null => return currentUser | throw Error`

### OAuth 第三方登录

> 登录基本原理: https://authjs.dev/concepts/oauth

1. 创建 `pages/api/auth/[...nextauth].ts`
2. 定义 auth 配置项：
    - `provider`：数组，其概念就是验证用户身份的不同方式，例如用户名/密码、Github 登录、Google 登录等，每个 `provider`(提供者)就相当于一个独立的身份验证服务
3. 除支持第三方登录功能之外，还需定义一个自定义验证方式，用于传统的邮箱密码登录。
    - 此 Credential 实例需有 `credential` 属性（指定校验字段）与 `authorize` 方法（返回用户数据）
4. 配置登录页面路由、jwt 密钥及 cookie 密钥等
```ts
export const authOptions: AuthOptions = {
  providers: [
    GithubProvider({
      clientId: process.env.GITHUB_ID || '',
      clientSecret: process.env.GITHUB_SECRET || '',
    }),
    GoogleProvider({
      clientId: process.env.GOOGLE_CLIENT_ID || '',
      clientSecret: process.env.GOOGLE_CLIENT_SECRET || '',
    }),
    // 自定义一个 Credentials 提供者实例用于邮箱密码登录方式
    Credentials({
      id: 'credentials',
      name: 'Credentials',
      credentials: {
        email: {
          label: 'Email',
          type: 'text',
        },
        password: {
          label: 'Password',
          type: 'password',
        },
      },
      // 定义身份验证的授权函数，成功后返回用户对象
      async authorize(credentials) {
        // 如果没有 email 或 password 直接报错
        if (!credentials?.email || !credentials?.password)
          throw new Error('Email and password required')

        // 根据 email 找到 用户
        const user = await prismadb.user.findUnique({
          where: {
            email: credentials.email,
          },
        })
        // 如果找不到用户或者密码不存在，则说明用户不存在
        if (!user || !user.hashedPassword)
          throw new Error('Email does not exist')
        // 比较密码是否正确
        const isCorrectPassword = await compare(
          credentials.password, user.hashedPassword,
        )
        // 不正确就报错
        if (!isCorrectPassword)
          throw new Error('Incorrect password')

        return user
      },
    }),
  ],
  // 指定自定义登录路由
  pages: {
    signIn: '/auth',
  },
  // 开发环境启用调试模式
  debug: process.env.NODE_ENV === 'development',
  adapter: PrismaAdapter(prismadb),
  // 配置会话策略为 jwt/database
  session: {
    strategy: 'jwt',
  },
  // 配置 jwt 密钥
  jwt: {
    secret: process.env.NEXTAUTH_JWT_SECRET,
  },
  // 设置 cookie 密钥
  secret: process.env.NEXTAUTH_SECRET,
}

export default NextAuth(authOptions)
```

### 获取 OAuth Secret

- github

    1. Settings -> Developer settings -> OAuth Apps -> Register a new application

    2. 设置名称、url等配置

    name: 'netflix-clone'
    Homepage URL: 'http://localhost:3000' // 生产环境会改成别的
    Authorization callback URL: 'http://localhost:3000'

    3. 将生成的 Client ID 和 Client Secret 复制到 env 中

- google

    1. google 搜索 google developer console
    2. 创建项目
    名称: 'netflix-clone'
    3. 搜索栏搜索 api -> api service -> OAuth consent screen
    4. External ✅ -> create
    name: 'netflix-clone' , email *2
    5. continue -> done
    6. Credentials -> 点上面的 create credentials -> OAuth Client ID
    type 选择 web application name不管 然后 ADD Authorized redirect URIS
    'http://localhost:3000/api/auth/callback/google'
    7. 复制生成好的 id 和 secret 即可

## Modal 组件设计实现

### 组件 dom 结构设计
```tsx
<mask>
  <container>
    <content />
  </container>
</mask>
```

### store 设计

hooks/useInfoModal.ts

```ts
const useInfoModal = create<ModalStoreInterface>(set => ({
  movieId: undefined,
  isOpen: false,
  openModal: movieId => set({ isOpen: true, movieId }),
  closeModal: () => set({ isOpen: false, movieId: undefined }),
}))
```

### visible state

使用 isOpen（store） 和 isVisible（state） 来搭配控制弹窗显隐

- 为什么需要两个 state ？

组件内部维护 isVisible state，初始值为 props 接收到的 isOpen，内部使用 useEffect 同步 props 与 state
```tsx
const [isVisible, setIsVisible] = useState(!!isOpen)
// ...
useEffect(() => {
  setIsVisible(!!isOpen)
}, [isOpen])
```

这里表面上看有两个 state 来完成 Modal 的显隐控制
实际上 isVisible 仅用于控制 Modal Content 元素的 scale 过渡动效
```tsx
// Modal Body Content
<div
  className={`
    ${isVisible ? 'scale-100' : 'scale-0'}
    transform
    duration-300
    ...
  `}
></div>
```
而 isOpen 则负责整体组件的条件渲染
```tsx
if (!visible)
  return null
return <modal/>
```
两个变量搭配，能够使弹窗显隐不受 props 限制，且可以提供更多的灵活性，使组件能够更好地适应各种场景和需求。

### setTimeout

- 为什么在弹窗关闭的回调中执行两次关闭的操作？
```tsx
const handleClose = useCallback(() => {
  setIsVisible(false)
  setTimeout(() => {
    onClose()
  }, 300)
}, [onClose])
```
setIsVisible 实际控制的是 Modal Content 的 scale 过渡动画的状态
而 onClose 实际控制的是 Modal 组件的返回值(组件/null)，一旦 onClose 执行了，那么组件会即刻消失
因此使用 setTimeout 延时执行 onClose，延时时长与 Modal Content 元素的 transition duration 相同(300ms)，这样可以实现更加平滑的弹窗关闭效果，提供更好的用户体验。

## 部署

### 远程服务器部署

**TODO**

### Vercel 部署

1. vercel 添加 github 仓库，一键导入
2. 设置环境变量
3. 重写 build 命令：npx prisma generate && next build
4. 记得去 github 和 google 的 Oauth 设置中修改或添加 callbackUrl 为生产环境的 url
5. done

## 其他

github clean history
axios delete/post
宝藏图标库 react-icons