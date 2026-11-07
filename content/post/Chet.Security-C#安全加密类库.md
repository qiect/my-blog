---
title: "Chet.Security：加密这件事，别每次都从 Stack Overflow 抄"
date: 2024-06-27T10:00:00+08:00
draft: false
summary: "C# 安全与加密工具类库，27+ 算法类、400+ 方法，覆盖哈希、对称/非对称加密、混合加密、密钥派生与国密 SM2/SM3/SM4。"
tags: ["开源项目", ".NET", "安全"]
---

我见过太多这样的代码：

```csharp
var md5 = MD5.Create();
var bytes = md5.ComputeHash(Encoding.UTF8.GetBytes(input));
```

能用，但问题不少：大小写不统一、没有加盐、硬编码密钥、AES 的 IV 随手写个字符串。这些代码大多是从某篇十年前的博客里抄来的，抄的时候能跑，上线之后就成了安全隐患。

更麻烦的是国密。项目要求 SM2/SM3/SM4，你去翻 BouncyCastle 的 API，文档稀薄，示例零散，光是跑通一个 SM4 就要折腾半天。

<!--more-->

## 一个库把常见加密场景收齐

```bash
dotnet add package Chet.Security
```

Chet.Security 收录了 27 个以上的算法类、400 多个方法。覆盖范围大概是这样的：

**哈希**

MD5、SHA-1、SHA-2、SHA-3、SM3、HMAC、Blake2

**对称加密**

AES、DES、3DES、RC2、ChaCha20-Poly1305、SM4

**非对称加密**

RSA、DSA、ECC、SM2

**混合加密**

RSA + AES-GCM、SM2 + SM4、ECIES 等信封加密方案

**密钥派生**

PBKDF2、BCrypt、SCrypt、HKDF、Argon2id

**其他**

安全随机数、Hex/Base64/Base32/Base58 编码、CRC32/CRC64/Adler32 校验和

## 混合加密才是真实用法

非对称加密安全，但慢。直接拿 RSA 加密一段长文本，性能会非常难看。

真实场景里的做法是"信封加密"：用对称密钥加密数据，再用非对称密钥加密那个对称密钥。Chet.Security 把这套方案封装好了，长文本性能能提升三到四个数量级。

这类方案自己在项目里手写，很容易写出一个"看起来安全、实际上有漏洞"的东西。用经过整理的实现，至少少踩一半的坑。

## 国密支持

SM2、SM3、SM4 都是完整实现，遵循 GM/T 标准，底层基于 BouncyCastle。

对做政务、金融、国企项目的开发者来说，这一块往往是硬性要求。以前要么自己啃 BouncyCastle，要么找一个半成品库改。现在一条 `dotnet add package` 就能解决。

## 用法足够直白

```csharp
using Chet.Security;

// 哈希
string md5 = MD5Helper.ComputeHash("hello");
string sha256 = SHAHelper.ComputeSHA256("hello");
string sm3 = SM3Helper.ComputeHash("hello");

// AES-CBC，密钥和 IV 自动规范化
string cipher = AESHelper.Encrypt("plaintext", "password", "my-iv");
string plain  = AESHelper.Decrypt(cipher, "password", "my-iv");

// AES-GCM 认证加密
string gcm = AESHelper.EncryptGCM("data", "key", "nonce");
string decoded = AESHelper.DecryptGCM(gcm, "key", "nonce");

// RSA，PEM 格式密钥对
var (publicPem, privatePem) = RSAHelper.GenerateKeyPair(2048);
string enc = RSAHelper.Encrypt("hello", publicPem);
string dec = RSAHelper.Decrypt(enc, privatePem);

// 密码哈希
string hashed = BCryptHelper.HashPassword("password");
bool ok = BCryptHelper.VerifyPassword("password", hashed);

// 安全随机 Token
string token = SecurityHelper.GenerateRandomBase64(32);
```

统一的 `SecurityHelper` 门面和 `ISecurityService` 抽象，也可以通过 `CryptoAlgorithm` 分发，方便依赖注入和单元测试。

## 兼容性

同时支持 `netstandard2.1` 和 `net8.0`，内置 polyfill 兼容层。老项目、新项目都能接。

MIT 协议，可商用。

## 适合谁

- 项目里有一堆"祖传加密代码"、想统一掉的人
- 需要国密算法但不想啃 BouncyCastle 的开发者
- 需要做密码哈希、令牌生成、数据加密的标准实现的人

**文档**：https://qiect.github.io/Chet.Security/

> 加密代码最危险的地方在于：写错了也能跑，跑起来也不报错。
