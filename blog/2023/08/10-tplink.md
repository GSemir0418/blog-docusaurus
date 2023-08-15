---
title: 服务器网络环境配置
date: 2023-08-10T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
---

## 记录一下tplink路由器设置与服务器网络环境配置

- 问题

设备：ubuntu server 服务器，通过网线与路由器相连

将 ubuntu server 的 mac 地址与内网 ip 绑定

一开始是将这台服务器设置为路由器的 DMZ 主机，即路由器公网 ip 接收到的请求都会优先转发给这台服务器上，包括 22 端口的 ssh 连接等

之后便可以通过域名（tplink 提供的免费 dns 服务）远程连接到这台服务器了

但是服务器上 8080 端口启动的 nginx 服务，内网可以正确访问，但公网访问不了

检查了 ufw ，允许 nginx HTTP 以及 8080 端口的访问

怀疑是路由器设置问题，又在路由器8080端口创建了虚拟服务器，将公网8080端口的请求转发给服务器内网ip的8080端口

还是不行

- 解决

后面为了安全考虑，用虚拟服务器的功能替代了 DMZ 主机功能，开放 22、21 等远程端口，目前远程连接一切正常

此时又尝试了下 8080 端口的虚拟服务，还是不行

最后改了一组端口映射（1234:8080），就可以了，可能 8080 端口是被内网某个设备或应用占用了。。

- 总结：ufw 开启端口，路由器利用虚拟服务器功能做请求端口转发（8080:8080），如果不通，可以换一组端口映射试试（1234:8080），尽量使用虚拟服务器功能替代 DMZ 主机功能