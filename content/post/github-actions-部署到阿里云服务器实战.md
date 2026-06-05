---
title: "GitHub Actions 自动部署博客到阿里云服务器实战"
date: 2026-06-05T15:00:00+08:00
draft: false
summary: "记录从 GitHub Actions 自动构建 Hugo 博客，通过 SSH 部署到阿里云服务器 Docker 容器的完整过程，以及踩过的坑和解决方案"
tags: ["GitHub Actions", "Docker", "阿里云", "CI/CD", "部署"]
---

## 前言

我的博客使用 Hugo + github-style 主题搭建，源码托管在 GitHub 上。为了同时支持 GitHub Pages 和阿里云服务器访问，我配置了 GitHub Actions 工作流，实现推送代码后自动构建并部署到两个地方。本文记录了整个部署过程中遇到的问题和解决方案。

<!--more-->

## 整体架构

```
代码推送到 GitHub main 分支
        ↓
GitHub Actions 触发构建
        ↓
Hugo 构建静态文件
        ↓
   ┌────┴────┐
   ↓         ↓
GitHub Pages  SSH 部署到阿里云
              ↓
         Docker 容器 (nginx:alpine)
              ↓
         端口 8000 对外访问
```

## 一、GitHub Pages 部署

### 工作流配置

GitHub Pages 部署相对简单，使用官方 Actions 即可：

```yaml
- name: Setup Pages
  id: pages
  uses: actions/configure-pages@v4

- name: Build with Hugo
  run: |
    hugo --gc --minify --baseURL "${{ steps.pages.outputs.base_url }}/"

- name: Upload artifact
  uses: actions/upload-pages-artifact@v3
  with:
    path: ./public
```

### 踩坑：主题目录结构

**问题**：最初直接将主题文件放在项目根目录，构建时报错：

```
Error: module "github-style" not found in "themes/github-style"
```

**解决**：Hugo 要求主题文件必须放在 `themes/` 目录下。将 `layouts/`、`static/` 等文件移动到 `themes/github-style/` 目录即可。

### 踩坑：静态资源路径 404

**问题**：部署后图片、CSS 等静态资源返回 404。

**原因**：配置文件中使用了绝对路径 `/images/avatar.png`，在子目录部署时（如 `/my-blog/`），浏览器会请求 `https://qiect.github.io/images/avatar.png`，而不是正确的 `https://qiect.github.io/my-blog/images/avatar.png`。

**解决**：将路径改为相对路径：

```toml
# 修改前
favicon = "/images/github-mark.png"

# 修改后
favicon = "images/github-mark.png"
```

### 踩坑：搜索功能 index.json 404

**问题**：搜索功能请求 `/index.json` 返回 404。

**原因**：`search.js` 中硬编码了绝对路径 `fetch('/index.json')`。

**解决**：改为相对路径 `fetch('index.json')`。

## 二、Gitalk 评论系统集成

### 踩坑：敏感信息泄露

**问题**：Gitalk 的 `clientID` 和 `clientSecret` 直接写在 `config.toml` 中，提交到公开仓库不安全。

**解决**：使用 GitHub Secrets + 构建时替换的方案：

1. 配置文件使用占位符：
   ```toml
   [params.gitalk]
     clientID = "{{ GITALK_CLIENT_ID }}"
     clientSecret = "{{ GITALK_CLIENT_SECRET }}"
   ```

2. 工作流构建前替换：
   ```yaml
   - name: Replace Gitalk secrets
     run: |
       sed -i 's/{{ GITALK_CLIENT_ID }}/${{ secrets.GITALK_CLIENT_ID }}/g' config.toml
       sed -i 's/{{ GITALK_CLIENT_SECRET }}/${{ secrets.GITALK_CLIENT_SECRET }}/g' config.toml
   ```

3. 在 GitHub 仓库 Settings → Secrets 中添加 `GITALK_CLIENT_ID` 和 `GITALK_CLIENT_SECRET`。

### 关于私有仓库

最初考虑将仓库改为私有来保护敏感信息，但发现 **GitHub 免费账户的私有仓库不支持 GitHub Pages**。所以最终选择了 Secrets 方案。

## 三、阿里云服务器 Docker 部署

### 方案选择

选择使用 Docker + nginx 方案，优势：
- 环境隔离，不污染宿主机
- 部署简单，一条命令启动
- 方便更新和回滚

### Dockerfile

```dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### nginx 配置

```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html index.htm;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    gzip_min_length 1000;
}
```

### 踩坑：artifact 下载问题

**问题**：使用 `actions/download-pages-artifact@v3` 报错：
```
Unable to resolve action actions/download-pages-artifact, repository not found
```

**解决**：改用 `actions/download-artifact@v4`：
```yaml
- name: Download artifact
  uses: actions/download-artifact@v4
  with:
    name: github-pages
    path: ./artifact
```

### 踩坑：artifact.tar 未解压

**问题**：下载的 artifact 是一个 `artifact.tar` 压缩包，直接传到服务器无法使用。

**解决**：在 Actions 中先解压再传输：
```bash
mkdir -p public
cd artifact
if [ -f artifact.tar ]; then
  tar -xf artifact.tar -C ../public/
else
  cp -r * ../public/ 2>/dev/null || true
fi
```

### 踩坑：Docker 权限问题

**问题**：SSH 部署时执行 `docker` 命令报错：
```
permission denied while trying to connect to the docker API
```

**尝试方案 1**：将用户添加到 docker 组
```bash
sudo usermod -aG docker github
```
结果：`sudo` 需要密码，SSH 非交互模式下无法输入。

**尝试方案 2**：配置 sudo 免密码
```bash
sudo visudo
# 添加：github ALL=(ALL) NOPASSWD: ALL
```
结果：✅ 成功！所有 `docker` 命令前加 `sudo` 即可。

### 最终部署流程

```yaml
# 1. 停止并删除旧容器
sudo docker stop myblog 2>/dev/null || true
sudo docker rm myblog 2>/dev/null || true
sudo docker rmi myblog:latest 2>/dev/null || true

# 2. 复制文件到服务器

# 3. 构建并运行新容器
cd /tmp/myblog
sudo docker build -t myblog:latest .
sudo docker run -d \
  --name myblog \
  --restart always \
  -p 8000:80 \
  myblog:latest
```

## 四、GitHub Secrets 配置清单

在仓库 Settings → Secrets and variables → Actions 中添加：

| Secret 名称 | 说明 |
|---|---|
| `GITALK_CLIENT_ID` | Gitalk OAuth App Client ID |
| `GITALK_CLIENT_SECRET` | Gitalk OAuth App Client Secret |
| `SERVER_USERNAME` | 阿里云服务器 SSH 用户名 |
| `SERVER_PASSWORD` | 阿里云服务器 SSH 密码 |

## 五、经验总结

1. **路径问题**：子目录部署时，所有静态资源路径必须使用相对路径，避免绝对路径导致 404
2. **敏感信息**：公开仓库的敏感信息必须使用 GitHub Secrets，构建时动态注入
3. **Artifact 处理**：GitHub Actions 的 artifact 可能是压缩包，需要先解压再使用
4. **Docker 权限**：非 root 用户执行 Docker 命令需要配置权限，推荐 `sudo` 免密码方案
5. **容器重启策略**：使用 `--restart always` 确保容器异常退出后自动重启

## 六、后续优化方向

- [ ] 配置 nginx 反向代理，通过域名 80 端口直接访问
- [ ] 配置 HTTPS 证书（Let's Encrypt）
- [ ] 添加 CDN 加速
- [ ] 配置服务器监控和告警

---

> 部署是一场修行，每个坑都是成长。希望这篇文章能帮到同样在折腾博客部署的你。
