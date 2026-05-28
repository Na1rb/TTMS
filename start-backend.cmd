@echo off
setlocal
cd /d %~dp0

if "%JAVA_HOME%"=="" (
  echo [ERROR] JAVA_HOME 未配置，请先将 JDK 17 配置到 JAVA_HOME。
  exit /b 1
)

echo [INFO] 启动 TTMS 后端...
call mvnw.cmd spring-boot:run
