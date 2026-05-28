# 制作小组

## 成员分工

| 姓名 | 角色 | 负责模块 | 涉及文件 |
|------|------|---------|---------|
| 组长 | 组长、后端开发 | Spring MVC 控制器、Service 层、REST API | `AnalysisRestController.java`、`ScheduleRestController.java`、`ScheduleServiceImpl.java`、`PlayServiceImpl.java` |
| 组员A | 后端开发、数据库 | MyBatis DAO 层、数据库表设计、数据字典 | `EmployeeDAO.java`、`SaleDAO.java`、`TicketDAO.java`、`DataDictionaryServiceImpl.java` |
| 组员B | 前端开发（核心页面） | 售票退票、剧目管理、排片管理页面 | `SellTickets.vue`、`Plays.vue`、`Schedules.vue`、`Login.vue` |
| 组员C | 前端开发（管理页面） | 用户管理、演出厅管理、座位管理、字典管理页面 | `Employees.vue`、`Studios.vue`、`Seats.vue`、`Dictionary.vue` |
| 组员D | 前端开发（数据与图表） | API 封装、状态管理、销售分析图表、个人中心 | `ttms.js`、`user.js`、`SalesAnalysis.vue`、`Profile.vue`、`PendingOrders.vue` |
| 组员E | 前端配置、文档测试 | 路由配置、首页、布局样式、接口测试、文档编写 | `router/index.js`、`Layout.vue`、`Home.vue`、`style.css`、`README.md` |

## 项目结构总览

```
TTMS_C-S_group1/
├── TTMS_Server/                          # 后端（Spring MVC + MyBatis）
│   ├── src/main/java/TTMS_Server/
│   │   ├── config/                       # Spring 配置（组长）
│   │   ├── dao/                          # MyBatis DAO（组员A）
│   │   ├── model/                        # 实体类（组长 + 组员A）
│   │   ├── service/                      # 服务接口（组长）
│   │   ├── serviceimpl/                  # 服务实现（组长）
│   │   ├── web/RESTful/                  # REST 控制器（组长）
│   │   └── utils/                        # 工具类（组长）
│   └── src/test/java/                    # 测试（组员E）
│
├── TTMS_vue3_web/                        # 前端（Vue3）
│   ├── src/
│   │   ├── api/                          # Axios + API 定义（组员D）
│   │   ├── config/                       # 系统常量（组员E）
│   │   ├── router/                       # 路由配置（组员E）
│   │   ├── stores/                       # Pinia 状态管理（组员D）
│   │   ├── views/                        # 页面组件（组员B + 组员C）
│   │   ├── assets/                       # 样式资源（组员E）
│   │   └── main.js                       # 入口（组员E）
│   ├── index.html                        # 入口 HTML（组员E）
│   └── README.md                         # 项目文档（组员E）
│
├── TTMS_client/                          # JavaFX 客户端（C/S 原版）
└── README.md                             # 根目录文档（组员E）
```

## 致谢

感谢小组成员的共同努力，以及指导老师的帮助与支持。
