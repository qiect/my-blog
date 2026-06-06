---
title: "DotNetCore使用ElasticSearch+NEST"
date: 2026-04-05T22:52:00+08:00
draft: false
summary: "在 .Net Core 项目中使用 NEST 客户端操作 ElasticSearch，包括 ES 安装、NEST 依赖注入及 ElasticSearch-Head 工具的安装配置"
tags: [".NetCore", "ElasticSearch", "NEST", "搜索"]
---

Elasticsearch是一个基于Lucene的搜索服务器。它提供了一个分布式多用户能力的全文搜索引擎，基于RESTful web接口。Elasticsearch是用Java语言开发的，并作为Apache许可条款下的开放源码发布，是一种流行的企业级搜索引擎。Elasticsearch用于云计算中，能够达到实时搜索，稳定，可靠，快速，安装使用方便。官方客户端在Java、.NET（C#）、PHP、Python、Apache Groovy、Ruby和许多其他语言中都是可用的。根据DB-Engines的排名显示，Elasticsearch是最受欢迎的企业搜索引擎，其次是Apache Solr，也是基于Lucene。

<!--more-->

## 如何安装ElasticSearch？

1. 安装JDK

2. 安装ElasticSearch，下载解压后运行\bin\elasticsearch.bat，完成后浏览器输入 http://localhost:9200/ ，看到下面这样就说明安装成功了

![ElasticSearch安装成功](/images/DotNetCore使用ElasticSearch+NEST/16104412_1.png)

## .Net Core如何使用NEST客户端

1. 直接在NuGet里搜索NEST安装就可以用了

2. 为了遵循.Net Core的IOC原则，我们这里依赖注入NEST，在项目目录中新建Service文件夹，Service下创建EsClientProvider.cs类和IEsClientProvider.cs类，内容如下：

![EsClientProvider](/images/DotNetCore使用ElasticSearch+NEST/16104412_2.png)

![IEsClientProvider](/images/DotNetCore使用ElasticSearch+NEST/16104412_3.png)

3. 完成后就可以在Controller里注入了，如下图：

![Controller注入](/images/DotNetCore使用ElasticSearch+NEST/16104412_4.png)

为了更好的使用ElasticSearch，我们可以借助ElasticSearch-Head工具来查询或者新增数据

## 如何安装ElasticSearch-Head工具？

在此我看了网上很多的安装资料，安装步骤比较繁琐或者已经不适应当前的版本了，最新的安装方式如下：

1.去GitHub上下载最新的ElasticSearch-Head，下载后解压

![GitHub下载](/images/DotNetCore使用ElasticSearch+NEST/16104412_5.png)

2.用cmd命令行的方式cd到elasticsearch-head目录

3.依次输入以下命令

```
npm install

npm run start
```

这里需要注意的是npm install的时候会安装很多东西，如果网络不稳定，换个网络下载即可，作者碰到的坑就在这里，浪费了很多时间；看到下图的内容就说明head工具安装和运行成功了，祝贺你

![npm运行成功](/images/DotNetCore使用ElasticSearch+NEST/16104412_6.png)

也可以访问 http://localhost:9100/，跟我下面的图内容差不多也说明成功了

![Head工具界面](/images/DotNetCore使用ElasticSearch+NEST/16104412_7.png)
