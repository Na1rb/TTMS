#!/usr/bin/env bash
# ============================================================
# TTMS 一键部署脚本
# 用法：在项目根目录执行
#   chmod +x deploy.sh && ./deploy.sh
# ============================================================
set -e

echo "========================================"
echo "  TTMS 票务管理系统 - Docker 部署"
echo "========================================"

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "[ERROR] Docker 未安装，请先安装 Docker"
    exit 1
fi

if ! command -v docker compose &> /dev/null; then
    echo "[ERROR] Docker Compose 未安装"
    exit 1
fi

echo "[1/4] 拉取最新基础镜像..."
docker pull node:20-alpine
docker pull nginx:alpine

echo "[2/4] 构建并启动所有服务（前端无缓存构建）..."
docker compose build --no-cache frontend
docker compose build backend
docker compose up -d

echo "[3/4] 等待服务启动..."
echo "      等待 MySQL 初始化（约 30 秒）..."
sleep 20

echo "[4/4] 检查服务状态..."
docker compose ps

echo ""
echo "  验证前端是否更新："
echo "    docker exec ttms-frontend ls -lh /usr/share/nginx/html/"
echo ""

echo "========================================"
echo "  ✅ 部署完成！"
echo "========================================"
echo ""
echo "  访问地址："
echo "    前端页面：http://服务器IP"
echo "    后端 API：http://服务器IP:8080/rest"
echo "    数据库：  localhost:3306 (root / root123456)"
echo ""
echo "  ⚠️ 如果前端仍无变化，请在浏览器按 Ctrl+Shift+R 强制刷新"
echo "    或使用隐私/无痕模式打开页面"
echo ""
echo "  测试账号："
echo "    管理员 - admin / admin123"
echo "    经理   - manager / 123456"
echo "    售票员 - clerk / 123456"
echo "    VIP    - vip / 123456"
echo ""
echo "  常用命令："
echo "    查看日志：  docker compose logs -f"
echo "    重启服务：  docker compose restart"
echo "    停止服务：  docker compose down"
echo "    清理数据：  docker compose down -v"
echo "========================================"
