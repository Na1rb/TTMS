# 🎬 TTMS 票务管理系统

> **T**icket & **T**heater **M**anagement **S**ystem — 前后端分离的影院票务管理平台

---

## 📋 目录

- [1. 项目概览](#1-项目概览)
- [2. 环境要求](#2-环境要求)
- [3. 项目资源清单](#3-项目资源清单)
- [4. 数据库初始化](#4-数据库初始化)
- [5. 本地开发启动](#5-本地开发启动)
- [6. Docker Compose 部署](#6-docker-compose-部署)
- [7. 配置文件说明](#7-配置文件说明)
- [8. 测试账号与权限](#8-测试账号与权限)
- [9. 初始化数据说明](#9-初始化数据说明)
- [10. 常用接口](#10-常用接口)
- [11. 常见问题](#11-常见问题)

---

## 1. 项目概览

| 层级 | 技术栈 |
|------|--------|
| **后端** | Java 17 · Spring Boot 3.5.14 · MyBatis 3.0.4 · MySQL 8.4 |
| **前端** | Vue 3.4 · Vite 5 · Pinia 2 · Vue Router 4 · Axios · ECharts 5 · Tailwind CSS 3 |
| **数据库** | MySQL 8.0 (utf8mb4) |
| **部署** | Docker · Docker Compose · Nginx (Alpine) |

**目录结构：**

```text
TTMS/
├── src/                              # 后端源码 (Spring Boot)
│   └── main/
│       ├── java/com/example/ttms/    # Java 业务代码
│       └── resources/
│           └── db-config.properties  # 本地数据库配置
├── TTMS_vue3_web/                    # 前端源码 (Vue 3)
│   ├── src/                          # Vue 组件 & 路由 & Store
│   ├── public/                       # 静态资源
│   ├── Dockerfile                    # 前端多阶段构建
│   ├── nginx.conf                    # Nginx 反向代理配置
│   ├── vite.config.js               # Vite + 开发代理
│   ├── tailwind.config.js           # Tailwind CSS 配置
│   └── package.json                  # 前端依赖
├── init.sql                          # 数据库初始化脚本 (建表 + 测试数据)
├── docker-compose.yml                # Docker 三服务编排
├── Dockerfile                        # 后端镜像构建
├── docker-db-config.properties       # Docker 环境数据库配置
├── deploy.sh                         # 一键部署脚本
├── start-backend.cmd / .sh           # 本地后端启动脚本
├── pom.xml                           # Maven 项目配置
├── 操作流程.md                        # 详细业务操作说明
├── HELP.md                           # 技术栈深度介绍
└── README.md                         # 本文件
```

---

## 2. 环境要求

### 本地开发

| 依赖 | 版本要求 |
|------|----------|
| JDK | **17** (必须) |
| MySQL | **8.0+** |
| Node.js | **≥20.19** 或 **≥22.12** |
| npm | **≥10** |
| Maven | 项目自带 Maven Wrapper，无需全局安装 |

### Docker 部署

- **Docker** ≥ 20.10
- **Docker Compose** ≥ 2.0

---

## 3. 项目资源清单

### 3.1 后端资源

| 资源 | 位置 | 说明 |
|------|------|------|
| 源码 | `src/main/java/com/example/ttms/` | Spring Boot 业务代码 |
| 本地数据库配置 | `src/main/resources/db-config.properties` | 开发环境使用 |
| Docker 数据库配置 | `docker-db-config.properties` | 构建镜像时覆盖使用 |
| Maven POM | `pom.xml` | 依赖与构建配置 |
| Maven Wrapper | `mvnw` / `mvnw.cmd` | 免安装 Maven |
| Dockerfile | `Dockerfile` (根目录) | 后端镜像构建 |

### 3.2 前端资源

| 资源 | 位置 | 说明 |
|------|------|------|
| 源码 | `TTMS_vue3_web/src/` | Vue 3 组件、路由、Store |
| 入口 | `TTMS_vue3_web/index.html` | HTML 模板 |
| 依赖声明 | `TTMS_vue3_web/package.json` | npm 依赖列表 |
| 构建配置 | `TTMS_vue3_web/vite.config.js` | Vite + 开发代理 |
| CSS 框架配置 | `TTMS_vue3_web/tailwind.config.js` | Tailwind CSS |
| 前端 Dockerfile | `TTMS_vue3_web/Dockerfile` | Node 构建 + Nginx 运行 |
| Nginx 配置 | `TTMS_vue3_web/nginx.conf` | 静态资源 + API 反向代理 |

### 3.3 数据库资源

| 资源 | 位置 | 说明 |
|------|------|------|
| 初始化脚本 | `init.sql` | 10 张表 + 种子数据 + 测试订单 |

### 3.4 部署资源

| 资源 | 位置 | 说明 |
|------|------|------|
| Compose 编排 | `docker-compose.yml` | MySQL + 后端 + 前端三服务 |
| 一键部署 | `deploy.sh` | 自动化构建与启动 |
| 本地后端启动 | `start-backend.cmd` / `start-backend.sh` | Windows / Unix |

---

## 4. 数据库初始化

### 4.1 创建数据库

```sql
CREATE DATABASE ttms DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 4.2 导入脚本

```bash
mysql -u root -p ttms < init.sql
```

> ⚠️ `init.sql` 必须保存为 **UTF-8** 编码，否则中文会乱码。

### 4.3 初始化内容概览

脚本包含 **10 张表**（自动先删后建）：

| 表名 | 说明 |
|------|------|
| `employee` | 员工/用户表 |
| `studio` | 演出厅表 |
| `play` | 剧目表 |
| `seat` | 座位表（外键 → studio） |
| `schedule` | 排片计划表（外键 → studio, play） |
| `ticket` | 票表（外键 → seat, schedule） |
| `sale` | 销售/订单表（外键 → employee） |
| `sale_item` | 销售明细表（外键 → ticket, sale） |
| `data_dict` | 数据字典表 |
| `mylog` | 操作日志表 |

以及 **种子数据**：5 个测试账号、3 个演出厅、4 个剧目、12 个排片、对应票数据、13 条历史订单。

---

## 5. 本地开发启动

### 5.1 启动后端

#### Windows

```bat
start-backend.cmd
```

或手动：

```bat
mvnw.cmd spring-boot:run
```

#### Linux / macOS

```bash
chmod +x start-backend.sh
./start-backend.sh
```

或手动：

```bash
./mvnw spring-boot:run
```

**后端地址：** `http://localhost:8080`  
**API 前缀：** `/rest`

### 5.2 启动前端

```bash
cd TTMS_vue3_web
npm install
npm run dev
```

**前端地址：** `http://localhost:5173`

> 开发模式下，Vite 会自动将 `/rest` 请求代理到 `http://localhost:8080`，无需额外配置。

---

## 6. Docker Compose 部署

### 6.1 一键部署

```bash
# 方式一：直接使用 docker compose
docker compose up -d --build

# 方式二：使用一键脚本
chmod +x deploy.sh && ./deploy.sh
```

### 6.2 服务架构

```
                    ┌──────────────┐
                    │   浏览器      │
                    │  :80 / :8080 │
                    └──────┬───────┘
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
        ┌──────────┐ ┌──────────┐ ┌──────────┐
        │  frontend │ │  backend  │ │   mysql   │
        │  Nginx:80 │ │  :8080   │ │  :3306   │
        │ (Vue 静态) │ │ (Spring) │ │ (MySQL8) │
        └──────────┘ └────┬─────┘ └────┬─────┘
              │            │            │
              │   /rest/   │            │
              └───代理─────►│            │
                           │  jdbc:mysql│
                           └────────────┘
```

### 6.3 服务端口

| 服务 | 容器名 | 宿主机端口 | 内部端口 |
|------|--------|:--------:|:------:|
| 前端 (Nginx) | `ttms-frontend` | `80` | `80` |
| 后端 (Spring Boot) | `ttms-backend` | `8080` | `8080` |
| MySQL | `ttms-mysql` | `3306` | `3306` |

### 6.4 Docker 默认数据库信息

| 参数 | 值 |
|------|-----|
| 数据库名 | `ttms` |
| 用户名 | `root` |
| 密码 | `12345678` |
| 字符集 | `utf8mb4` |

### 6.5 重置数据

如果修改了 `init.sql` 需要重新初始化：

```bash
docker compose down -v      # 删除数据卷（会清空数据库！）
docker compose up -d --build
```

### 6.6 常用 Docker 命令

```bash
docker compose ps              # 查看服务状态
docker compose logs -f         # 实时日志
docker compose logs backend    # 只看后端日志
docker compose restart         # 重启所有服务
docker compose down            # 停止并移除容器
docker compose down -v         # 停止并清理数据卷
```

---

## 7. 配置文件说明

### 7.1 后端数据库配置

项目使用 **两套** 数据库配置文件，在不同场景自动切换：

| 文件 | 使用场景 |
|------|----------|
| `src/main/resources/db-config.properties` | 本地开发 (`spring-boot:run`) |
| `docker-db-config.properties` | Docker 镜像构建时覆盖 |

**本地配置示例** (`db-config.properties`)：

```properties
jdbc.url=jdbc:mysql://127.0.0.1:3306/ttms?useUnicode=true&characterEncoding=utf8&...
jdbc.username=root
jdbc.password=12345678
jdbc.driverClassName=com.mysql.cj.jdbc.Driver
```

**Docker 配置** (`docker-db-config.properties`)：

```properties
# 注意：这里 host 是 mysql（Docker 内部服务名），不是 localhost
jdbc.url=jdbc:mysql://mysql:3306/ttms?useUnicode=true&characterEncoding=utf8&...
jdbc.username=root
jdbc.password=12345678
jdbc.driverClassName=com.mysql.cj.jdbc.Driver
```

> 关键区别：Docker 环境中数据库主机名是 `mysql`（Compose 服务名），本地是 `127.0.0.1`。

### 7.2 前端 Nginx 配置

`TTMS_vue3_web/nginx.conf` 核心功能：

- **静态资源托管** — Vue 构建产物 (`/usr/share/nginx/html`)
- **API 反向代理** — `/rest/` → `http://backend:8080/rest/`
- **Vue Router History 模式** — 所有路由 fallback 到 `index.html`
- **缓存策略** — HTML 禁止缓存，JS/CSS/图片长缓存（7天）
- **Gzip 压缩** — 开启，减少传输体积

### 7.3 Docker Compose 编排

`docker-compose.yml` 定义三个服务：

- **mysql** — 基于 `mysql:8.4`，挂载 `init.sql` 自动初始化
- **backend** — 基于根目录 `Dockerfile` 构建，依赖 mysql 健康检查
- **frontend** — 基于 `TTMS_vue3_web/Dockerfile` 多阶段构建，依赖 backend

---

## 8. 测试账号与权限

### 8.1 登录说明

> ⚠️ 登录使用 `emp_name`（用户名），**不是** `emp_no`（工号）。

### 8.2 内置账号

| 角色 | 用户名 | 密码 | emp_type | 可访问页面 |
|------|--------|------|:------:|-----------|
| **管理员** | `admin` | `admin123` | 3 | 首页、用户管理、演出厅管理、个人中心 |
| **经理** | `manager` | `123456` | 1 | 首页、剧目管理、排片管理、座位管理、字典管理、销售分析、个人中心 |
| **售票员** | `seller01` | `123456` | 2 | 首页、退票（页面）、未处理订单、个人中心 |
| **VIP** | `vip01` | `123456` | 4 | 首页、购票、退票、个人中心 |
| **普通用户** | `user01` | `123456` | 5 | 首页、购票、个人中心 |

### 8.3 购票时间窗口

| 用户类型 | 可购买时间窗口 | 说明 |
|----------|:----------:|------|
| 普通用户 (type=5) | 开演前 **30 分钟**内 | 标准窗口 |
| VIP (type=4) | 开演前 **50 分钟**内 | 提前 20 分钟 |

### 8.4 权限注意事项

- 售票员 `seller01` 前端可见「退票」菜单，但后端订单接口只允许 VIP/普通用户，提交会被拦截（当前代码实际行为）
- 更详细的权限矩阵见 `操作流程.md`

---

## 9. 初始化数据说明

### 9.1 演出厅

| ID | 名称 | 规格 | 座位数 |
|:--:|------|------|:----:|
| 1 | 晨星厅 | 5行×6列 | 30 |
| 2 | 海蓝厅 | 6行×8列 | 48 |
| 3 | 云幕VIP厅 | 4行×5列 | 20 |

### 9.2 剧目

| ID | 剧名 | 类型 | 语言 | 默认票价 |
|:--:|------|------|------|:----:|
| 1 | 迷城追踪 | 悬疑片 | 中文 | ¥49 |
| 2 | 月海计划 | 科幻片 | 中文字幕 | ¥69 |
| 3 | 周末训练营 | 喜剧片 | 中文 | ¥39 |
| 4 | 风筝小队 | 动画片 | 中文 | ¥45 |

### 9.3 排片时间

排片基准日期自动计算：当前时间早于 20:00 使用今天，否则使用明天，确保初始化后始终有可测试的未来场次。

---

## 10. 常用接口

所有接口前缀：`/rest`

```text
# 登录
POST /rest/login

# 登出
GET  /rest/logout

# 剧目
GET  /rest/play/getAllPlay

# 排片
GET  /rest/schedule/getScheduleByPlayId

# 座位/票
GET  /rest/ticket/getTicketByScheduleId

# 订单
POST /rest/sale/create          # 创建订单
GET  /rest/sale/pay              # 支付
GET  /rest/sale/cancel           # 取消

# 用户
POST /rest/employee/updatePassword

# 销售分析 (经理)
GET  /rest/analysis/...
```

---

## 11. 常见问题

### Q1：登录失败？

检查：① 用户名用的是 `emp_name` 不是 `emp_no`；② 密码是明文；③ 数据库已导入最新 `init.sql`。

### Q2：改了 `init.sql` 但 Docker 数据没变？

MySQL 初始化脚本只在 **首次创建数据目录** 时执行。需要：

```bash
docker compose down -v
docker compose up -d --build
```

### Q3：为什么前端能看到页面但操作被拒？

当前前端路由权限与后端接口权限不完全一致（如售票员进退票页但后端拦截）。这是当前代码的实际行为。

### Q4：中文乱码？

确保：① `init.sql` 为 UTF-8 编码；② 数据库字符集 `utf8mb4`；③ JDBC 连接参数含 `useUnicode=true&characterEncoding=utf8`。

### Q5：初始化后排片买不了票？

因为购票有时间窗口限制。用经理账号新建一个距当前 30 分钟内的排片即可。

---

> 📖 **进一步阅读：** 详细的角色操作步骤、购票/退票流程、验收测试顺序请查看 `操作流程.md`。  
> 🔧 **技术栈深度介绍：** 面向开发者的架构设计、技术选型说明请查看 `HELP.md`。
