---
title: "Hugo 博客搭建指南"
date: 2026-06-05T11:00:00+08:00
draft: false
summary: "详细介绍如何使用 Hugo 和 github-style 主题搭建个人博客"
tags: ["Hugo", "教程", "博客"]
---

## Hugo 简介

Hugo 是一个用 Go 语言编写的静态网站生成器，以其构建速度快而闻名。相比其他静态网站生成器，Hugo 有以下优势：

- ⚡ 构建速度极快（毫秒级）
- 🔄 跨平台支持
- 📦 单一二进制文件，无需复杂依赖
- 🎨 丰富的主题生态

<!--more-->

## 安装 Hugo

### macOS

```bash
brew install hugo
```

### Windows

```bash
choco install hugo-extended
```

### Linux

```bash
snap install hugo
```

## 创建新站点

```bash
hugo new site myblog
cd myblog
```

## 添加主题

将主题克隆到 `themes` 目录：

```bash
git clone https://github.com/MeiK2333/github-style.git themes/github-style
```

## 创建文章

```bash
hugo new post/my-first-post.md
```

## 本地预览

```bash
hugo server -D
```

访问 `http://localhost:1313` 即可预览。

## 构建生产版本

```bash
hugo --gc --minify
```

生成的静态文件在 `public` 目录中。
