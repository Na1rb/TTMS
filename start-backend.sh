#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

if [ -z "$JAVA_HOME" ]; then
  echo "[ERROR] JAVA_HOME 未配置，请先将 JDK 17 配置到 JAVA_HOME。"
  exit 1
fi

echo "[INFO] 启动 TTMS 后端..."
./mvnw spring-boot:run
