# ============================================================
# TTMS 前端 Dockerfile
# 基于 Node.js 构建 + Nginx 运行
# 优化：分层缓存 → 仅 package.json 变化时才重装依赖
# ============================================================

# ---- 构建阶段 ----
FROM node:20-alpine AS builder

WORKDIR /app

# ① 先复制依赖描述文件（独立层，极少变化 → 缓存复用率高）
COPY package.json ./

# ② 安装依赖（此层仅在 package.json 变化时重建）
RUN npm install --registry=https://registry.npmmirror.com

# ③ 复制所有源码（.dockerignore 已排除 node_modules / dist / .git）
COPY . .

# ④ 构建（源码变化 → 从此步开始重建）
RUN npm run build

# ---- 运行阶段 ----
FROM nginx:alpine

WORKDIR /usr/share/nginx/html

# 清除默认页面
RUN rm -rf ./*

# 从构建阶段复制构建产物
COPY --from=builder /app/dist .

# 复制 Nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 时区
ENV TZ=Asia/Shanghai
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
