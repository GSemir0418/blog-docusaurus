---
title: jwt
date: 2024-02-26T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [sso, jwt]
---

>JSON Web Token，既是一种**数据标准**，也是一种**登录认证方案**。
>
>[HEADER].[PAYLOAD].[SIGNATURE]
>
>Header 是一个 JSON 对象，描述 JWT 的元数据，例如加密算法或类型等
>
>Payload 是一个 JSON 对象，实际需要传递的数据
>
>Signature 是签名，使用密钥对前两部分使用加密算法进行加密后的字符串

## 定义

JWT 全称 **JSON Web Token**，定义了一种在网络上安全传输以 JSON 格式包含的声明信息（数据）的标准，也指代了一种登录认证方案

## 由来

传统的 cookie-session 登录模式流程如下

```
1、客户端向服务器发送用户名和密码

2、服务器验证通过后，在当前对话（session）里面保存相关数据，比如用户角色、登录时间等等

3、服务器向客户端返回一个 session_id，写入客户端的 Cookie

4、客户端随后的每一次请求，都会通过 Cookie，将 session_id 传回服务器

5、服务器收到 session_id，找到前期保存的数据，由此得知用户的身份
```

这种模式具有一些明显的弊端

1. 扩展性不高：在分布式系统中，如果用户的请求被路由到不同的服务器，需要共享 Session，处理这个问题会相对麻烦。这是因为，会话信息通常保存在服务器的内存中，当服务需要扩展时，也需要同步这些会话信息。
2. 存储压力：如果网站有大量的并发访问，每个用户登录都需要服务器存储用户的会话信息，这无疑会增加服务器的存储压力。
3. 无法携带数据：客户端的 Cookie 只是一个会话 ID，要获取用户的登录信息，还需要在服务器端进行查询。
4. CSRF攻击：与跨站点脚本 （XSS） 不同，跨站点脚本 （XSS） 利用用户对特定站点的信任，而 CSRF 利用站点在用户浏览器中的信任。不过现在可以通过 `sameSite|secure|httpOnly` 等属性解决一定的 cookie 安全性问题
5. 存在被篡改和伪造的隐患：如果某个人能够拦截这个会话ID，那么他就可以通过伪造这个会话ID来假冒用户身份，这就是所谓的“会话劫持”。此外，如果服务器端的会话存储不当，比如存储在可被外部访问或者能够被SQL注入的数据库，那么这些会话数据就有可能被篡改。

为了**提高安全性**，**减轻服务端压力**，**实现单点登录**等，JWT 应运而生

## 组成

JWT 由三部分组成，中间由 `.` 连接

```
[HEADER].[PAYLOAD].[SIGNATURE]
```

### Header

Header 是一个 JSON 对象，描述 JWT 的元数据

```json
{
  "alg": "HS256", // 加密算法
  "typ": "JWT" // token 类型
}
```

将上面的 JSON 对象使用 Base64URL 算法转成字符串 btoa 解码 atob

注意这里是 Base64URL 而不是 Base64

> Base64编码使用的字符包括A-Z，a-z，0-9，+和/，并且在需要的时候使用=作为填充。然而，这些字符在URL中有特殊的含义，可能会被认为是分隔符，也可能在传输过程中被改变。
>
> Base64URL编码是为了解决这个问题而产生的。它将Base64编码中的+和/分别替换为-和_。这样，就可以在URL和文件名中安全地使用Base64URL编码的字符串，不需要进行额外的URL转义处理。

### Payload

Payload 也是一个 JSON 对象，用来存放实际需要传递的数据

```json
{
  "sub": "1234567890",
  "name": "John Doe",
  "admin": true,
  "iss": "签发人",
	"exp": "过期时间",
  "nbf": "生效时间",
  "iat": "签发时间",
  "jti": "编号"
}
```

注意，JWT 默认是不加密的，任何人都可以读到，所以不要把秘密信息放在这个部分。

这个 JSON 对象也要使用 Base64URL 算法转成字符串

### Signature

Signature 部分是对前两部分的签名，防止数据篡改。

首先，需要指定一个密钥（secret）。这个密钥只有服务器才知道，不能泄露给用户。然后，使用 Header 里面指定的签名算法（默认是 HMAC SHA256），产生前两部分的签名，再经过 Base64URL 编码后作为 JWT 的第三部分

```
HMACSHA256(
  base64UrlEncode(header) + "." + base64UrlEncode(payload),
  secret
)
```

## 流程

登录成功后，服务端使用密钥生成 jwt 返回给客户端，客户端保存在本地。再次发起请求时，服务端将 jwt 放到 Authorization 请求头中，服务端拿到 jwt 字符串，使用密钥解密，验证用户是否有效，解密成功且用户有效，则校验通过。

## 优缺点

- 优点：解决了上述传统登录模式的问题，提升了数据传输的安全性、减轻服务端压力（自包含用户信息，无状态，无需保持会话状态）
- 缺点：由于服务器不保存 session 状态，因此无法在使用过程中废止某个 token，或者更改 token 的权限。也就是说，一旦 JWT 签发了，在到期之前就会始终有效，除非服务器部署额外的逻辑（黑名单）。









