---
title: 操作 FileList
date: 2024-06-30T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [File, FileList, DataTransferList]
---

#### 问题

多文件上传前，支持移除某个文件

但问题在于 **FileList 伪数组是只读**的，我们可以通过索引 `fileList[index]` 读取其中的 File 对象，但无法增加或删除文件列表的数据

#### 解决方案


可以借助 `Array.from` 结合 `DataTransferList` 来处理 FileList 数据

首先将 FileList 转为数组，方便增加或删除的操作

```js
const fileArr = Array.from(fileList)

fileArr.push(newFile)

fileArr.splice(deleteIndex, 1)
```

然后使用 `DataTransferList` 将处理后的 File 数组恢复为 `FileList`

```js
const dataTransfer = new DataTransfer()

// 使用 dataTransfer.items.add 方法将数组中的 File 添加到 dataTransfer
fileArray.forEach((file) => {
  dataTransfer.items.add(file)
})

// 此时 dataTransfer.files 属性就是 FileList 类型
field.onChange(dataTransfer.files)
```
