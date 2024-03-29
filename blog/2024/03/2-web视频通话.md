---
title: Web 视频通话
date: 2024-03-02T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [express, socket, peer, webRTC, video call]
---

# web 视频通话

> https://github.com/GSemir0418/video-call-demo-express

基于 SocketIO 和 PeerJS，使用 Express 完成 Web 视频通话的 demo，

二者结合既能高效传输数据，又能正确处理实时的信令事件

其中 socket.io 主要负责在服务器和客户端之间实现实时双向通信，用于在服务器和客户端之间传递与通话相关的信令数据，比如「哪一个用户加入了通话」或者「一个用户离开了通话」

## PeerJS

> https://peerjs.com/

PeerJS 是一个封装了 WebRTC API 的 JavaScript 库，主要负责通过浏览器直接在客户端之间进行实时通信，可以让两个浏览器直接进行实时数据的传输，无需经过服务器。

>WebRTC（Web Real-Time Communication）是一项开源项目，让网页应用和网站能在不需要中间媒介的情况下直接进行浏览器间音视频通话和数据分享，大大降低了实时通信应用的复杂性，使得开发者无需为实现复杂的实时通信架构而头疼，也让用户无需安装任何额外插件就能使用浏览器进行音视频聊天和文件分享。

PeerJS 的作用主要体现在以下几点：

1. 直接传输视频和音频流：由于 PeerJS 封装了 WebRTC，你可以使用它将视频和音频流直接从一个浏览器传输到另一个浏览器，而无需经过服务器。这不仅能提高数据传输速度，还可以显著降低服务器带宽消耗。
2. 高效的数据传输：PeerJS 允许你使用其数据通道API进行二进制数据的直接传输，同时，数据通道API也支持流控和拥塞控制。
3. 点对点的通信模式：通过 PeerJS 和 WebRTC 实现的点对点（Peer-to-Peer）通信模式，可以有效避免服务端负载过大的问题，并且提高了整体的数据传输性能。

### 使用

- 基本使用

```bash
npm i -g peer
peerjs --port 9000 --key peerjs --path /myapp
```

```js
// 初始化 peer 实例，连接 peer 服务
const peer = new Peer(undefined, {
  host: '你的服务器地址',
  port: '你的服务器端口',
  path: '/myapp',
  key: 'peerjs',
})
// 第一个参数表示该用户 id，传入 undefined 表示自动生成用户 id
```

- 可以将一个 peer 对象类比于一个用户
- open 事件

`open` 事件在 Peer 对象与其对应的 Peer 服务器成功建立连接时触发。在这个事件触发之后，我们就可以获得一个在 Peer 服务器上唯一的ID，它可以被用来建立 Peer 到 Peer 的连接

事件参数 `id` 是由 Peer 服务器为此 Peer 对象分配的唯一 ID。在此事件触发后，我们就可以使用这个 ID 与其他 Peer 对象建立连接

- call 事件

`call` 事件在 `Peer.call()` 调用时触发，其事件参数 call 对象，表示一次 Peer 到 Peer 的连接

当与另一个 Peer 对象建立连接并共享音视频流，可以调用 `peer.call(otherPeerId, yourStream)`。其中 `otherPeerId` 是你想要连接的其他 Peer 的 ID，`yourStream` 是你想要共享的音视频流

当调用了 `peer.call()` 后，我们可以得到一个代表这次连接的 Call 对象。在这个 Call 对象上，我们可以听取各种事件，如 `stream`，`close` 等，分别在接收到其他 Peer 的流以及连接关闭时触发

- 可以将 call 连接类比于 socket 连接，可以使用 on 监听事件，也可以触发事件

## 代码

服务端开启 peerjs 服务

服务端开启 socket 服务，处理 `join-room`，`user-connected`，`disconnected` 以及 `user-disconnected` 事件

```js
io.on('connection', socket => {
  // 注册并监听客户端触发的 join-room 事件
  socket.on('join-room', (roomId, userId) => {
    // 让 socket 客户端加入这个 roomId 房间
    socket.join(roomId)
    // 让 socket 客户端向指定房间内（除自己之外）的其他客户端广播 user-connected 事件
    socket.to(roomId).emit('user-connected', userId)

    // 注册断开连接事件
    socket.on('disconnect', () => {
      // 向指定房间内其他成员广播 该用户断开连接
      socket.to(roomId).emit('user-disconnected', userId)
    })
  })
})
```

客户端源码

```js
// 初始化 socket 连接
const socket = io('/')
const videoGrid = document.getElementById('video-grid')
// 缓存所有连接到同一房间的其他用户
const peers = {}
// 连接 peerjs 服务器
const myPeer = new Peer(undefined, {
  host: '/',
  port: '3001'
})

// 视频元素：来自当前用户设备的视频流
const myVideo = document.createElement('video')
myVideo.style.border = '3px solid red'
myVideo.muted = true

// 当 peer 连接打开时，通过socket向服务器发送一个'join-room'事件
myPeer.on('open', id => {
  socket.emit('join-room', ROOM_ID, id)
})

// 获取当前用户视频流
navigator.mediaDevices.getUserMedia({
  video: true,
  audio: true
}).then(currentStream => {
  // 添加当前用户的视频流数据及 video 元素
  addVideoStream(myVideo, currentStream)
  
  // 监听其他用户的连接事件
  socket.on('user-connected', (userId) => {
    // 发起 peer 连接
    connectToNewUser(userId, currentStream)
  })

  // 监听'call'事件，
  myPeer.on('call', call => {
    // 当收到其他用户的音视频流时，将当前用户的视频流返回给其他用户
    call.answer(currentStream)
    const video = document.createElement('video')
    call.on('stream', otherVideoStream => {
      addVideoStream(video, otherVideoStream)
    })
  })
})

// socket 断开连接事件
socket.on('user-disconnected', userId => {
  if(peers[userId])
    peers[userId].close()
})


// 添加（其他用户）视频元素
function addVideoStream(video, stream) {
  video.srcObject = stream
  video.addEventListener('loadedmetadata', () => {
    video.play()
  })
  videoGrid.append(video)
}

// 连接到（其他）用户
function connectToNewUser(userId, stream) {
  // 向该用户建立连接
  const call = myPeer.call(userId, stream)
  const video = document.createElement('video')
  call.on('stream', userVideoStream => {
    addVideoStream(video, userVideoStream)
  }) 
  // close 事件触发后，移除 video 元素
  call.on('close', () => {
    video.remove()
  })
  // 缓存新用户连接
  peers[userId] = call
}
```

