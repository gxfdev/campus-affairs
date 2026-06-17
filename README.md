# 校园事务管理系统 (Campus Affairs Management System)

一个基于 Spring Boot 3 + Vue 3 的校园事务管理系统，提供学生请假、宿舍报修、公告管理、活动报名等功能。采用前后端分离架构，使用 JWT 进行身份认证。

## 技术栈

| 层级 | 技术 |
|------|------|
| 前端 | Vue 3.4 + Element Plus 2.5 + Vite 5 + Pinia + Axios + ECharts |
| 后端 | Spring Boot 3.2.0 + MyBatis-Plus 3.5.5 + JWT |
| 数据库 | MySQL 8.0 |
| 容器化 | Docker + Docker Compose |

## 功能模块

- **用户管理** - 注册/登录、JWT认证、角色权限控制（管理员/教师/学生）
- **请假管理** - 学生提交请假、教师/管理员审批、请假统计
- **报修管理** - 学生提交报修、管理员处理、状态跟踪、报修统计
- **公告管理** - 发布公告、分类管理、浏览统计、置顶功能
- **活动管理** - 发布活动、学生报名、人数限制、活动状态管理

## 项目结构

```
├── 001-backend/                # 后端 (Spring Boot)
│   ├── src/main/java/com/xiaou/
│   │   ├── controller/         # 控制器层
│   │   ├── service/            # 业务逻辑层
│   │   ├── mapper/             # 数据访问层
│   │   ├── entity/             # 实体类
│   │   ├── config/             # 配置类 (JWT/CORS/MyBatis)
│   │   ├── common/             # 通用类 (Result/Exception)
│   │   └── utils/              # 工具类 (JwtUtil)
│   ├── src/main/resources/
│   │   ├── application.yml     # 应用配置
│   │   └── sql/init.sql        # 数据库初始化脚本
│   ├── Dockerfile
│   └── pom.xml
├── 001-frontend/               # 前端 (Vue 3)
│   ├── src/
│   │   ├── api/                # API 请求
│   │   ├── views/              # 页面组件
│   │   ├── layout/             # 布局组件
│   │   ├── router/             # 路由配置
│   │   ├── stores/             # 状态管理
│   │   └── utils/              # 工具函数
│   ├── nginx.conf              # Nginx 配置 (Docker 部署用)
│   ├── Dockerfile
│   └── package.json
├── docker-compose.yml          # Docker Compose 编排
└── README.md
```

## 快速开始

### 方式一：本地开发

**环境要求：** JDK 17+、MySQL 8.0+、Maven 3.6+、Node.js 18+

1. **初始化数据库**
   ```bash
   mysql -u root -p --default-character-set=utf8mb4 < 001-backend/src/main/resources/sql/init.sql
   ```

2. **修改数据库配置**（如需要）

   编辑 `001-backend/src/main/resources/application.yml`，修改数据库用户名和密码：
   ```yaml
   spring:
     datasource:
       username: root
       password: 123456
   ```

3. **启动后端**
   ```bash
   cd 001-backend
   mvn spring-boot:run
   ```
   后端启动在 http://localhost:8088

4. **启动前端**
   ```bash
   cd 001-frontend
   npm install
   npm run dev
   ```
   前端启动在 http://localhost:3000

### 方式二：Docker 部署

**环境要求：** Docker + Docker Compose

```bash
# 一键启动所有服务（MySQL + 后端 + 前端）
docker-compose up -d

# 查看日志
docker-compose logs -f
```

- 前端访问：http://localhost:80
- 后端 API：http://localhost:8088
- MySQL 端口：3307（外部访问）

### 默认账号

| 角色 | 用户名 | 密码 |
|------|--------|------|
| 管理员 | admin | admin123 |
| 教师 | teacher001 | teacher123 |
| 学生 | student001 | student123 |

## API 接口

### 认证接口
- `POST /api/auth/login` - 用户登录
- `POST /api/auth/register` - 用户注册
- `GET /api/auth/userinfo` - 获取当前用户信息

### 请假管理
- `POST /api/leave/apply` - 提交请假申请
- `GET /api/leave/list` - 请假列表
- `POST /api/leave/approve` - 审批请假

### 报修管理
- `POST /api/repair/submit` - 提交报修
- `GET /api/repair/list` - 报修列表
- `POST /api/repair/handle` - 处理报修

### 公告管理
- `POST /api/notice/add` - 发布公告
- `GET /api/notice/list` - 公告列表
- `GET /api/notice/{id}` - 公告详情

### 活动管理
- `POST /api/activity/add` - 发布活动
- `GET /api/activity/list` - 活动列表
- `POST /api/activity/signup` - 报名活动

## 权限说明

- **学生** - 提交请假/报修申请，查看公告，报名活动
- **教师** - 审批请假，发布公告/活动
- **管理员** - 所有权限，用户管理，报修处理，数据统计

## 许可证

MIT License
