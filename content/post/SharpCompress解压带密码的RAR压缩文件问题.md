---
title: "SharpCompress解压带密码的RAR压缩文件问题"
date: 2025-10-25T14:24:00+08:00
draft: false
summary: "使用 SharpCompress 解压带密码的压缩文件时遇到的问题及解决方案，RAR 解压失败后改用 ZIP 格式并逐文件写入的完整过程"
tags: [".NetCore", "SharpCompress", "压缩解压", "ZIP"]
---

因为保密性的原因，我需要针对压缩文件加密，也就是在压缩的同时加上密码；然后代码解压带密码的压缩文件，再去处理解压后的文件。

<!--more-->

## 问题描述

在使用SharpCompress解压带密码的压缩文件时遇到的一系列问题。

例如：

1.解压带密码的rar文件，未解压成功，最后改为zip文件；

2.解压带密码的zip文件，WriteToDirectory时解压过程中会抛异常，后改用WriteToFile；

## 解决方案：

在使用SharpCompress解压带密码的rar压缩文件是，报file crc mismatch问题；

```csharp
using (Stream stream = File.OpenRead(tempPath))
{
    //压缩文件解密
    var rarPassword = Configuration["RARPassword"];
    var reader = ReaderFactory.Open(stream, new ReaderOptions() { Password = rarPassword });
    while (reader.MoveToNextEntry())
    {
        if (!reader.Entry.IsDirectory)
        {
            Console.WriteLine(reader.Entry.Key);
            Directory.CreateDirectory(@$"{currentDic}/wwwroot/temp/SQL");
            reader.WriteEntryToDirectory(@$"{currentDic}/wwwroot/temp/SQL");
        }
    }
}
```

这段代码是把压缩文件的流读取到内存中，再用ReaderFactory去带密解压缩，但在解压缩的时候抛异常，我这里压缩文件里有几十个文件，却只解压了一个文件，所以我想既然可以解压出来一个，说明解密肯定没问题，只不过在解压多个文件的时候抛了异常，内部什么原因就不知道了，只能换个方法。

于是，我按照下面的代码改了下，一个一个输出，发现还是不行。

```csharp
reader.WriteEntryToFile(Path.Combine(@$"{currentDic}/wwwroot/temp/SQL", reader.Entry.Key));
```

没办法，我放弃了RAR方式，改用ZIP。

```csharp
using (var archive = ArchiveFactory.Open(tempPath, new ReaderOptions { Password = rarPassword }))
{
    foreach (var entry in archive.Entries)
    {
        if (!entry.IsDirectory)
        {
            Console.WriteLine(entry.Key);
            Directory.CreateDirectory(@$"{currentDic}/wwwroot/temp/SQL");
            entry.WriteToDirectory(@$"{currentDic}/wwwroot/temp/SQL");
        }
    }
}
```

用这种方式后，可以把所有的文件解压出来，但每个文件里面都没内容，只是个空文件。

于是 我又尝试单个文件输出，不直接写整个目录了。

```csharp
entry.WriteEntryToFile(Path.Combine(@$"{currentDic}/wwwroot/temp/SQL", entry.Entry.Key));
```

最后可以了。

最终可行的解压带密码的zip压缩文件代码：

```csharp
using (var archive = ArchiveFactory.Open(tempPath, new ReaderOptions { Password = rarPassword }))
{
    foreach (var entry in archive.Entries)
    {
        if (!entry.IsDirectory)
        {
            Console.WriteLine(entry.Key);
            Directory.CreateDirectory(@$"{currentDic}/wwwroot/temp/SQL");
            entry.WriteToFile(Path.Combine(@$"{currentDic}/wwwroot/temp/SQL", entry.Key));
        }
    }
}
```

## 总结：

最奇葩的是用这种方式解压带密码的rar文件，都是空文件，zip就没问题，知道的兄弟可以留言下。

![SharpCompress](/images/SharpCompress解压带密码的RAR压缩文件问题/16363110_1.png)
