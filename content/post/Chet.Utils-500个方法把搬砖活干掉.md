---
title: "Chet.Utils：500 多个方法，专治 .NET 项目里那些重复的搬砖代码"
date: 2025-10-11T10:00:00+08:00
draft: false
summary: "12 个扩展方法类 + 11 个帮助类，覆盖字符串、日期、集合、数值、HTTP、正则等日常场景。"
tags: ["开源项目", ".NET", "工具类库"]
---

每个 .NET 项目里，都藏着几个叫 `StringHelper`、`DateUtil`、`CommonUtils` 的文件。

打开一看，是历代同事留下的祖传代码：有的方法全世界只有原作者知道怎么用，有的连原作者都忘了，还有的在生产环境埋了个坑——比如那个永远返回 `true` 的手机号校验。

项目一多，这些工具类就跟着复制粘贴。改一个 bug，得改八个项目。

<!--more-->

## 干脆收进一个 NuGet 包里

```bash
dotnet add package Chet.Utils
```

Chet.Utils 收录了 12 个扩展方法类和 11 个帮助类，方法总数 500 多个。主打一个"想用的时候刚好有"。

举几个日常用得最多的：

```csharp
using Chet.Utils;
using Chet.Utils.Helpers;

// 字符串验证
"test@example.com".IsEmail();          // true
"13800138000".IsMobilePhone();         // 类似这样顺手

// 日期处理
DateTime.Now.IsWeekend();              // 是不是周末
DateTime.Now.ToChineseDateString();    // 中文日期

// 集合分页
var page = list.GetPage(1, 10);

// 数值格式化
12345.ToThousandsString();             // "12,345"
12345.ToChineseNumber();               // "一万二千三百四十五"

// HTTP 请求
var http = new HttpClientHelper();
var data = await http.GetAsync<string>("https://api.example.com/data");

// 正则
RegexHelper.IsMobilePhone("13800138000");
```

写完你会发现，代码里突然少了很多 `if` 和 `try`。

## 他不是一个"什么都往里塞"的垃圾桶

很多工具库的问题在于贪多。Chet.Utils 的取舍比较克制：只收那些**每个项目都会遇到、但又不值得单独造轮子**的东西。

同时它做了几件正经事：

- **空值检查和异常处理**都补齐了，不会在半路给你一个 `NullReferenceException`
- **性能做过优化**，减少不必要的内存分配
- **完整 XML 注释**，IDE 里能看到说明和示例，不用翻文档
- **双目标框架**：同时支持 `netstandard2.1` 和 `net8.0`，老项目也能用
- **API 命名符合 .NET 规范**，不是那种自创风格的野路子

## 一个真实的省钱场景

我见过一个项目，光日期格式化就在五个地方写了五份不同的实现。一份输出 `2026-11-08`，一份输出 `2026/11/08`，还有一份把时区算错了。

这种问题不会报错，只会在某天导出报表的时候，让财务发现数字对不上。

工具库最大的价值，其实是**让同一件事只存在一种写法**。

## 适合谁

- 手上项目多、工具类到处复制的开发者
- 想减少依赖、又不想自己维护一套基础库的团队
- 刚接触 .NET，想看看"标准写法长什么样"的新人

MIT 协议，随便用。

**文档与示例**：https://qiect.github.io/Chet.Utils/

> 工具类库不能让你变强，但能让你少写点没意义的代码。
