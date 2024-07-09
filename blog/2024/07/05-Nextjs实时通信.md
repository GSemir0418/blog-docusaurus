---
title: Nextjs实时通信方案
date: 2024-07-05T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [react, websocket, react-query, hooks]
---

# Socket 服务集成

使用 socket.io 在 nextjs 中集成 WebSocket 服务，实现实时通信

> Socket.IO 是一个库，可以在客户端和服务器之间实现 **低延迟**, **双向** 和 **基于事件的** 通信。
>
> 服务端使用 emit 触发 socket 事件，客户端使用 on 监听 socket 事件

## 准备

- 背景

App 模式下的 routes.ts 文件中只支持定义请求方法的同名方法，并以具名方式导出，这样才可以成功映射为 GET /api/xxx 的后端路由。

但 socket io 服务是需要重写整个 req/res handler 的， 所以我们只能使用老版本（pages 模式）的写法来定义 socket 路由

> 还有一种方案是创建 server 文件，重写 nextjs 底层 http 服务逻辑，作为整个服务的入口。在这里注册 socket io 的连接事件
> https://socket.io/how-to/use-with-nextjs

- 类型定义

扩展 NextApiResponse，支持 SocketIoServer 类型

```ts
export type NextApiResponseServerIo = NextApiResponse & {
  socket: Socket & {
    server: NetServer & {
      io: SocketIoServer
    }
  }
}
```

- 初始化 socket 实例

定义 `pages/api/socket/io.ts`，用于初始化 socket 服务实例，并注入 res 对象中。

当客户端初始化 socket 连接时，会访问这个路由，此时就会将服务端的 socket 实例注入到 next 响应对象中

该文件默认导出了 ioHandler 方法，在方法中实例化 socket server 实例，并把 res.socket.server.io 指向了这个实例。

该接口不作任何返回行为，仅作为初始化服务端 socket 实例方法。

```ts
// pages/api/socket/io.ts
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
      addTrailingSlash: false,
    })
    res.socket.server.io = io
  }
  res.end()
}

export default ioHandler
```

## 服务端

继续在 pages 模式下定义消息路由 `api/socket/messages`，以频道消息通信为例

- 接口逻辑

数据库中创建 message 数据，同时 emit 触发 socket 事件，最后接口正常返回 message 即可

```ts
// pages/api/socket/messages/index.ts
export default async function handler(
  req: NextApiRequest,
  res: NextApiResponseServerIo,
) {
  // ...
  const message = await db.message.create({
    data: {
      content,
      fileUrl,
      channelId: channelId as string,
      memberId: member.id,
    },
    include: {
      member: {
        include: {
          profile: true,
        },
      },
    },
  })

  const channelKey = `chat:${channelId}:messages`

  res?.socket?.server?.io?.emit(channelKey, message)

  return res.status(200).json(message)
}
```

服务端还需要在 `app/api/messages` 提供 GET 方法，用于 http 分页查询 messages 数据

关于查询逻辑详见下文

## 客户端

- socket Provider

客户端通过 Provider 组件向全局提供 socket 客户端实例与连接状态

```tsx
// app/layout.tsx
export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className="bg-white dark:bg-[#313338]">
        <SocketProvider>
          {children}
        </SocketProvider>
      </body>
    </html>
  )
}
```

SocketProvider 定义如下，页面挂载后访问 /api/socket/io 初始化服务端 socket 实例，并生成客户端实例，同时注册 connect 与 disconnect 事件，用于更新连接状态

```tsx
// components/providers/socket-provider.tsx
'use client'

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

- useChatSocket hook

具体的信息发送逻辑封装到 `useChatSocket` 中，接收 addKey

> addKey 就是使用 channelId 或者 conversationId 拼接出来的唯一字符串，作为 socket 事件的标识

接着拿到全局的 socket 客户端实例，在 useEffect 中注册事件，监听服务端的相同的 key 的事件，使用传递过来的新 message 数据更新页面数据即可

```ts
// hooks/use-chat-socket.ts
interface Props {
  addKey: string
}

export function useChatSocket({
  addKey,
}: Props) {
  const { socket } = useSocket()

  useEffect(() => {
    if (!socket)
      return

    socket.on(addKey, (message: MessageWithMemberWithProfile) => {
      // 根据 queryKey（此处省略） 同步修改 react-query 查询到的数据即可
    })

    return () => {
      socket.off(addKey)
    }
  }, [addKey, socket])
}

// 使用
useChatSocket({ addKey })
```

# cursor 分页查询方案

> 服务端使用某条数据的 id 作为 cursor 标记进行分页查询，返回查询数据及下一次的 cursor；客户端使用 react-query 提供的 useInfiniteQuery hook 进行分页轮询数据

## 服务端

服务端采用 cursor 的分页方案，cursor 即某条数据的 id，作为查询的参数以及查询数据的起点。

逻辑：从 searchParams 中拿到 cursor 和 channelId，默认每次查 10 条数据，如果有 cursor 标记，则从 cursor 标记的 id 开始查（skip 掉自己）；然后通过 messages.length 判断并计算 nextCursor，将 messages 和 nextCursor 做为响应体返回即可

```ts
// app/api/messages/route.ts
// 默认每次查 10 条数据
const MESSAGES_BATCH = 10

export async function GET(req: Request) {
  try {
    // 拿到 cursor 和 channelId 参数
    const { searchParams } = new URL(req.url)

    const cursor = searchParams.get('cursor')
    const channelId = searchParams.get('channelId')

    let messges: Message[] = []
    
    // 如果存在 cursor，则从 cursor 标记的 id 开始查询（skip 掉自己）
    if (cursor) {
      messges = await db.message.findMany({
        take: MESSAGES_BATCH,
        skip: 1,
        cursor: {
          id: cursor,
        },
        where: {
          channelId,
        },
        include: {
          member: {
            include: {
              profile: true,
            },
          },
        },
        // 按创建时间倒序排列
        orderBy: {
          createdAt: 'desc',
        },
      })
    }
    else {
      messges = await db.message.findMany({
        take: MESSAGES_BATCH,
        where: {
          channelId,
        },
        include: {
          member: {
            include: {
              profile: true,
            },
          },
        },
        orderBy: {
          createdAt: 'desc',
        },
      })
    }

    // 然后通过 messages.length 判断并计算 nextCursor，
    // 如果查询到的数据条数为 10，则说明还可能有下页数据，更新 nextCursor 为 最后一条的 id 即可
    // 反之说明没有下页数据了，将 nextCursor 置为 null 返回即可
    let nextCursor = null
    if (messges.length === MESSAGES_BATCH)
      nextCursor = messges[MESSAGES_BATCH - 1].id
    
    // 将 messages 和 nextCursor 做为响应体返回即可
    return NextResponse.json({
      items: messges,
      nextCursor,
    })
  }
}

```
## 客户端

使用 react-query 提供的 `useInfiniteQuery hook` 实现消息的查询功能

之所以使用 useInfiniteQuery 是想利用其轮询的特性，作为 socket 服务失效的**备用方案**

useInfiniteQuery 自带分页查询功能，其入参的 `getNextPageParam` 方法，将本次响应体数据作为参数，返回下次调用 `queryFn` 方法的入参，起到承上启下的作用，为本方案的核心方法

该 hook 返回了 data（响应数据）、fetchNextPage（发起下次请求的方法）、hasNextPage（下一页是否存在）、isFetchingNextPage（是否正在请求下页数据）、status（请求状态）：

- 其中，queryFn 就是查询数据的方法，内部可以使用 fetch 也可以使用 axios，接收从 getNextPageParam 返回的参数（cursor id）进行查询

- 在上面的服务端逻辑中，处理并返回了 nextCursor id，所以在 getNextPageParam 中，将响应体的 nextCursor 数据设置为下次 queryFn 的参数，把这个参数作为 url params 调用接口，形成闭环

- 其中，hasNextPage 同样也是取决于 getNextPageParam 方法是否返回了有效的 nextCursor

封装 useChatQuery hook:

```ts
interface Props {
  queryKey: string // 用于标记此次查询的 key，用于 socket 同步更改数据
  apiUrl: string
  paramKey: 'channelId' | 'conversationId'
  paramValue: string
}

export function useChatQuery({
  queryKey,
  apiUrl,
  paramKey,
  paramValue,
}: Props) {
  const { isConnected } = useSocket()

  const fetchMessages = async ({ pageParam = undefined }) => {
    const url = qs.stringifyUrl({
      url: apiUrl,
      query: {
        cursor: pageParam,
        // 动态 key，方便查询私信或者频道消息
        [paramKey]: paramValue,
      },
    }, { skipNull: true })

    const res = await fetch(url)
    return res.json()
  }

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
    // 根据 socket 连接状态判断是否轮询
    refetchInterval: isConnected ? false : 1000,
  })

  // 返回数据、
  return {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    status,
  }
}

```

使用 `queryClient.setQueryData` 根据 queryKey 同步修改消息数据

```ts
const queryClient = useQueryClient()

queryClient.setQueryData([queryKey], (oldData: any) => {
  if (!oldData || !oldData.pages || oldData.pages.length === 0) {
    return {
      pages: [{
        items: [message],
      }],
    }
  }
  const newData = [...oldData.pages]

  newData[0] = { ...newData[0], items: [message, ...newData[0].items] }

  return { ...oldData, pages: newData }
})
```
