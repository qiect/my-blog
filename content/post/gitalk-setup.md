---
title: "Gitalk 评论系统集成"
date: 2026-06-05T12:00:00+08:00
draft: false
summary: "如何在 Hugo 博客中集成 Gitalk 评论系统"
tags: ["Gitalk", "评论", "GitHub"]
---

## Gitalk 简介

Gitalk 是一个基于 GitHub Issue 和 Preact 的评论组件，非常适合技术博客使用。

### 特点

- 💬 基于 GitHub Issue，无需额外数据库
- 🔐 支持 GitHub 登录
- 🎨 简洁的界面设计
- 📱 响应式支持

<!--more-->

## 配置步骤

### 1. 创建 GitHub OAuth App

1. 访问 GitHub Settings → Developer settings → OAuth Apps
2. 点击 "New OAuth App"
3. 填写信息：
   - Application name: 你的应用名称
   - Homepage URL: 你的博客地址
   - Authorization callback URL: 同上

### 2. 获取凭证

注册成功后获取：
- Client ID
- Client Secret（需要生成）

### 3. 配置 Hugo

在 `config.toml` 中添加：

```toml
[params]
  enableGitalk = true

  [params.gitalk]
    clientID = "你的ClientID"
    clientSecret = "你的ClientSecret"
    repo = "你的仓库名"
    owner = "你的GitHub用户名"
    admin = "管理员用户名"
    id = "location.pathname"
    labels = "gitalk"
    perPage = 15
    pagerDirection = "last"
    createIssueManually = true
    distractionFreeMode = false
```

## 使用说明

- 当 `createIssueManually = false` 时，访问文章会自动创建对应的 Issue
- 当 `createIssueManually = true` 时，需要管理员手动创建第一个评论

## 注意事项

1. 确保仓库是公开的
2. OAuth App 的 callback URL 必须与博客地址一致
3. Client Secret 不要泄露
