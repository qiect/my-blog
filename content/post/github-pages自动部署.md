---
title: "GitHub Pages 自动部署"
date: 2026-06-05T13:00:00+08:00
draft: false
summary: "使用 GitHub Actions 自动部署 Hugo 博客到 GitHub Pages"
tags: ["GitHub Actions", "CI/CD", "部署"]
---

## GitHub Actions 简介

GitHub Actions 是 GitHub 提供的持续集成/持续部署（CI/CD）服务，可以自动化你的工作流程。

<!--more-->

## 工作流配置

创建 `.github/workflows/deploy.yml` 文件：

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches:
      - main
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        
      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v3
        with:
          hugo-version: '0.125.0'
          extended: true
          
      - name: Build
        run: hugo --gc --minify
        
      - name: Deploy
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./public
```

## 启用 GitHub Pages

1. 进入仓库 Settings → Pages
2. Source 选择 "GitHub Actions"
3. 保存后工作流会自动运行

## 部署流程

每次推送到 `main` 分支时：

1. GitHub Actions 自动触发
2. 拉取代码
3. 安装 Hugo
4. 构建静态文件
5. 部署到 GitHub Pages

## 自定义域名（可选）

在 `static` 目录创建 `CNAME` 文件：

```
yourdomain.com
```

然后在域名服务商配置 DNS 指向 GitHub Pages。
