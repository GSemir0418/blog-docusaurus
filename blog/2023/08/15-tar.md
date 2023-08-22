---
title: tar 命令
date: 2023-08-15T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
---
tar 命令是 linux 系统中用于文件归档与压缩工具

tar 是 `tape archive`（磁带存档）的缩写，它最初是为了在磁带上进行文件备份和恢复而设计的。随着时间的推移，它逐渐演变成了一个通用的文件处理工具，用于创建归档、压缩文件和目录等。它的特点在于，它可以将多个文件或目录打包成一个单独的文件，并且可以应用不同的压缩算法。

### 创建归档文件

`tar -cvf archive_name.tar /path/to/source/*`

- `c` 表示创建新的归档文件
- `v` 表示暴露详细归档过程
- `f` 表示指定归档文件名

### 解压归档文件

`tar -xvf archive_name.tar` 默认当前目录

- `x` 表示解压归档文件

### 压缩文件

`tar -cvfz archive_name.tar.gz /path/to/source/*`

- `z` 表示使用gzip算法进行压缩，文件名也要指定为 *.gz

### 指定解压路径 

`tar -xvf archive.tar -C /path/to/target`

- `C` 指定解压路径

### 解压部分文件

`tar -xvf archive.tar file1 file2`