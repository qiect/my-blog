FROM nginx:alpine

# 复制构建好的静态文件到 nginx 目录
COPY . /usr/share/nginx/html/

# 复制 nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
