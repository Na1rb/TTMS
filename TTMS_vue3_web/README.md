# TTMS 票务管理系统 - Vue3 前端

## 技术栈

- Vue 3（Composition API + `<script setup>`）
- Vite
- Vue Router
- Pinia
- Axios
- ECharts

---

## 环境要求

- Node.js >= 20.19 或 >= 22.12
- npm >= 10

---

## 本地开发启动

```bash
npm install
npm run dev
```

浏览器访问：

```text
http://localhost:5173
```

当前 Vite 代理配置位于 `vite.config.js`，会把：

```text
/rest
```

转发到：

```text
http://localhost:8080
```

因此前后端本地联调时，需要先启动后端。

---

## Docker 运行说明

前端 Docker 镜像采用：

- Node.js 构建
- Nginx 提供静态资源服务

容器启动后默认通过 Nginx 对外提供：

```text
http://localhost
```

并把 `/rest/` 反向代理到：

```text
http://backend:8080/rest/
```

相关配置文件：

- `Dockerfile`
- `nginx.conf`

---

## 页面与路由

当前前端路由定义以 `src/router/index.js` 为准。

| 路由 | 页面 | 允许角色 |
|------|------|------|
| `/login` | 登录页 | 所有用户 |
| `/` | 首页 | 所有已登录用户 |
| `/profile` | 个人中心 | 所有已登录用户 |
| `/employees` | 用户管理 | 管理员 `3` |
| `/studios` | 演出厅管理 | 管理员 `3` |
| `/plays` | 剧目管理 | 经理 `1` |
| `/schedules` | 排片管理 | 经理 `1` |
| `/seats` | 座位管理 | 经理 `1` |
| `/dictionary` | 字典管理 | 经理 `1` |
| `/analysis` | 销售分析 | 经理 `1` |
| `/sell` | 购票 | VIP `4`、普通用户 `5` |
| `/return-ticket` | 退票 | 售票员 `2`、VIP `4` |
| `/unhandled` | 未处理订单 | 售票员 `2` |

---

## 当前菜单显示规则

侧边栏菜单定义在 `src/views/Layout.vue`。

### 管理员 `emp_type=3`

显示：

- 用户管理
- 演出厅管理

### 经理 `emp_type=1`

显示：

- 剧目管理
- 排片管理
- 座位管理
- 字典管理
- 销售分析

### 售票员 `emp_type=2`

显示：

- 退票
- 未处理订单

### VIP `emp_type=4`

显示：

- 购票
- 退票

### 普通用户 `emp_type=5`

显示：

- 购票

---

## 当前前后端权限差异

这里要特别注意：

虽然前端路由和菜单允许：

- 售票员进入 `/return-ticket`

但后端当前实际限制订单相关操作只允许：

- VIP `4`
- 普通用户 `5`

因此当前实际效果是：

- `vip01`：可购票，可走退票页流程
- `user01`：可购票
- `seller01`：可打开退票页，但提交订单类操作时可能被后端拦截

如果你只是做前端展示或联调验收，需要按这个现状理解，而不是按理想业务理解。

---

## 登录说明

登录接口：

```text
POST /rest/login
```

前端通过 `src/api/http.js` 把请求发送到：

```text
baseURL: /rest
```

登录使用的是：

- 用户名：`employee.emp_name`
- 密码：明文密码

当前初始化测试账号：

| 角色 | 用户名 | 密码 |
|------|------|------|
| 管理员 | `admin` | `admin123` |
| 经理 | `manager` | `123456` |
| 售票员 | `seller01` | `123456` |
| VIP | `vip01` | `123456` |
| 普通用户 | `user01` | `123456` |

---

## 项目结构

```text
src/
├── api/           # Axios 实例 + 接口封装
├── assets/        # 样式与静态资源
├── config/        # 系统常量
├── router/        # 路由与权限守卫
├── stores/        # Pinia 状态管理
├── views/         # 页面组件
├── App.vue
└── main.js
```

---

## 主要接口封装位置

接口封装文件：

- `src/api/http.js`
- `src/api/ttms.js`

主要模块包括：

- `authApi`
- `employeeApi`
- `studioApi`
- `playApi`
- `scheduleApi`
- `ticketApi`
- `saleApi`
- `dictionaryApi`
- `seatApi`
- `orderApi`
- `salesApi`
- `profileApi`

---

## 联调建议

推荐联调顺序：

1. 先启动后端
2. 再启动前端
3. 先用 `admin` 登录验证会话
4. 再按角色验证路由守卫和菜单显示
5. 最后验证购票、退票、分析等复杂流程

如果你需要更完整的业务操作说明，请查看项目根目录：

- `README.md`
- `操作流程.md`
