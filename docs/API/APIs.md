---
sidebar-position: 1
title: API 技术核心原理
date: 2023-07-24
authors: gsemir
tags: [RESTful, GraphQL, RPC]
---

## API 是啥

API（Application Programming Interface）就是接口，通过这个接口可以帮我们实现某种功能，比如

## REST 架构风格

不是协议，也不是语言，而是一种惯例或者风格

### 两个核心

REST 是x个单词的简写

REpresentational：资源有某种表现形式，让资源用某种代表来展现

State Transfer：状态传输，要求客户端的状态不保存在服务端处，每一次请求都需要正确表示自己的状态，并且传输给服务端

### 六个约束

- 客户端服务端，二者相互独立

- 统一接口，GET /user/1

- 无状态，服务端不保存状态

- 缓存，GET默认缓存

- 分层系统，

- 按需代码，服务端可以响应可执行代码给客户端

## REST缺点

过于依赖API文档

获取不足、过度获取

就像理发店只提供洗剪吹 想单独洗不行 想洗 + 按摩也不行

## GraphQL

几乎不需要API文档

按照 GraphQL的语法来写即可获取整合的资源

读 Query

写 Mutation

事件观察 Subscription

注明操作类型（query），操作名（），变量（），大括号中就是服务端要响应的内容（name）

```js
query GetAllEggs ($eggId: iD!) {
    egg(id: $eggId){
        name
    }
}
```

## 对比

简单首选 REST

不过越到后期就越复杂。如果拥有复杂关系的数据，有强类型的需求，或者要面对很多移动端用户，对客户端的性能有较高的要求，就要选择 GraphQL 了

## RPC

协议？技术机制

### 三个核心