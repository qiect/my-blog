# My Blog

基于 Hugo 和 github-style 主题搭建的个人技术博客。

## 🚀 快速开始

### 本地预览

```bash
# 安装 Hugo (扩展版)
brew install hugo  # macOS
# 或
choco install hugo-extended  # Windows

# 克隆仓库
git clone https://github.com/qiect/my-blog.git
cd my-blog

# 启动本地服务器
hugo server -D

# 访问 http://localhost:1313/my-blog/
```

### 创建新文章

```bash
hugo new post/文章标题.md
```

编辑生成的文件，将 `draft: true` 改为 `draft: false` 即可发布。

## 📁 项目结构

```
my-blog/
├── .github/
│   └── workflows/
│       └── deploy.yml       # GitHub Actions 自动部署
├── content/
│   ├── post/                # 博客文章
│   └── readme.md            # 首页 README
├── themes/
│   └── github-style/        # 主题文件
├── config.toml              # Hugo 配置文件
└── README.md                # 本文件
```

## ✨ 功能特性

- 🎨 **GitHub 风格设计** - 简洁优雅的界面
- 💬 **Gitalk 评论系统** - 基于 GitHub Issue 的评论
- 🔍 **本地搜索** - 基于 fuse.js 的全文搜索
- 🌙 **暗色模式** - 支持明暗主题切换
- 📱 **响应式设计** - 完美支持移动端
- 📊 **LaTeX 支持** - 支持 KaTeX 和 MathJax 数学公式
- 🏷️ **标签分类** - 文章标签和分类支持
- 📡 **RSS 订阅** - 支持 RSS 订阅
- 🚀 **自动部署** - GitHub Actions 自动构建部署

## 📝 文章管理

### 文章格式

```yaml
---
title: "文章标题"
date: 2026-06-05T10:00:00+08:00
draft: false
summary: "文章摘要"
tags: ["标签1", "标签2"]
pin: true  # 可选：置顶文章
katex: math  # 可选：启用 LaTeX
---

文章内容...
```

### 摘要控制

**方式一**：使用 `summary` 字段

**方式二**：使用 `<!--more-->` 分隔符

```markdown
这部分显示在列表页

<!--more-->

这部分只在详情页显示
```

## 🔧 配置说明

主要配置在 `config.toml` 文件中：

### 基本信息

```toml
baseURL = "https://qiect.github.io/my-blog/"
title = "我的博客"

[params]
  author = "qiect"
  description = "个人博客描述"
  github = "qiect"
```

### Gitalk 评论

```toml
[params]
  enableGitalk = true

  [params.gitalk]
    clientID = "your-client-id"
    clientSecret = "your-client-secret"
    repo = "my-blog"
    owner = "qiect"
```

## 🚢 部署

博客使用 GitHub Actions 自动部署到 GitHub Pages。

### 部署流程

1. 推送代码到 `main` 分支
2. GitHub Actions 自动触发构建
3. Hugo 构建静态文件
4. 自动部署到 GitHub Pages

### 手动部署

```bash
hugo --gc --minify
```

生成的文件在 `public/` 目录。

## 📖 相关链接

- [博客地址](https://qiect.github.io/my-blog/)
- [GitHub 仓库](https://github.com/qiect/my-blog)
- [Hugo 官方文档](https://gohugo.io/documentation/)
- [github-style 主题](https://github.com/MeiK2333/github-style)

## 📄 许可证

本项目基于 MIT 许可证开源。

主题基于 [github-style](https://github.com/MeiK2333/github-style) (MIT License)。
