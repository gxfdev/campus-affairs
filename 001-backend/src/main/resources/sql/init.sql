-- 校园事务管理系统数据库初始化脚本

SET SQL_MODE = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- 创建数据库
CREATE DATABASE IF NOT EXISTS campus_affairs DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE campus_affairs;

-- 用户表（扩展：增加班级、年级、学院字段）
CREATE TABLE IF NOT EXISTS `user` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `password` varchar(100) NOT NULL COMMENT '密码（MD5加密）',
  `role` varchar(20) NOT NULL DEFAULT 'student' COMMENT '角色（admin/teacher/student）',
  `real_name` varchar(50) DEFAULT NULL COMMENT '真实姓名',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像地址',
  `student_no` varchar(50) DEFAULT NULL COMMENT '学号/工号',
  `class_name` varchar(50) DEFAULT NULL COMMENT '班级名称',
  `grade` int DEFAULT NULL COMMENT '年级（1-4对应大一到大四）',
  `college` varchar(100) DEFAULT NULL COMMENT '学院',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除（0-未删除，1-已删除）',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  KEY `idx_role` (`role`),
  KEY `idx_class_name` (`class_name`),
  KEY `idx_grade` (`grade`),
  KEY `idx_college` (`college`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 请假申请表
CREATE TABLE IF NOT EXISTS `leave_request` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `student_id` bigint NOT NULL COMMENT '学生ID',
  `reason` varchar(500) NOT NULL COMMENT '请假理由',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `end_time` datetime NOT NULL COMMENT '结束时间',
  `days` int NOT NULL DEFAULT '1' COMMENT '请假天数',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '状态（0-待审批，1-已通过，2-已驳回）',
  `approver_id` bigint DEFAULT NULL COMMENT '审批人ID',
  `approval_comment` varchar(500) DEFAULT NULL COMMENT '审批意见',
  `approval_time` datetime DEFAULT NULL COMMENT '审批时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`id`),
  KEY `idx_student_id` (`student_id`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='请假申请表';

-- 报修申请表
CREATE TABLE IF NOT EXISTS `repair_request` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `student_id` bigint NOT NULL COMMENT '学生ID',
  `type` varchar(50) NOT NULL COMMENT '报修类型（电器/水管/门窗/其他）',
  `location` varchar(200) NOT NULL COMMENT '报修位置',
  `description` varchar(1000) NOT NULL COMMENT '报修说明',
  `image_url` varchar(1000) DEFAULT NULL COMMENT '图片地址（多张用逗号分隔）',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '状态（0-未处理，1-处理中，2-已完成）',
  `handler_id` bigint DEFAULT NULL COMMENT '处理人ID',
  `handle_comment` varchar(500) DEFAULT NULL COMMENT '处理备注',
  `handle_time` datetime DEFAULT NULL COMMENT '处理时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`id`),
  KEY `idx_student_id` (`student_id`),
  KEY `idx_status` (`status`),
  KEY `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='报修申请表';

-- 公告表
CREATE TABLE IF NOT EXISTS `notice` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `title` varchar(200) NOT NULL COMMENT '标题',
  `content` text NOT NULL COMMENT '内容',
  `category` varchar(50) NOT NULL DEFAULT '通知' COMMENT '分类（通知/活动/系统）',
  `author_id` bigint NOT NULL COMMENT '发布者ID',
  `is_top` tinyint NOT NULL DEFAULT '0' COMMENT '是否置顶（0-否，1-是）',
  `view_count` int NOT NULL DEFAULT '0' COMMENT '浏览次数',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`id`),
  KEY `idx_author_id` (`author_id`),
  KEY `idx_category` (`category`),
  KEY `idx_is_top` (`is_top`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='公告表';

-- 活动表
CREATE TABLE IF NOT EXISTS `activity` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `title` varchar(200) NOT NULL COMMENT '活动标题',
  `description` text NOT NULL COMMENT '活动描述',
  `location` varchar(200) NOT NULL COMMENT '活动地点',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `end_time` datetime NOT NULL COMMENT '结束时间',
  `max_participants` int NOT NULL DEFAULT '100' COMMENT '人数限制',
  `current_participants` int NOT NULL DEFAULT '0' COMMENT '当前报名人数',
  `cover_image` varchar(500) DEFAULT NULL COMMENT '活动封面图',
  `organizer_id` bigint NOT NULL COMMENT '组织者ID',
  `status` varchar(20) NOT NULL DEFAULT 'pending' COMMENT '活动状态（pending/upcoming/ended）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`id`),
  KEY `idx_organizer_id` (`organizer_id`),
  KEY `idx_status` (`status`),
  KEY `idx_start_time` (`start_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='活动表';

-- 活动报名表
CREATE TABLE IF NOT EXISTS `activity_signup` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `activity_id` bigint NOT NULL COMMENT '活动ID',
  `student_id` bigint NOT NULL COMMENT '学生ID',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '报名状态（0-待审核，1-已通过，2-已取消）',
  `remark` varchar(500) DEFAULT NULL COMMENT '报名备注',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_activity_student` (`activity_id`,`student_id`),
  KEY `idx_student_id` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='活动报名表';

-- 辅导员表
CREATE TABLE IF NOT EXISTS `counselor` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '关联用户ID',
  `college` varchar(100) NOT NULL COMMENT '负责学院',
  `grade` int NOT NULL COMMENT '负责年级（1-4对应大一到大四）',
  `description` varchar(500) DEFAULT NULL COMMENT '简介',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_college` (`college`),
  KEY `idx_grade` (`grade`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='辅导员表';

-- 课程表
CREATE TABLE IF NOT EXISTS `course_schedule` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `class_name` varchar(50) NOT NULL COMMENT '班级名称',
  `course_name` varchar(100) NOT NULL COMMENT '课程名称',
  `teacher_name` varchar(50) NOT NULL COMMENT '授课教师',
  `location` varchar(100) NOT NULL COMMENT '上课地点',
  `day_of_week` tinyint NOT NULL COMMENT '星期几（1-7对应周一到周日）',
  `period_start` tinyint NOT NULL COMMENT '开始节次',
  `period_end` tinyint NOT NULL COMMENT '结束节次',
  `semester` varchar(20) NOT NULL COMMENT '学期（如2025-2026-1）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`id`),
  KEY `idx_class_name` (`class_name`),
  KEY `idx_semester` (`semester`),
  KEY `idx_day_of_week` (`day_of_week`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='课程表';

-- 成绩表
CREATE TABLE IF NOT EXISTS `score` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `student_id` bigint NOT NULL COMMENT '学生ID',
  `course_name` varchar(100) NOT NULL COMMENT '课程名称',
  `course_type` varchar(20) NOT NULL DEFAULT 'required' COMMENT '课程类型（required/optional/pe）',
  `score` decimal(5,1) DEFAULT NULL COMMENT '成绩',
  `credit` decimal(3,1) NOT NULL COMMENT '学分',
  `semester` varchar(20) NOT NULL COMMENT '学期',
  `class_name` varchar(50) DEFAULT NULL COMMENT '班级',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`id`),
  KEY `idx_student_id` (`student_id`),
  KEY `idx_semester` (`semester`),
  KEY `idx_course_type` (`course_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='成绩表';

-- 选课表（公选课/体育课）
CREATE TABLE IF NOT EXISTS `course_selection` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `course_name` varchar(100) NOT NULL COMMENT '课程名称',
  `course_type` varchar(20) NOT NULL COMMENT '课程类型（optional公选课/pe体育课）',
  `teacher_name` varchar(50) NOT NULL COMMENT '授课教师',
  `location` varchar(100) DEFAULT NULL COMMENT '上课地点',
  `max_students` int NOT NULL DEFAULT '100' COMMENT '最大选课人数',
  `current_students` int NOT NULL DEFAULT '0' COMMENT '当前选课人数',
  `credit` decimal(3,1) NOT NULL DEFAULT '1.0' COMMENT '学分',
  `semester` varchar(20) NOT NULL COMMENT '学期',
  `day_of_week` tinyint DEFAULT NULL COMMENT '星期几',
  `period_start` tinyint DEFAULT NULL COMMENT '开始节次',
  `period_end` tinyint DEFAULT NULL COMMENT '结束节次',
  `status` varchar(20) NOT NULL DEFAULT 'open' COMMENT '选课状态（open/closed/full）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`id`),
  KEY `idx_course_type` (`course_type`),
  KEY `idx_semester` (`semester`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='选课表';

-- 学生选课记录表
CREATE TABLE IF NOT EXISTS `course_selection_record` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `course_id` bigint NOT NULL COMMENT '选课ID',
  `student_id` bigint NOT NULL COMMENT '学生ID',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态（1-已选，0-已退）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_course_student` (`course_id`,`student_id`),
  KEY `idx_student_id` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学生选课记录表';

-- 宿舍表
CREATE TABLE IF NOT EXISTS `dormitory` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `building` varchar(20) NOT NULL COMMENT '楼栋号',
  `room_number` varchar(20) NOT NULL COMMENT '房间号',
  `capacity` tinyint NOT NULL DEFAULT '4' COMMENT '容纳人数',
  `current_count` tinyint NOT NULL DEFAULT '0' COMMENT '当前入住人数',
  `gender` varchar(4) NOT NULL COMMENT '性别限制（男/女）',
  `status` varchar(20) NOT NULL DEFAULT 'available' COMMENT '状态（available/full/maintenance）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_building_room` (`building`,`room_number`),
  KEY `idx_status` (`status`),
  KEY `idx_gender` (`gender`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='宿舍表';

-- 宿舍选择记录表
CREATE TABLE IF NOT EXISTS `dormitory_selection` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `dormitory_id` bigint NOT NULL COMMENT '宿舍ID',
  `student_id` bigint NOT NULL COMMENT '学生ID',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态（1-已选，0-已退）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_student` (`student_id`),
  KEY `idx_dormitory_id` (`dormitory_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='宿舍选择记录表';

-- 通知消息表
CREATE TABLE IF NOT EXISTS `notification` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '接收用户ID',
  `title` varchar(200) NOT NULL COMMENT '通知标题',
  `content` varchar(500) DEFAULT NULL COMMENT '通知内容',
  `type` varchar(20) NOT NULL DEFAULT 'system' COMMENT '类型（system/leave/repair/activity）',
  `is_read` tinyint NOT NULL DEFAULT '0' COMMENT '是否已读（0-未读，1-已读）',
  `related_id` bigint DEFAULT NULL COMMENT '关联业务ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `deleted` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_is_read` (`is_read`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='通知消息表';

-- 初始化默认数据
INSERT INTO `user` (`username`, `password`, `role`, `real_name`, `phone`, `email`, `student_no`, `class_name`, `grade`, `college`) VALUES
-- 默认管理员 (密码: admin123)
('admin', '0192023a7bbd73250516f069df18b500', 'admin', '系统管理员', '13800000000', 'admin@campus.edu', 'ADMIN001', NULL, NULL, NULL),
-- 默认教师 (密码: teacher123)
('teacher001', 'a426dcf72ba25d046591f81a5495eab7', 'teacher', '张老师', '13800000001', 'zhang@campus.edu', 'T001', NULL, NULL, '计算机学院'),
-- 默认学生 (密码: student123)
('student001', 'ad6a280417a0f533d8b670c61667e1a0', 'student', '李小明', '13800000002', 'li@campus.edu', '2024001', '计科2401', 1, '计算机学院'),
('student002', 'ad6a280417a0f533d8b670c61667e1a0', 'student', '王小红', '13800000003', 'wang@campus.edu', '2024002', '计科2401', 1, '计算机学院'),
('student003', 'ad6a280417a0f533d8b670c61667e1a0', 'student', '赵大力', '13800000004', 'zhao@campus.edu', '2023001', '计科2301', 2, '计算机学院'),
('student004', 'ad6a280417a0f533d8b670c61667e1a0', 'student', '刘小芳', '13800000005', 'liu@campus.edu', '2022001', '计科2201', 3, '计算机学院'),
('student005', 'ad6a280417a0f533d8b670c61667e1a0', 'student', '陈大伟', '13800000006', 'chen@campus.edu', '2021001', '计科2101', 4, '计算机学院');

-- 辅导员数据
INSERT INTO `counselor` (`user_id`, `college`, `grade`, `description`) VALUES
(2, '计算机学院', 1, '负责计算机学院大一学生'),
(2, '计算机学院', 2, '负责计算机学院大二学生');

-- 示例课程表数据
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('计科2401', '高等数学', '王教授', '教学楼A101', 1, 1, 2, '2025-2026-1'),
('计科2401', '大学英语', '李老师', '教学楼B203', 1, 3, 4, '2025-2026-1'),
('计科2401', 'C语言程序设计', '张老师', '实验楼C301', 2, 1, 2, '2025-2026-1'),
('计科2401', '线性代数', '刘教授', '教学楼A102', 3, 1, 2, '2025-2026-1'),
('计科2401', '大学物理', '陈教授', '教学楼A201', 3, 3, 4, '2025-2026-1'),
('计科2401', '思想政治', '赵老师', '教学楼B101', 4, 1, 2, '2025-2026-1'),
('计科2401', '体育', '孙老师', '体育馆', 4, 3, 4, '2025-2026-1'),
('计科2401', '大学英语', '李老师', '教学楼B203', 5, 1, 2, '2025-2026-1'),
('计科2301', '数据结构', '周教授', '教学楼A301', 1, 1, 2, '2025-2026-1'),
('计科2301', '操作系统', '吴教授', '教学楼A302', 2, 3, 4, '2025-2026-1'),
('计科2301', '计算机网络', '郑老师', '实验楼C201', 3, 1, 2, '2025-2026-1'),
('计科2301', '数据库原理', '张老师', '实验楼C302', 4, 1, 2, '2025-2026-1');

-- 示例成绩数据
INSERT INTO `score` (`student_id`, `course_name`, `course_type`, `score`, `credit`, `semester`, `class_name`) VALUES
(3, '高等数学', 'required', 85.0, 4.0, '2024-2025-2', '计科2401'),
(3, '大学英语', 'required', 78.5, 3.0, '2024-2025-2', '计科2401'),
(3, 'C语言程序设计', 'required', 92.0, 3.0, '2024-2025-2', '计科2401'),
(3, '线性代数', 'required', 80.0, 3.0, '2024-2025-2', '计科2401'),
(4, '高等数学', 'required', 76.0, 4.0, '2024-2025-2', '计科2401'),
(4, '大学英语', 'required', 88.0, 3.0, '2024-2025-2', '计科2401'),
(4, 'C语言程序设计', 'required', 85.5, 3.0, '2024-2025-2', '计科2401');

-- 示例选课数据
INSERT INTO `course_selection` (`course_name`, `course_type`, `teacher_name`, `location`, `max_students`, `current_students`, `credit`, `semester`, `day_of_week`, `period_start`, `period_end`, `status`) VALUES
('艺术鉴赏', 'optional', '马老师', '艺术楼A101', 120, 45, 2.0, '2025-2026-1', 2, 5, 6, 'open'),
('心理学导论', 'optional', '杨老师', '教学楼D201', 100, 78, 2.0, '2025-2026-1', 3, 5, 6, 'open'),
('创业基础', 'optional', '黄老师', '教学楼D301', 80, 80, 1.0, '2025-2026-1', 5, 5, 6, 'full'),
('篮球', 'pe', '孙老师', '体育馆', 40, 32, 1.0, '2025-2026-1', 1, 5, 6, 'open'),
('羽毛球', 'pe', '周老师', '体育馆', 35, 35, 1.0, '2025-2026-1', 2, 5, 6, 'full'),
('乒乓球', 'pe', '吴老师', '体育馆', 30, 18, 1.0, '2025-2026-1', 3, 5, 6, 'open'),
('瑜伽', 'pe', '李老师', '体操房', 25, 20, 1.0, '2025-2026-1', 4, 5, 6, 'open');

-- 示例宿舍数据
INSERT INTO `dormitory` (`building`, `room_number`, `capacity`, `current_count`, `gender`, `status`) VALUES
('1号楼', '101', 4, 2, '男', 'available'),
('1号楼', '102', 4, 4, '男', 'full'),
('1号楼', '103', 4, 1, '男', 'available'),
('2号楼', '201', 4, 3, '女', 'available'),
('2号楼', '202', 4, 4, '女', 'full'),
('2号楼', '203', 4, 0, '女', 'available');

-- 示例通知数据
INSERT INTO `notification` (`user_id`, `title`, `content`, `type`, `is_read`, `related_id`) VALUES
(3, '请假申请已通过', '您的请假申请已被审批通过', 'leave', 0, NULL),
(3, '报修处理通知', '您的报修申请已开始处理', 'repair', 0, NULL),
(4, '活动报名成功', '您已成功报名春季运动会', 'activity', 0, NULL);

-- 插入示例公告数据
INSERT INTO `notice` (`title`, `content`, `category`, `author_id`, `is_top`) VALUES
('欢迎使用校园事务管理系统', '本系统为学生、教师提供便捷的校园事务管理服务，包括请假申请、报修申请、公告查看、活动报名等功能。', '系统', 1, 1),
('校园网络维护通知', '定于本周末进行校园网络设备维护，届时网络可能出现短暂中断，请提前做好准备。', '通知', 1, 0);

-- 插入示例活动数据
INSERT INTO `activity` (`title`, `description`, `location`, `start_time`, `end_time`, `max_participants`, `organizer_id`, `status`) VALUES
('春季运动会', '学校一年一度的春季运动会，欢迎全校师生参加。设有田径、球类等多个项目。', '校体育场', '2024-04-15 09:00:00', '2024-04-15 17:00:00', 200, 2, 'pending'),
('编程竞赛', '面向全校学生的编程竞赛，设有个人赛和团队赛，获奖者将获得丰厚奖品。', '计算机学院机房', '2024-04-20 14:00:00', '2024-04-20 18:00:00', 50, 2, 'pending');
