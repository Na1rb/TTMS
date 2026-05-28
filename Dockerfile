# ============================================================
# TTMS 后端 Dockerfile
# 基于 JDK 17 + Maven Wrapper 构建
# ============================================================

# ---- 构建阶段 ----
FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

# 先复制依赖描述文件，利用 Docker 缓存层
COPY pom.xml ./
COPY .mvn .mvn
COPY mvnw mvnw.cmd ./
RUN chmod +x mvnw

# 下载依赖（独立缓存层）
RUN ./mvnw dependency:resolve -DskipTests -q || true

# 复制源码
COPY src src

# 使用 Docker 环境的数据库配置覆盖默认配置
COPY docker-db-config.properties src/main/resources/db-config.properties

# 构建
RUN ./mvnw package -DskipTests -q

# ---- 运行阶段 ----
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# 从构建阶段复制 JAR
COPY --from=builder /app/target/*.jar app.jar

# 时区
ENV TZ=Asia/Shanghai
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
