---
sidebar-position: 2
title: HTTP
date: 2024-03-18
authors: gsemir
tags: [http, https, dns, tcp, websocket, cdn, cache]
---

#### TCP\UDP区别

> **`TCP/IP` 模型**是互联网的基础，它是**一系列网络协议的总称**(TCP，UDP，IP，FTP，HTTP，SMTP等)。这些协议可以划分为**四层**，分别为**链路层、网络层、传输层和应用层**。

 `TCP` 和 `UDP` 都属于 `TCP/IP` 模型中的**传输层**协议

##### UDP（用户数据报协议）

1. **面向无连接**：不需要像TCP那样在发送数据前进行三次握手建立连接的，同时不会对报文进行处理
2. UDP 不止支持点对点的传输方式，同样支持一对多，多对多，多对一的方式，也就是说 UDP 提供了单播，多播，广播的功能。
3. **不可靠性**：在网络条件不好的情况下可能会导致丢包
4. **头部开销小**，传输数据报文时是很**高效**的。
5. 适用于**实时应用**（IP电话，视频会议，直播等）

##### TCP（传输控制协议）

1. **面向连接**：发送数据之前必须在两端建立连接
2. **仅支持单播传输**：只能进行**点对点**的数据传输
3. **可靠传输**：每个包都有序号，保证传输顺序，且接收方会返回确认（ACK），没收到的话会重传
4. 适用于要求可靠传输的应用，例如**文件传输**

-----

#### DNS、TCP与HTTP

##### DNS（Domain Name System）：域名系统

当我们在地址栏属于域名并访问时，会先在**浏览器缓存**中找对应域名的ip，如果没有，则去**操作系统**的缓存中查找，其实就是操作系统的`hosts`文件，hosts文件相当于手动给操作系统添加ip缓存；如果都找不到，则去请求**ISP**（互联网服务提供商），得到对应域名的ip地址。

##### TCP（传输控制协议）

- 建立TCP连接过程的三次握手，`SYN`表示同步信息，`ACK`表示获悉，x、y一般从0开始

1. A->B，`SYN(x)`
2. B->A，`ACK(x+1)SYN(y)`——确保A能向B发送信息，B能收到A的信息
3. A->B，`ACK(y+1)`——确保A能收（为什么一定需要第三次）
4. A正式开始发送HTTP请求

- 关闭TCP连接过程的四次挥手，`FIN`表示finish，x、y一般不为0

1. A->B，`FIN(x)`——A请求结束通讯
2. B->A，`ACK(x+1)`——确保B知道A要请求结束了
3. B->A，`FIN(y)`——B结束响应，并关闭TCP连接
4. A->B，`ACK(y+1)`——确保A知道B要结束响应了
   - 为什么2、3两步骤B不能一起发送？因为第二次和第三次中间，服务端**可能夹杂其他响应数据**（B可能还没说完）
   - 不一定是客户端发起FIN，服务端也可以发起FIN

##### HTTP（超文本传输协议）

-----

#### HTTP/1.1、HTTP/2 和 HTTPS

首先 HTTP/1.1 和 HTTP/2 是属于 HTTP 协议的两个版本

HTTPS 是 HTTP 协议通过 SSL 或 TLS 协议加密后的版本

HTTP/1.1是早期互联网的通信标准，HTTP/2是基于HTTP/1.1的改进版，提供了**更高效**的通信

HTTPS 是 HTTP 通信的**安全形式**，它可以使用 HTTP/1.1 或 HTTP/2 协议进行安全传输

-----

#### HTTP/2 vs HTTP/1.1

- HTTP/2使用**二进制格式传输**数据，而且将 `head` 和 `body` 分成**帧**来传输，更高效；HTTP/1.1是**字符串传输**
- HTTP/2 支持**多路复用**，即一个 TCP 连接从单车道变成了几百个双向通行的车道
- HTTP/2 可以压缩头部信息，**减少**数据大小
- HTTP/2 可以设置请求的优先级，有效管理资源的加载顺序。

-----

#### HTTP/2 多路复用

#####  HTTP/2 的帧

 HTTP/1.1 的请求响应过程是基于字符串的，而HTTP/2的请求响应过程是基于**帧**的。

 HTTP/2 引入了**帧（Frame）**的概念，可以将一次请求响应过程拆分成若干帧，每一帧包含`Length Type Flags StreamID Payload`五部分。前四个部分是固定的**9字节**长度，采用**二进制**的形式，起到**标识**的作用；第五部分 `Payload` 的最大长度为16kb到16Mb，具体的最大长度由终端自行决定，其中包括请求响应**头**和请求响应头**体**的内容。

##### HTTP/2 的请求与响应

HTTP/2 保留了请求和响应的概念，请求头和响应头会被发送方压缩后，分成几个**连续的Frame**传输，头字段会出现在这些Frame的`Payload`中，接收方拼合这些Frame后，解压缩即可得到真正的请求头或响应头。

- 请求示例
  - 前三行数据为二进制翻译后的帧标识部分，`+`表示true，`-`表示false
  - 头部字段名全部改为小写，不允许出现大写，例如`accept = text/html`
  - 引入了伪头部字段的概念，出现在头部字段的前面，必须以冒号开头，例如`:method = GET`

| HTTP/1.1                                                     | HTTP/2                                                       |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| GET /resource HTTP/1.1<br/>Host: example.org<br/>Accept: image/jpeg | HEADERS<br/>+ END_STREAM<br/>+ END_HEADERS :method = GET<br/>:scheme = https<br/>:path = /resource<br/>host = example.org<br/>accept = image/jpeg |
| POST /resource HTTP/1.1<br/>Host: example.org<br/>Content-Type: image/jpeg<br/>Content-Length: 123 <br/><br/>{消息体} | HEADERS<br/>- END_STREAM<br/>- END_HEADERS<br/>:method = POST<br/>:path = /resource<br/>:scheme = https<br/><br/>CONTINUATION<br/>+ END_HEADERS<br/>content-type = image/jpeg<br/>host = example.org<br/>content-length = 123<br/><br/>DATA<br/>+ END_STREAM<br/>{消息体} |
| HTTP/1.1 200 OK<br/>Content-Type: image/jpeg<br/>Content-Length: 123<br/><br/>{响应体} | HEADERS<br/>- END_STREAM<br/>+ END_HEADERS<br/>:status = 200<br/>content-type = image/jpeg<br/>content-length = 123<br/><br/>DATA<br/>+ END_STREAM<br/>{响应体} |

##### HTTP/2 的流与多路复用

- HTTP/2 引入了**流（Stream）**的概念，一个 Stream 由双向传输的连续且有序的 Frame(s) 组成
- 一个TCP连接可以**同时包含**多个 Stream（比如100个），**一个 Stream 只用于一次**请求和一次响应，
- Stream之间**相互独立**，通过 StreamID 区别请求。
- Stream支持**复用**，即多路复用。

-----

#### HTTP 缓存有哪些方案

HTTP 缓存主要分为两种：**强缓存**和**协商缓存**

##### 强缓存（服务端响应头）

客户端可以从本地缓存中加载资源，而无需发送请求到服务器。强缓存通过以下响应头实现

- `Cache-Control`: 这是最常用的控制缓存行为的方式。例如，`Cache-Control: max-age=3600`表示资源可以在本地缓存并在3600秒后才需要重新验证
- `Expires`: 这是一个旧的 HTTP/1.0 特性，它设置一个资源过期的绝对时间，例如 `Sun, 18 Oct 2020 08:56:53 GMT`。如果`Cache-Control`和`Expires`同时存在，`Cache-Control`的设置将优先。
- 考虑到兼容性，通常会一起使用

##### 协商缓存（服务端响应头 + 客户端请求头）

当一个资源的**强缓存失效**后，浏览器会发送一个请求到服务器，**来检查资源是否需要更新**。协商缓存通常通过以下响应头实现

- `Last-Modified`（响应）和`If-Modified-Since`（请求）: `Last-Modified` 表示资源最后一次修改的时间。客户端后续请求可能包含`If-Modified-Since`头部，它的值是先前`Last-Modified`的值。服务器通过比较两者来决定是否发送全新的资源。
- `ETag`（响应）和 `If-None-Match`（请求）: `ETag`相当于资源的特定版本的标识（可能是一个内容哈希等）。如果资源有变动，ETag也会变。客户端可能在后续请求中发送`If-None-Match`头，其中包含先前响应中的`ETag`值。服务器用这个值与当前版本对比，如果不匹配就发送新资源。

##### 缓存逻辑

这两种缓存机制结合使用，可以显著减少不必要的网络传输，提高网页加载性能

1. 首先向服务器请求数据

```http
GET /example.jpg HTTP/1.1
Host: www.example.com
```

2. 服务端响应中包含强缓存（`Cache-Control/Expires`）与协商缓存（`Last-Modified/ETag`）所需的字段

```http
HTTP/1.1 200 OK
Date: Mon, 25 Mar 2024 12:00:00 GMT
Last-Modified: Wed, 21 Oct 2020 07:28:00 GMT
ETag: "a1234"
Cache-Control: max-age=3600
Expires: Mon, 25 Mar 2024 13:00:00 GMT
Content-Length: 12345
Content-Type: image/jpeg

[example.jpg文件的数据]
```

3. 当强缓存失效后，浏览器会向服务器发送协商缓存请求，包括 `If-Modified-Since`（上次响应头的 Last-Modified） 和 `If-None-Match`（上次响应头的 ETag） 请求头

```http
GET /example.jpg HTTP/1.1
Host: www.example.com
If-Modified-Since: Wed, 21 Oct 2020 07:28:00 GMT
If-None-Match: "a1234"
```

4. 如果服务器验证了资源没有过期，会返回 304 编码

```http
HTTP/1.1 304 Not Modified
Date: Mon, 25 Mar 2024 12:00:00 GMT
Cache-Control: max-age=3600
Expires: Mon, 25 Mar 2024 13:00:00 GMT
ETag: "a1234"
```

-----

#### HTTP和HTTPS的区别

`HTTPS = HTTP + SSL/TLS(安全层)`

- HTTP是**明文传输**的，不安全（Chrome直接会显示不安全）；HTTPS是**加密传输**的，非常安全
- HTTP默认使用**80**端口；HTTPS默认使用**443**端口
- HTTP较**快**，HTTPS较**慢**（因为要加密）
- HTTPS的证书一般需要**购买**，HTTP**不需要**证书
- 浏览器对于 http 有限制：禁止网站访问视频和音频

-----

#### WebSocket

WebSocket 是一种**网络通信协议**，提供了在单个长连接上进行全双工通信的能力。它允许服务端和客户端之间建立一个**持久**的连接，并且双方可以在任何时间点开始发送数据。

与 HTTP 不同的是，WebSocket 提供了一种在客户端和服务器之间进行**实时**、**双向交流**的方式。一旦 WebSocket 连接被建立，客户端和服务器之间就可以**自由**地发送和接收数据，而不需要每次都重新发送请求头和其他信息，这样可以减少不必要的网络开销和延迟。

WebSocket 的工作流程通常如下：

1. 客户端发送一个特殊的 **HTTP** 请求，称为「WebSocket 握手请求」到服务器。
2. 服务器理解这个请求并返回一个应答，完成握手过程。
3. 一旦握手成功，客户端与服务器之间的连接就**升级**为 WebSocket 连接。接下来，客户端和服务器可以通过这个通道发送消息，直到其中一方关闭连接。

WebSocket 协议在 URI 方案中以`ws`（非加密）和`wss`（加密）出现。例如：

- `ws://www.example.com/socket` 表示未加密的WebSocket连接
- `wss://www.example.com/socket` 表示加密的WebSocket连接

在 web 开发中，WebSocket 非常适合需要快速和常规更新的应用程序，例如**在线游戏**、**实时通讯**（聊天室）、实时通知系统、**协同编辑**工具等。WebSocket 使得这些类型的应用程序能够提供更顺滑和接近实时的用户体验。

-----

#### GET和POST的区别有哪些

1. 语义上，GET是**读**，POST是**写**，造成两者幂等性（多次执行操作，产生的结果相同）的不同

   - 所以GET是幂等的，POST不是幂等的

   - 所以用浏览器**打开网页**会发送GET请求（若想用POST打开网页要用form标签）

   - 所以GET打开的页面**刷新**是无害的，POST打开的页面刷新需要确认

   - 所以GET结果会被**缓存**，POST结果不会被缓存

   - 所以GET打开的页面可被**书签**收藏，POST打开的不行

2. 请求参数不同

   1. GET请求参数放在url中，POST请求数据放在body（消息体）中
      - 其实是可以互换的，即GET可以携带body，不过浏览器或服务器一般不会接受
   2. GET比POST更**不安全**，因为参数直接以明文形式暴露在url中，所以不能用来传递敏感信息
      - 但是POST请求体实际上也是明文的
   3. GET请求参数放在url中是**有长度限制**的，而POST放在body里没有长度限制
      - 都是可配置的，比如nginx就可以限制POST请求体的最大长度（code:414）

3. TCP packet

   - GET产生**一个**TCP数据包，POST产生**两个或以上**TCP数据包
     - 因为一般浏览器或服务器不会接受GET的请求体，默认GET没有请求体

-----

#### Cookie、Session、LS、SS的区别

Cookies、SessionStorage和LocalStorage三者都是在浏览器中存储数据的方法，但它们在存储方式、存储大小、存储时效和安全性方面有所不同。

|          | Cookies                                                      | SS                                                       | LS                                                         |
| -------- | ------------------------------------------------------------ | -------------------------------------------------------- | ---------------------------------------------------------- |
| 用途     | 用于服务器与客户端之间的**状态管理**                         | 用于在**单个**浏览器标签页的会话中存储数据               | 用于在浏览器中**长期**存储数据，直到显式删除               |
| 存储大小 | 较小，一般为4KB左右                                          | 通常比cookies大，5MB或更多                               | 比cookies大，5MB或更多                                     |
| 存储时效 | 可以设置**过期时间**，没有设置过期时间的会在浏览器关闭时消失 | 数据仅在**当前会话**中有效，关闭页面或标签后数据会被清除 | **没有**过期时间，数据在关闭和重新开启浏览器后依然可以使用 |
| 安全性   | 每次http请求**都会携带**cookies向服务器发送                  | **不**随http请求发送，只在客户端使用                     | **不**随http请求发送，只在客户端使用；**且同源标签共享**   |

------


#### 常见状态码

**成功响应**

- 201 创建成功 POST 或 PUT

- 202 请求已接收，但未响应，需要额外请求结果

- 204 无响应体

- 206 部分内容

用于指示服务器成功处理了部分请求，允许客户端在需要时分段下载大文件，从而提高了效率和灵活性。这种机制在视频流、音频流和大文件下载中非常常见

当客户端发送一个包含`Range`头的请求时，服务器会根据这个请求返回相应的数据。

```
HTTP/1.1 206 Partial Content
Content-Type: video/mp4
Content-Length: 25000
Content-Range: bytes 25000-75000/100000
```

**重定向**

- 301 永久重定向

- 304 未修改

**客户端错误**

- 401 未鉴权
- 403 无权限
- 405 不支持的请求方法
- 422 请求体格式或语义
- 429 请求过于频繁

**服务端错误**

- 500 内部错误



