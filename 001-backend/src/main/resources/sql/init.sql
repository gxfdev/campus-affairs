-- 校园事务管理系统数据库初始化脚本（完整版）
-- 5个学院、12个专业、每专业每届1-2个班、每届每学院1个辅导员
-- 真实课程表、成绩、宿舍、选课数据

SET SQL_MODE = 'NO_ENGINE_SUBSTITUTION';
SET NAMES utf8mb4;

CREATE DATABASE IF NOT EXISTS campus_affairs DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE campus_affairs;

-- ==================== 用户表 ====================
CREATE TABLE IF NOT EXISTS `user` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(100) NOT NULL,
  `role` varchar(20) NOT NULL DEFAULT 'student' COMMENT 'admin/counselor/teacher/student',
  `real_name` varchar(50) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `student_no` varchar(50) DEFAULT NULL,
  `class_name` varchar(50) DEFAULT NULL,
  `grade` int DEFAULT NULL COMMENT '1-4对应大一到大四',
  `college` varchar(100) DEFAULT NULL,
  `major` varchar(100) DEFAULT NULL,
  `gender` varchar(4) DEFAULT NULL,
  `counselor_id` bigint DEFAULT NULL COMMENT '专属辅导员ID',
  `enrollment_year` int DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  KEY `idx_role` (`role`),
  KEY `idx_class_name` (`class_name`),
  KEY `idx_college` (`college`),
  KEY `idx_counselor_id` (`counselor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 请假、报修、公告、活动、活动报名表（保持不变）
CREATE TABLE IF NOT EXISTS `leave_request` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` bigint NOT NULL,
  `reason` varchar(500) NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `days` int NOT NULL DEFAULT '1',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '0-待审批 1-已通过 2-已驳回',
  `approver_id` bigint DEFAULT NULL COMMENT '审批人（辅导员）',
  `approval_comment` varchar(500) DEFAULT NULL,
  `approval_time` datetime DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_student_id` (`student_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `repair_request` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` bigint NOT NULL,
  `type` varchar(50) NOT NULL,
  `location` varchar(200) NOT NULL,
  `description` varchar(1000) NOT NULL,
  `image_url` varchar(1000) DEFAULT NULL,
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '0-未处理 1-处理中 2-已完成',
  `handler_id` bigint DEFAULT NULL COMMENT '处理人（管理员）',
  `handle_comment` varchar(500) DEFAULT NULL,
  `handle_time` datetime DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_student_id` (`student_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `notice` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL,
  `content` text NOT NULL,
  `category` varchar(50) NOT NULL DEFAULT '通知',
  `author_id` bigint NOT NULL,
  `is_top` tinyint NOT NULL DEFAULT '0',
  `view_count` int NOT NULL DEFAULT '0',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `activity` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL,
  `description` text NOT NULL,
  `location` varchar(200) NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `max_participants` int NOT NULL DEFAULT '100',
  `current_participants` int NOT NULL DEFAULT '0',
  `cover_image` varchar(500) DEFAULT NULL,
  `organizer_id` bigint NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'pending',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `activity_signup` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `activity_id` bigint NOT NULL,
  `student_id` bigint NOT NULL,
  `status` tinyint NOT NULL DEFAULT '1',
  `remark` varchar(500) DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_activity_student` (`activity_id`,`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 辅导员表
CREATE TABLE IF NOT EXISTS `counselor` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `college` varchar(100) NOT NULL,
  `grade` int NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_college_grade` (`college`,`grade`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 课程表
CREATE TABLE IF NOT EXISTS `course_schedule` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `class_name` varchar(50) NOT NULL,
  `course_name` varchar(100) NOT NULL,
  `teacher_name` varchar(50) NOT NULL,
  `location` varchar(100) NOT NULL,
  `day_of_week` tinyint NOT NULL COMMENT '1-5',
  `period_start` tinyint NOT NULL,
  `period_end` tinyint NOT NULL,
  `semester` varchar(20) NOT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_class_semester` (`class_name`,`semester`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 成绩表
CREATE TABLE IF NOT EXISTS `score` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` bigint NOT NULL,
  `course_name` varchar(100) NOT NULL,
  `course_type` varchar(20) NOT NULL DEFAULT 'required',
  `score` decimal(5,1) DEFAULT NULL,
  `credit` decimal(3,1) NOT NULL,
  `semester` varchar(20) NOT NULL,
  `class_name` varchar(50) DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_student_id` (`student_id`),
  KEY `idx_semester` (`semester`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 选课表（增加辅导员控制字段）
CREATE TABLE IF NOT EXISTS `course_selection` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `course_name` varchar(100) NOT NULL,
  `course_type` varchar(20) NOT NULL COMMENT 'optional/pe',
  `teacher_name` varchar(50) NOT NULL,
  `location` varchar(100) DEFAULT NULL,
  `max_students` int NOT NULL DEFAULT '100',
  `current_students` int NOT NULL DEFAULT '0',
  `credit` decimal(3,1) NOT NULL DEFAULT '1.0',
  `semester` varchar(20) NOT NULL,
  `day_of_week` tinyint DEFAULT NULL,
  `period_start` tinyint DEFAULT NULL,
  `period_end` tinyint DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'open' COMMENT 'open/closed/full',
  `college` varchar(100) DEFAULT NULL COMMENT '开放学院',
  `grade` int DEFAULT NULL COMMENT '开放年级',
  `is_open` tinyint NOT NULL DEFAULT '0' COMMENT '0-未开放 1-已开放',
  `opened_by` bigint DEFAULT NULL COMMENT '开放选课的辅导员ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_course_type` (`course_type`),
  KEY `idx_semester` (`semester`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `course_selection_record` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `course_id` bigint NOT NULL,
  `student_id` bigint NOT NULL,
  `status` tinyint NOT NULL DEFAULT '1',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_course_student` (`course_id`,`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 宿舍表（增加学院字段）
CREATE TABLE IF NOT EXISTS `dormitory` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `building` varchar(20) NOT NULL,
  `room_number` varchar(20) NOT NULL,
  `capacity` tinyint NOT NULL DEFAULT '4',
  `current_count` tinyint NOT NULL DEFAULT '0',
  `gender` varchar(4) NOT NULL,
  `college` varchar(100) DEFAULT NULL COMMENT '所属学院',
  `status` varchar(20) NOT NULL DEFAULT 'available',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_building_room` (`building`,`room_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `dormitory_selection` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `dormitory_id` bigint NOT NULL,
  `student_id` bigint NOT NULL,
  `status` tinyint NOT NULL DEFAULT '1',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_student` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `notification` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `title` varchar(200) NOT NULL,
  `content` varchar(500) DEFAULT NULL,
  `type` varchar(20) NOT NULL DEFAULT 'system',
  `is_read` tinyint NOT NULL DEFAULT '0',
  `related_id` bigint DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 数据初始化
-- ============================================================

-- 1. 管理员 (密码: admin123)
INSERT INTO `user` (`username`, `password`, `role`, `real_name`, `phone`, `email`, `student_no`, `gender`) VALUES
('admin', '0192023a7bbd73250516f069df18b500', 'admin', '系统管理员', '13800000000', 'admin@campus.edu', 'ADMIN001', '男');

-- 2. 辅导员（5学院×4届=20个，密码: admin123）
INSERT INTO `user` (`username`, `password`, `role`, `real_name`, `phone`, `email`, `student_no`, `college`, `grade`, `gender`) VALUES
('counselor_cs_24', '0192023a7bbd73250516f069df18b500', 'counselor', '24级计算机学院辅导员', '13901010001', 'cs24@campus.edu', 'CS24C001', '计算机学院', 1, '男'),
('counselor_cs_23', '0192023a7bbd73250516f069df18b500', 'counselor', '23级计算机学院辅导员', '13901010002', 'cs23@campus.edu', 'CS23C001', '计算机学院', 2, '女'),
('counselor_cs_22', '0192023a7bbd73250516f069df18b500', 'counselor', '22级计算机学院辅导员', '13901010003', 'cs22@campus.edu', 'CS22C001', '计算机学院', 3, '男'),
('counselor_cs_21', '0192023a7bbd73250516f069df18b500', 'counselor', '21级计算机学院辅导员', '13901010004', 'cs21@campus.edu', 'CS21C001', '计算机学院', 4, '女'),
('counselor_em_24', '0192023a7bbd73250516f069df18b500', 'counselor', '24级经管学院辅导员', '13902010001', 'em24@campus.edu', 'EM24C001', '经济管理学院', 1, '女'),
('counselor_em_23', '0192023a7bbd73250516f069df18b500', 'counselor', '23级经管学院辅导员', '13902010002', 'em23@campus.edu', 'EM23C001', '经济管理学院', 2, '男'),
('counselor_em_22', '0192023a7bbd73250516f069df18b500', 'counselor', '22级经管学院辅导员', '13902010003', 'em22@campus.edu', 'EM22C001', '经济管理学院', 3, '女'),
('counselor_em_21', '0192023a7bbd73250516f069df18b500', 'counselor', '21级经管学院辅导员', '13902010004', 'em21@campus.edu', 'EM21C001', '经济管理学院', 4, '男'),
('counselor_fl_24', '0192023a7bbd73250516f069df18b500', 'counselor', '24级外国语学院辅导员', '13903010001', 'fl24@campus.edu', 'FL24C001', '外国语学院', 1, '女'),
('counselor_fl_23', '0192023a7bbd73250516f069df18b500', 'counselor', '23级外国语学院辅导员', '13903010002', 'fl23@campus.edu', 'FL23C001', '外国语学院', 2, '女'),
('counselor_fl_22', '0192023a7bbd73250516f069df18b500', 'counselor', '22级外国语学院辅导员', '13903010003', 'fl22@campus.edu', 'FL22C001', '外国语学院', 3, '男'),
('counselor_fl_21', '0192023a7bbd73250516f069df18b500', 'counselor', '21级外国语学院辅导员', '13903010004', 'fl21@campus.edu', 'FL21C001', '外国语学院', 4, '女'),
('counselor_ce_24', '0192023a7bbd73250516f069df18b500', 'counselor', '24级土木学院辅导员', '13904010001', 'ce24@campus.edu', 'CE24C001', '土木工程学院', 1, '男'),
('counselor_ce_23', '0192023a7bbd73250516f069df18b500', 'counselor', '23级土木学院辅导员', '13904010002', 'ce23@campus.edu', 'CE23C001', '土木工程学院', 2, '男'),
('counselor_ce_22', '0192023a7bbd73250516f069df18b500', 'counselor', '22级土木学院辅导员', '13904010003', 'ce22@campus.edu', 'CE22C001', '土木工程学院', 3, '女'),
('counselor_ce_21', '0192023a7bbd73250516f069df18b500', 'counselor', '21级土木学院辅导员', '13904010004', 'ce21@campus.edu', 'CE21C001', '土木工程学院', 4, '男'),
('counselor_ei_24', '0192023a7bbd73250516f069df18b500', 'counselor', '24级电信学院辅导员', '13905010001', 'ei24@campus.edu', 'EI24C001', '电子信息学院', 1, '男'),
('counselor_ei_23', '0192023a7bbd73250516f069df18b500', 'counselor', '23级电信学院辅导员', '13905010002', 'ei23@campus.edu', 'EI23C001', '电子信息学院', 2, '女'),
('counselor_ei_22', '0192023a7bbd73250516f069df18b500', 'counselor', '22级电信学院辅导员', '13905010003', 'ei22@campus.edu', 'EI22C001', '电子信息学院', 3, '男'),
('counselor_ei_21', '0192023a7bbd73250516f069df18b500', 'counselor', '21级电信学院辅导员', '13905010004', 'ei21@campus.edu', 'EI21C001', '电子信息学院', 4, '女');

-- 3. 辅导员表
INSERT INTO `counselor` (`user_id`, `college`, `grade`, `description`) VALUES
(2,'计算机学院',1,'负责2024级计算机学院全体学生'),
(3,'计算机学院',2,'负责2023级计算机学院全体学生'),
(4,'计算机学院',3,'负责2022级计算机学院全体学生'),
(5,'计算机学院',4,'负责2021级计算机学院全体学生'),
(6,'经济管理学院',1,'负责2024级经管学院全体学生'),
(7,'经济管理学院',2,'负责2023级经管学院全体学生'),
(8,'经济管理学院',3,'负责2022级经管学院全体学生'),
(9,'经济管理学院',4,'负责2021级经管学院全体学生'),
(10,'外国语学院',1,'负责2024级外国语学院全体学生'),
(11,'外国语学院',2,'负责2023级外国语学院全体学生'),
(12,'外国语学院',3,'负责2022级外国语学院全体学生'),
(13,'外国语学院',4,'负责2021级外国语学院全体学生'),
(14,'土木工程学院',1,'负责2024级土木学院全体学生'),
(15,'土木工程学院',2,'负责2023级土木学院全体学生'),
(16,'土木工程学院',3,'负责2022级土木学院全体学生'),
(17,'土木工程学院',4,'负责2021级土木学院全体学生'),
(18,'电子信息学院',1,'负责2024级电信学院全体学生'),
(19,'电子信息学院',2,'负责2023级电信学院全体学生'),
(20,'电子信息学院',3,'负责2022级电信学院全体学生'),
(21,'电子信息学院',4,'负责2021级电信学院全体学生');

-- 4. 学生数据（密码: student123，counselor_id对应counselor表id）
INSERT INTO `user` (`username`, `password`, `role`, `real_name`, `phone`, `email`, `student_no`, `class_name`, `grade`, `college`, `major`, `gender`, `counselor_id`, `enrollment_year`) VALUES
-- 计算机学院-计科
('cs2401wjm','ad6a280417a0f533d8b670c61667e1a0','student','王建明','13810010001','wjm@stu.edu','2024010101','计科2401',1,'计算机学院','计算机科学与技术','男',1,2024),
('cs2401lxy','ad6a280417a0f533d8b670c61667e1a0','student','李晓雅','13810010002','lxy@stu.edu','2024010102','计科2401',1,'计算机学院','计算机科学与技术','女',1,2024),
('cs2301zhl','ad6a280417a0f533d8b670c61667e1a0','student','张浩龙','13810010003','zhl@stu.edu','2023010101','计科2301',2,'计算机学院','计算机科学与技术','男',2,2023),
('cs2301cyj','ad6a280417a0f533d8b670c61667e1a0','student','陈雨洁','13810010004','cyj@stu.edu','2023010102','计科2301',2,'计算机学院','计算机科学与技术','女',2,2023),
('cs2201lzw','ad6a280417a0f533d8b670c61667e1a0','student','刘志伟','13810010005','lzw@stu.edu','2022010101','计科2201',3,'计算机学院','计算机科学与技术','男',3,2022),
('cs2201zym','ad6a280417a0f533d8b670c61667e1a0','student','赵雅敏','13810010006','zym@stu.edu','2022010102','计科2201',3,'计算机学院','计算机科学与技术','女',3,2022),
('cs2101hxy','ad6a280417a0f533d8b670c61667e1a0','student','黄晓宇','13810010007','hxy@stu.edu','2021010101','计科2101',4,'计算机学院','计算机科学与技术','男',4,2021),
('cs2101syy','ad6a280417a0f533d8b670c61667e1a0','student','孙雨莹','13810010008','syy@stu.edu','2021010102','计科2101',4,'计算机学院','计算机科学与技术','女',4,2021),
-- 计算机学院-网工
('ne2401yxc','ad6a280417a0f533d8b670c61667e1a0','student','杨晓晨','13810020001','yxc@stu.edu','2024010201','网工2401',1,'计算机学院','网络工程','男',1,2024),
('ne2401wmj','ad6a280417a0f533d8b670c61667e1a0','student','吴梦佳','13810020002','wmj@stu.edu','2024010202','网工2401',1,'计算机学院','网络工程','女',1,2024),
('ne2301gzw','ad6a280417a0f533d8b670c61667e1a0','student','郭志文','13810020003','gzw@stu.edu','2023010201','网工2301',2,'计算机学院','网络工程','男',2,2023),
('ne2301hyl','ad6a280417a0f533d8b670c61667e1a0','student','何雨露','13810020004','hyl@stu.edu','2023010202','网工2301',2,'计算机学院','网络工程','女',2,2023),
-- 计算机学院-数据
('ds2401tym','ad6a280417a0f533d8b670c61667e1a0','student','田一鸣','13810030001','tym@stu.edu','2024010301','数据2401',1,'计算机学院','数据科学与大数据技术','男',1,2024),
('ds2401lxy2','ad6a280417a0f533d8b670c61667e1a0','student','林心怡','13810030002','lxy2@stu.edu','2024010302','数据2401',1,'计算机学院','数据科学与大数据技术','女',1,2024),
-- 计算机学院-物联
('iot2401rzh','ad6a280417a0f533d8b670c61667e1a0','student','任子豪','13810040001','rzh@stu.edu','2024010401','物联2401',1,'计算机学院','物联网工程','男',1,2024),
('iot2401zmn','ad6a280417a0f533d8b670c61667e1a0','student','周梦楠','13810040002','zmn@stu.edu','2024010402','物联2401',1,'计算机学院','物联网工程','女',1,2024),
-- 经管学院-工商
('bm2401zpw','ad6a280417a0f533d8b670c61667e1a0','student','张鹏伟','13820010001','zpw@stu.edu','2024020101','工商2401',1,'经济管理学院','工商管理','男',5,2024),
('bm2401lyq','ad6a280417a0f533d8b670c61667e1a0','student','刘雅琴','13820010002','lyq@stu.edu','2024020102','工商2401',1,'经济管理学院','工商管理','女',5,2024),
('bm2301cxh','ad6a280417a0f533d8b670c61667e1a0','student','程晓辉','13820010003','cxh@stu.edu','2023020101','工商2301',2,'经济管理学院','工商管理','男',6,2023),
('bm2301wxy','ad6a280417a0f533d8b670c61667e1a0','student','王欣怡','13820010004','wxy@stu.edu','2023020102','工商2301',2,'经济管理学院','工商管理','女',6,2023),
-- 经管学院-会计
('ac2401hzw','ad6a280417a0f533d8b670c61667e1a0','student','韩志伟','13820020001','hzw@stu.edu','2024020201','会计2401',1,'经济管理学院','会计学','男',5,2024),
('ac2401zml','ad6a280417a0f533d8b670c61667e1a0','student','张美玲','13820020002','zml@stu.edu','2024020202','会计2401',1,'经济管理学院','会计学','女',5,2024),
-- 经管学院-营销
('mk2401lhy','ad6a280417a0f533d8b670c61667e1a0','student','李浩宇','13820030001','lhy@stu.edu','2024020301','营销2401',1,'经济管理学院','市场营销','男',5,2024),
('mk2401cxy','ad6a280417a0f533d8b670c61667e1a0','student','陈晓燕','13820030002','cxy@stu.edu','2024020302','营销2401',1,'经济管理学院','市场营销','女',5,2024),
-- 外国语学院-英语
('en2401szy','ad6a280417a0f533d8b670c61667e1a0','student','宋紫嫣','13830010001','szy@stu.edu','2024030101','英语2401',1,'外国语学院','英语','女',9,2024),
('en2401lxq','ad6a280417a0f533d8b670c61667e1a0','student','林晓晴','13830010002','lxq@stu.edu','2024030102','英语2401',1,'外国语学院','英语','女',9,2024),
('en2301wyf','ad6a280417a0f533d8b670c61667e1a0','student','王宇航','13830010003','wyf@stu.edu','2023030101','英语2301',2,'外国语学院','英语','男',10,2023),
('en2301xjy','ad6a280417a0f533d8b670c61667e1a0','student','许嘉颖','13830010004','xjy@stu.edu','2023030102','英语2301',2,'外国语学院','英语','女',10,2023),
-- 外国语学院-日语
('jp2401mzh','ad6a280417a0f533d8b670c61667e1a0','student','马子涵','13830020001','mzh@stu.edu','2024030201','日语2401',1,'外国语学院','日语','男',9,2024),
('jp2401yxy','ad6a280417a0f533d8b670c61667e1a0','student','叶晓雨','13830020002','yxy@stu.edu','2024030202','日语2401',1,'外国语学院','日语','女',9,2024),
-- 土木学院-土木
('ce2401dzw','ad6a280417a0f533d8b670c61667e1a0','student','邓志伟','13840010001','dzw@stu.edu','2024040101','土木2401',1,'土木工程学院','土木工程','男',13,2024),
('ce2401lxy3','ad6a280417a0f533d8b670c61667e1a0','student','罗晓燕','13840010002','lxy3@stu.edu','2024040102','土木2401',1,'土木工程学院','土木工程','女',13,2024),
('ce2301szh','ad6a280417a0f533d8b670c61667e1a0','student','宋子豪','13840010003','szh@stu.edu','2023040101','土木2301',2,'土木工程学院','土木工程','男',14,2023),
('ce2301hxy2','ad6a280417a0f533d8b670c61667e1a0','student','黄晓月','13840010004','hxy2@stu.edu','2023040102','土木2301',2,'土木工程学院','土木工程','女',14,2023),
-- 土木学院-建筑
('ar2401gzw2','ad6a280417a0f533d8b670c61667e1a0','student','顾子文','13840020001','gzw2@stu.edu','2024040201','建筑2401',1,'土木工程学院','建筑学','男',13,2024),
('ar2401zhy','ad6a280417a0f533d8b670c61667e1a0','student','赵慧颖','13840020002','zhy@stu.edu','2024040202','建筑2401',1,'土木工程学院','建筑学','女',13,2024),
-- 电信学院-电信
('ei2401lzh','ad6a280417a0f533d8b670c61667e1a0','student','李子豪','13850010001','lzh@stu.edu','2024050101','电信2401',1,'电子信息学院','电子信息工程','男',17,2024),
('ei2401wxy2','ad6a280417a0f533d8b670c61667e1a0','student','吴晓燕','13850010002','wxy2@stu.edu','2024050102','电信2401',1,'电子信息学院','电子信息工程','女',17,2024),
('ei2301zjk','ad6a280417a0f533d8b670c61667e1a0','student','张俊凯','13850010003','zjk@stu.edu','2023050101','电信2301',2,'电子信息学院','电子信息工程','男',18,2023),
('ei2301cxy2','ad6a280417a0f533d8b670c61667e1a0','student','陈欣怡','13850010004','cxy2@stu.edu','2023050102','电信2301',2,'电子信息学院','电子信息工程','女',18,2023),
-- 电信学院-通信
('tc2401yxc2','ad6a280417a0f533d8b670c61667e1a0','student','杨晓成','13850020001','yxc2@stu.edu','2024050201','通信2401',1,'电子信息学院','通信工程','男',17,2024),
('tc2401lmn','ad6a280417a0f533d8b670c61667e1a0','student','李梦楠','13850020002','lmn@stu.edu','2024050202','通信2401',1,'电子信息学院','通信工程','女',17,2024);

-- ============================================================
-- 5. 课程表数据 - 每个班级每周完整课表
-- 大一2学期, 大二4学期, 大三3学期, 大四一般3学期(大四基本没课)
-- ============================================================

-- ===== 计科2401 大一上学期 (2024-2025-1) =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('计科2401','高等数学A','王建国','教学楼A101',1,1,2,'2024-2025-1'),
('计科2401','C语言程序设计','李明','实验楼B201',1,3,4,'2024-2025-1'),
('计科2401','大学英语(一)','张丽华','外语楼C301',2,1,2,'2024-2025-1'),
('计科2401','线性代数','陈伟','教学楼A203',2,3,4,'2024-2025-1'),
('计科2401','计算机导论','赵志强','教学楼A305',3,1,2,'2024-2025-1'),
('计科2401','高等数学A','王建国','教学楼A101',3,3,4,'2024-2025-1'),
('计科2401','思想道德与法治','刘芳','教学楼A102',4,1,2,'2024-2025-1'),
('计科2401','C语言程序设计','李明','实验楼B201',4,5,6,'2024-2025-1'),
('计科2401','体育(一)','孙强','体育馆',5,1,2,'2024-2025-1'),
('计科2401','大学英语(一)','张丽华','外语楼C301',5,3,4,'2024-2025-1');

-- ===== 计科2401 大一下学期 (2024-2025-2) =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('计科2401','高等数学A(下)','王建国','教学楼A101',1,1,2,'2024-2025-2'),
('计科2401','C++程序设计','李明','实验楼B201',1,3,4,'2024-2025-2'),
('计科2401','大学英语(二)','张丽华','外语楼C301',2,1,2,'2024-2025-2'),
('计科2401','概率论与数理统计','陈伟','教学楼A203',2,3,4,'2024-2025-2'),
('计科2401','离散数学','赵志强','教学楼A305',3,1,2,'2024-2025-2'),
('计科2401','高等数学A(下)','王建国','教学楼A101',3,3,4,'2024-2025-2'),
('计科2401','中国近现代史纲要','刘芳','教学楼A102',4,1,2,'2024-2025-2'),
('计科2401','C++程序设计','李明','实验楼B201',4,5,6,'2024-2025-2'),
('计科2401','体育(二)','孙强','体育馆',5,1,2,'2024-2025-2'),
('计科2401','大学英语(二)','张丽华','外语楼C301',5,3,4,'2024-2025-2');

-- ===== 计科2301 大二上学期 (2024-2025-1) =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('计科2301','数据结构','周明','实验楼B301',1,1,2,'2024-2025-1'),
('计科2301','数字逻辑','吴强','教学楼A201',1,3,4,'2024-2025-1'),
('计科2301','大学英语(三)','张丽华','外语楼C302',2,1,2,'2024-2025-1'),
('计科2301','计算机组成原理','赵志强','教学楼A303',2,3,4,'2024-2025-1'),
('计科2301','数据结构','周明','实验楼B301',3,1,2,'2024-2025-1'),
('计科2301','马克思主义基本原理','刘芳','教学楼A102',3,5,6,'2024-2025-1'),
('计科2301','算法设计与分析','钱伟','教学楼A305',4,1,2,'2024-2025-1'),
('计科2301','面向对象程序设计(Java)','李明','实验楼B201',4,3,4,'2024-2025-1'),
('计科2301','体育(三)','孙强','体育馆',5,1,2,'2024-2025-1'),
('计科2301','大学英语(三)','张丽华','外语楼C302',5,3,4,'2024-2025-1');

-- ===== 计科2301 大二下学期 (2024-2025-2) =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('计科2301','操作系统','周明','教学楼A201',1,1,2,'2024-2025-2'),
('计科2301','数据库原理','吴强','实验楼B301',1,3,4,'2024-2025-2'),
('计科2301','大学英语(四)','张丽华','外语楼C302',2,1,2,'2024-2025-2'),
('计科2301','计算机网络','赵志强','教学楼A303',2,3,4,'2024-2025-2'),
('计科2301','操作系统','周明','教学楼A201',3,1,2,'2024-2025-2'),
('计科2301','毛泽东思想概论','刘芳','教学楼A102',3,5,6,'2024-2025-2'),
('计科2301','数据库原理','吴强','实验楼B301',4,1,2,'2024-2025-2'),
('计科2301','软件工程','钱伟','教学楼A305',4,3,4,'2024-2025-2'),
('计科2301','体育(四)','孙强','体育馆',5,1,2,'2024-2025-2');

-- ===== 计科2201 大三上学期 (2024-2025-1) =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('计科2201','编译原理','周明','教学楼A201',1,1,2,'2024-2025-1'),
('计科2201','人工智能导论','钱伟','教学楼A303',1,3,4,'2024-2025-1'),
('计科2201','计算机体系结构','赵志强','教学楼A305',2,1,2,'2024-2025-1'),
('计科2201','编译原理','周明','教学楼A201',3,1,2,'2024-2025-1'),
('计科2201','大数据技术','吴强','实验楼B301',3,3,4,'2024-2025-1'),
('计科2201','信息安全','李明','教学楼A102',4,1,2,'2024-2025-1'),
('计科2201','人工智能导论','钱伟','实验楼B201',4,3,4,'2024-2025-1');

-- ===== 计科2201 大三下学期 (2024-2025-2) =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('计科2201','机器学习','钱伟','教学楼A303',1,1,2,'2024-2025-2'),
('计科2201','云计算技术','吴强','实验楼B301',1,3,4,'2024-2025-2'),
('计科2201','自然语言处理','周明','教学楼A201',2,1,2,'2024-2025-2'),
('计科2201','机器学习','钱伟','实验楼B201',3,1,2,'2024-2025-2'),
('计科2201','深度学习','赵志强','教学楼A305',3,3,4,'2024-2025-2'),
('计科2201','计算机视觉','李明','实验楼B301',4,1,2,'2024-2025-2');

-- ===== 计科2201 大三上学期 (2023-2024-1) =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('计科2201','软件工程','钱伟','教学楼A201',1,1,2,'2023-2024-1'),
('计科2201','数据库课程设计','吴强','实验楼B301',1,3,4,'2023-2024-1'),
('计科2201','操作系统','周明','教学楼A303',2,1,2,'2023-2024-1'),
('计科2201','计算机网络','赵志强','教学楼A305',2,3,4,'2023-2024-1'),
('计科2201','软件工程','钱伟','教学楼A201',3,1,2,'2023-2024-1'),
('计科2201','数据库课程设计','吴强','实验楼B301',3,3,4,'2023-2024-1'),
('计科2201','操作系统','周明','教学楼A303',4,1,2,'2023-2024-1'),
('计科2201','创新创业实践','刘芳','教学楼A102',4,3,4,'2023-2024-1');

-- ===== 计科2101 大四上学期 (2024-2025-1) =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('计科2101','毕业设计','周明','教学楼A201',1,1,2,'2024-2025-1'),
('计科2101','前沿技术讲座','钱伟','教学楼A303',2,1,2,'2024-2025-1'),
('计科2101','毕业设计','周明','教学楼A201',3,1,2,'2024-2025-1');

-- ===== 网工2401 大一上学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('网工2401','高等数学B','王建国','教学楼A103',1,1,2,'2024-2025-1'),
('网工2401','C语言程序设计','李明','实验楼B203',1,3,4,'2024-2025-1'),
('网工2401','大学英语(一)','张丽华','外语楼C303',2,1,2,'2024-2025-1'),
('网工2401','网络技术基础','孙强','教学楼A205',2,3,4,'2024-2025-1'),
('网工2401','线性代数','陈伟','教学楼A207',3,1,2,'2024-2025-1'),
('网工2401','高等数学B','王建国','教学楼A103',3,3,4,'2024-2025-1'),
('网工2401','思想道德与法治','刘芳','教学楼A102',4,1,2,'2024-2025-1'),
('网工2401','体育(一)','孙强','体育馆',5,1,2,'2024-2025-1'),
('网工2401','大学英语(一)','张丽华','外语楼C303',5,3,4,'2024-2025-1');

-- ===== 网工2401 大一下学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('网工2401','高等数学B(下)','王建国','教学楼A103',1,1,2,'2024-2025-2'),
('网工2401','路由与交换技术','孙强','实验楼B301',1,3,4,'2024-2025-2'),
('网工2401','大学英语(二)','张丽华','外语楼C303',2,1,2,'2024-2025-2'),
('网工2401','概率论','陈伟','教学楼A207',2,3,4,'2024-2025-2'),
('网工2401','离散数学','赵志强','教学楼A205',3,1,2,'2024-2025-2'),
('网工2401','高等数学B(下)','王建国','教学楼A103',3,3,4,'2024-2025-2'),
('网工2401','中国近现代史纲要','刘芳','教学楼A102',4,1,2,'2024-2025-2'),
('网工2401','体育(二)','孙强','体育馆',5,1,2,'2024-2025-2');

-- ===== 数据2401 大一上学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('数据2401','高等数学A','王建国','教学楼A104',1,1,2,'2024-2025-1'),
('数据2401','Python程序设计','吴强','实验楼B302',1,3,4,'2024-2025-1'),
('数据2401','大学英语(一)','张丽华','外语楼C304',2,1,2,'2024-2025-1'),
('数据2401','统计学原理','钱伟','教学楼A206',2,3,4,'2024-2025-1'),
('数据2401','大数据导论','赵志强','教学楼A308',3,1,2,'2024-2025-1'),
('数据2401','高等数学A','王建国','教学楼A104',3,3,4,'2024-2025-1'),
('数据2401','思想道德与法治','刘芳','教学楼A102',4,1,2,'2024-2025-1'),
('数据2401','体育(一)','孙强','体育馆',5,1,2,'2024-2025-1');

-- ===== 数据2401 大一下学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('数据2401','高等数学A(下)','王建国','教学楼A104',1,1,2,'2024-2025-2'),
('数据2401','数据结构与算法','周明','实验楼B302',1,3,4,'2024-2025-2'),
('数据2401','大学英语(二)','张丽华','外语楼C304',2,1,2,'2024-2025-2'),
('数据2401','概率论与数理统计','陈伟','教学楼A206',2,3,4,'2024-2025-2'),
('数据2401','数据库原理','吴强','教学楼A308',3,1,2,'2024-2025-2'),
('数据2401','高等数学A(下)','王建国','教学楼A104',3,3,4,'2024-2025-2'),
('数据2401','中国近现代史纲要','刘芳','教学楼A102',4,1,2,'2024-2025-2'),
('数据2401','体育(二)','孙强','体育馆',5,1,2,'2024-2025-2');

-- ===== 物联2401 大一上学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('物联2401','高等数学B','王建国','教学楼A105',1,1,2,'2024-2025-1'),
('物联2401','C语言程序设计','李明','实验楼B204',1,3,4,'2024-2025-1'),
('物联2401','大学英语(一)','张丽华','外语楼C305',2,1,2,'2024-2025-1'),
('物联2401','电路基础','赵志强','教学楼A209',2,3,4,'2024-2025-1'),
('物联2401','物联网导论','孙强','教学楼A307',3,1,2,'2024-2025-1'),
('物联2401','高等数学B','王建国','教学楼A105',3,3,4,'2024-2025-1'),
('物联2401','思想道德与法治','刘芳','教学楼A102',4,1,2,'2024-2025-1'),
('物联2401','体育(一)','孙强','体育馆',5,1,2,'2024-2025-1');

-- ===== 物联2401 大一下学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('物联2401','高等数学B(下)','王建国','教学楼A105',1,1,2,'2024-2025-2'),
('物联2401','传感器原理','孙强','实验楼B302',1,3,4,'2024-2025-2'),
('物联2401','大学英语(二)','张丽华','外语楼C305',2,1,2,'2024-2025-2'),
('物联2401','模拟电子技术','赵志强','教学楼A209',2,3,4,'2024-2025-2'),
('物联2401','线性代数','陈伟','教学楼A307',3,1,2,'2024-2025-2'),
('物联2401','高等数学B(下)','王建国','教学楼A105',3,3,4,'2024-2025-2'),
('物联2401','中国近现代史纲要','刘芳','教学楼A102',4,1,2,'2024-2025-2'),
('物联2401','体育(二)','孙强','体育馆',5,1,2,'2024-2025-2');

-- ===== 网工2301 大二上学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('网工2301','数据结构','周明','实验楼B302',1,1,2,'2024-2025-1'),
('网工2301','计算机网络','赵志强','教学楼A205',1,3,4,'2024-2025-1'),
('网工2301','大学英语(三)','张丽华','外语楼C303',2,1,2,'2024-2025-1'),
('网工2301','路由与交换技术','孙强','实验楼B301',2,3,4,'2024-2025-1'),
('网工2301','数据结构','周明','实验楼B302',3,1,2,'2024-2025-1'),
('网工2301','马克思主义基本原理','刘芳','教学楼A102',3,5,6,'2024-2025-1'),
('网工2301','网络安全技术','钱伟','教学楼A207',4,1,2,'2024-2025-1'),
('网工2301','体育(三)','孙强','体育馆',5,1,2,'2024-2025-1');

-- ===== 网工2301 大二下学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('网工2301','操作系统','周明','教学楼A205',1,1,2,'2024-2025-2'),
('网工2301','网络编程','李明','实验楼B301',1,3,4,'2024-2025-2'),
('网工2301','大学英语(四)','张丽华','外语楼C303',2,1,2,'2024-2025-2'),
('网工2301','数据库原理','吴强','实验楼B302',2,3,4,'2024-2025-2'),
('网工2301','操作系统','周明','教学楼A205',3,1,2,'2024-2025-2'),
('网工2301','毛泽东思想概论','刘芳','教学楼A102',3,5,6,'2024-2025-2'),
('网工2301','网络编程','李明','实验楼B301',4,1,2,'2024-2025-2'),
('网工2301','体育(四)','孙强','体育馆',5,1,2,'2024-2025-2');

-- ===== 工商2401 大一上学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('工商2401','微积分','王建国','教学楼B101',1,1,2,'2024-2025-1'),
('工商2401','管理学原理','马丽','教学楼B201',1,3,4,'2024-2025-1'),
('工商2401','大学英语(一)','张丽华','外语楼C201',2,1,2,'2024-2025-1'),
('工商2401','经济学原理','黄伟','教学楼B203',2,3,4,'2024-2025-1'),
('工商2401','微积分','王建国','教学楼B101',3,1,2,'2024-2025-1'),
('工商2401','思想道德与法治','刘芳','教学楼B102',3,3,4,'2024-2025-1'),
('工商2401','会计学基础','林芳','教学楼B205',4,1,2,'2024-2025-1'),
('工商2401','体育(一)','孙强','体育馆',5,1,2,'2024-2025-1');

-- ===== 工商2401 大一下学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('工商2401','微积分(下)','王建国','教学楼B101',1,1,2,'2024-2025-2'),
('工商2401','市场营销学','马丽','教学楼B201',1,3,4,'2024-2025-2'),
('工商2401','大学英语(二)','张丽华','外语楼C201',2,1,2,'2024-2025-2'),
('工商2401','统计学','黄伟','教学楼B203',2,3,4,'2024-2025-2'),
('工商2401','微积分(下)','王建国','教学楼B101',3,1,2,'2024-2025-2'),
('工商2401','中国近现代史纲要','刘芳','教学楼B102',3,3,4,'2024-2025-2'),
('工商2401','组织行为学','林芳','教学楼B205',4,1,2,'2024-2025-2'),
('工商2401','体育(二)','孙强','体育馆',5,1,2,'2024-2025-2');

-- ===== 工商2301 大二上学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('工商2301','财务管理','马丽','教学楼B201',1,1,2,'2024-2025-1'),
('工商2301','运营管理','黄伟','教学楼B203',1,3,4,'2024-2025-1'),
('工商2301','大学英语(三)','张丽华','外语楼C201',2,1,2,'2024-2025-1'),
('工商2301','人力资源管理','林芳','教学楼B205',2,3,4,'2024-2025-1'),
('工商2301','财务管理','马丽','教学楼B201',3,1,2,'2024-2025-1'),
('工商2301','马克思主义基本原理','刘芳','教学楼B102',3,3,4,'2024-2025-1'),
('工商2301','战略管理','黄伟','教学楼B203',4,1,2,'2024-2025-1'),
('工商2301','体育(三)','孙强','体育馆',5,1,2,'2024-2025-1');

-- ===== 会计2401 大一上学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('会计2401','微积分','王建国','教学楼B103',1,1,2,'2024-2025-1'),
('会计2401','会计学原理','林芳','教学楼B207',1,3,4,'2024-2025-1'),
('会计2401','大学英语(一)','张丽华','外语楼C203',2,1,2,'2024-2025-1'),
('会计2401','经济学原理','黄伟','教学楼B209',2,3,4,'2024-2025-1'),
('会计2401','微积分','王建国','教学楼B103',3,1,2,'2024-2025-1'),
('会计2401','思想道德与法治','刘芳','教学楼B102',3,3,4,'2024-2025-1'),
('会计2401','管理学原理','马丽','教学楼B207',4,1,2,'2024-2025-1'),
('会计2401','体育(一)','孙强','体育馆',5,1,2,'2024-2025-1');

-- ===== 会计2401 大一下学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('会计2401','微积分(下)','王建国','教学楼B103',1,1,2,'2024-2025-2'),
('会计2401','中级财务会计','林芳','教学楼B207',1,3,4,'2024-2025-2'),
('会计2401','大学英语(二)','张丽华','外语楼C203',2,1,2,'2024-2025-2'),
('会计2401','统计学','黄伟','教学楼B209',2,3,4,'2024-2025-2'),
('会计2401','微积分(下)','王建国','教学楼B103',3,1,2,'2024-2025-2'),
('会计2401','中国近现代史纲要','刘芳','教学楼B102',3,3,4,'2024-2025-2'),
('会计2401','成本会计','林芳','教学楼B207',4,1,2,'2024-2025-2'),
('会计2401','体育(二)','孙强','体育馆',5,1,2,'2024-2025-2');

-- ===== 营销2401 大一上学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('营销2401','微积分','王建国','教学楼B105',1,1,2,'2024-2025-1'),
('营销2401','管理学原理','马丽','教学楼B211',1,3,4,'2024-2025-1'),
('营销2401','大学英语(一)','张丽华','外语楼C205',2,1,2,'2024-2025-1'),
('营销2401','经济学原理','黄伟','教学楼B213',2,3,4,'2024-2025-1'),
('营销2401','微积分','王建国','教学楼B105',3,1,2,'2024-2025-1'),
('营销2401','思想道德与法治','刘芳','教学楼B102',3,3,4,'2024-2025-1'),
('营销2401','市场营销学导论','马丽','教学楼B211',4,1,2,'2024-2025-1'),
('营销2401','体育(一)','孙强','体育馆',5,1,2,'2024-2025-1');

-- ===== 英语2401 大一上学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('英语2401','综合英语(一)','张丽华','外语楼C101',1,1,2,'2024-2025-1'),
('英语2401','英语听力(一)','王芳','语音楼C201',1,3,4,'2024-2025-1'),
('英语2401','英语口语(一)','Smith','外语楼C103',2,1,2,'2024-2025-1'),
('英语2401','英语语法','李红','外语楼C105',2,3,4,'2024-2025-1'),
('英语2401','综合英语(一)','张丽华','外语楼C101',3,1,2,'2024-2025-1'),
('英语2401','思想道德与法治','刘芳','教学楼C102',3,3,4,'2024-2025-1'),
('英语2401','英语阅读(一)','王芳','外语楼C103',4,1,2,'2024-2025-1'),
('英语2401','体育(一)','孙强','体育馆',5,1,2,'2024-2025-1');

-- ===== 英语2401 大一下学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('英语2401','综合英语(二)','张丽华','外语楼C101',1,1,2,'2024-2025-2'),
('英语2401','英语听力(二)','王芳','语音楼C201',1,3,4,'2024-2025-2'),
('英语2401','英语口语(二)','Smith','外语楼C103',2,1,2,'2024-2025-2'),
('英语2401','英美文化','李红','外语楼C105',2,3,4,'2024-2025-2'),
('英语2401','综合英语(二)','张丽华','外语楼C101',3,1,2,'2024-2025-2'),
('英语2401','中国近现代史纲要','刘芳','教学楼C102',3,3,4,'2024-2025-2'),
('英语2401','英语阅读(二)','王芳','外语楼C103',4,1,2,'2024-2025-2'),
('英语2401','体育(二)','孙强','体育馆',5,1,2,'2024-2025-2');

-- ===== 日语2401 大一上学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('日语2401','基础日语(一)','田中','外语楼C201',1,1,2,'2024-2025-1'),
('日语2401','日语听力(一)','佐藤','语音楼C202',1,3,4,'2024-2025-1'),
('日语2401','日语口语(一)','田中','外语楼C203',2,1,2,'2024-2025-1'),
('日语2401','日语语法','李红','外语楼C205',2,3,4,'2024-2025-1'),
('日语2401','基础日语(一)','田中','外语楼C201',3,1,2,'2024-2025-1'),
('日语2401','思想道德与法治','刘芳','教学楼C102',3,3,4,'2024-2025-1'),
('日语2401','日本文化概论','佐藤','外语楼C203',4,1,2,'2024-2025-1'),
('日语2401','体育(一)','孙强','体育馆',5,1,2,'2024-2025-1');

-- ===== 土木2401 大一上学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('土木2401','高等数学A','王建国','教学楼D101',1,1,2,'2024-2025-1'),
('土木2401','画法几何','张伟','教学楼D201',1,3,4,'2024-2025-1'),
('土木2401','大学英语(一)','张丽华','外语楼D301',2,1,2,'2024-2025-1'),
('土木2401','土木工程概论','李强','教学楼D203',2,3,4,'2024-2025-1'),
('土木2401','高等数学A','王建国','教学楼D101',3,1,2,'2024-2025-1'),
('土木2401','思想道德与法治','刘芳','教学楼D102',3,3,4,'2024-2025-1'),
('土木2401','线性代数','陈伟','教学楼D205',4,1,2,'2024-2025-1'),
('土木2401','体育(一)','孙强','体育馆',5,1,2,'2024-2025-1');

-- ===== 土木2401 大一下学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('土木2401','高等数学A(下)','王建国','教学楼D101',1,1,2,'2024-2025-2'),
('土木2401','工程制图','张伟','教学楼D201',1,3,4,'2024-2025-2'),
('土木2401','大学英语(二)','张丽华','外语楼D301',2,1,2,'2024-2025-2'),
('土木2401','理论力学','李强','教学楼D203',2,3,4,'2024-2025-2'),
('土木2401','高等数学A(下)','王建国','教学楼D101',3,1,2,'2024-2025-2'),
('土木2401','中国近现代史纲要','刘芳','教学楼D102',3,3,4,'2024-2025-2'),
('土木2401','概率论','陈伟','教学楼D205',4,1,2,'2024-2025-2'),
('土木2401','体育(二)','孙强','体育馆',5,1,2,'2024-2025-2');

-- ===== 建筑2401 大一上学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('建筑2401','建筑初步','张伟','设计楼E101',1,1,2,'2024-2025-1'),
('建筑2401','建筑制图','李强','设计楼E201',1,3,4,'2024-2025-1'),
('建筑2401','大学英语(一)','张丽华','外语楼D303',2,1,2,'2024-2025-1'),
('建筑2401','建筑设计基础','张伟','设计楼E101',2,3,4,'2024-2025-1'),
('建筑2401','建筑初步','张伟','设计楼E101',3,1,2,'2024-2025-1'),
('建筑2401','思想道德与法治','刘芳','教学楼D102',3,3,4,'2024-2025-1'),
('建筑2401','美术基础','王芳','设计楼E301',4,1,2,'2024-2025-1'),
('建筑2401','体育(一)','孙强','体育馆',5,1,2,'2024-2025-1');

-- ===== 电信2401 大一上学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('电信2401','高等数学A','王建国','教学楼E101',1,1,2,'2024-2025-1'),
('电信2401','电路分析基础','赵志强','实验楼D201',1,3,4,'2024-2025-1'),
('电信2401','大学英语(一)','张丽华','外语楼E301',2,1,2,'2024-2025-1'),
('电信2401','C语言程序设计','李明','实验楼D203',2,3,4,'2024-2025-1'),
('电信2401','高等数学A','王建国','教学楼E101',3,1,2,'2024-2025-1'),
('电信2401','思想道德与法治','刘芳','教学楼E102',3,3,4,'2024-2025-1'),
('电信2401','线性代数','陈伟','教学楼E205',4,1,2,'2024-2025-1'),
('电信2401','体育(一)','孙强','体育馆',5,1,2,'2024-2025-1');

-- ===== 电信2401 大一下学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('电信2401','高等数学A(下)','王建国','教学楼E101',1,1,2,'2024-2025-2'),
('电信2401','模拟电子技术','赵志强','实验楼D201',1,3,4,'2024-2025-2'),
('电信2401','大学英语(二)','张丽华','外语楼E301',2,1,2,'2024-2025-2'),
('电信2401','信号与系统','吴强','教学楼E203',2,3,4,'2024-2025-2'),
('电信2401','高等数学A(下)','王建国','教学楼E101',3,1,2,'2024-2025-2'),
('电信2401','中国近现代史纲要','刘芳','教学楼E102',3,3,4,'2024-2025-2'),
('电信2401','数字电子技术','赵志强','实验楼D201',4,1,2,'2024-2025-2'),
('电信2401','体育(二)','孙强','体育馆',5,1,2,'2024-2025-2');

-- ===== 电信2301 大二上学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('电信2301','数字信号处理','吴强','教学楼E201',1,1,2,'2024-2025-1'),
('电信2301','通信原理','赵志强','实验楼D301',1,3,4,'2024-2025-1'),
('电信2301','大学英语(三)','张丽华','外语楼E303',2,1,2,'2024-2025-1'),
('电信2301','电磁场与电磁波','钱伟','教学楼E203',2,3,4,'2024-2025-1'),
('电信2301','数字信号处理','吴强','教学楼E201',3,1,2,'2024-2025-1'),
('电信2301','马克思主义基本原理','刘芳','教学楼E102',3,3,4,'2024-2025-1'),
('电信2301','嵌入式系统','李明','实验楼D301',4,1,2,'2024-2025-1'),
('电信2301','体育(三)','孙强','体育馆',5,1,2,'2024-2025-1');

-- ===== 通信2401 大一上学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('通信2401','高等数学B','王建国','教学楼E103',1,1,2,'2024-2025-1'),
('通信2401','电路分析基础','赵志强','实验楼D203',1,3,4,'2024-2025-1'),
('通信2401','大学英语(一)','张丽华','外语楼E305',2,1,2,'2024-2025-1'),
('通信2401','通信导论','孙强','教学楼E207',2,3,4,'2024-2025-1'),
('通信2401','高等数学B','王建国','教学楼E103',3,1,2,'2024-2025-1'),
('通信2401','思想道德与法治','刘芳','教学楼E102',3,3,4,'2024-2025-1'),
('通信2401','C语言程序设计','李明','实验楼D203',4,1,2,'2024-2025-1'),
('通信2401','体育(一)','孙强','体育馆',5,1,2,'2024-2025-1');

-- ===== 通信2401 大一下学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('通信2401','高等数学B(下)','王建国','教学楼E103',1,1,2,'2024-2025-2'),
('通信2401','模拟电子技术','赵志强','实验楼D203',1,3,4,'2024-2025-2'),
('通信2401','大学英语(二)','张丽华','外语楼E305',2,1,2,'2024-2025-2'),
('通信2401','信号与系统','吴强','教学楼E207',2,3,4,'2024-2025-2'),
('通信2401','高等数学B(下)','王建国','教学楼E103',3,1,2,'2024-2025-2'),
('通信2401','中国近现代史纲要','刘芳','教学楼E102',3,3,4,'2024-2025-2'),
('通信2401','数字电子技术','赵志强','实验楼D203',4,1,2,'2024-2025-2'),
('通信2401','体育(二)','孙强','体育馆',5,1,2,'2024-2025-2');

-- ===== 计科2301 大一上学期 (历史学期) =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('计科2301','高等数学A','王建国','教学楼A101',1,1,2,'2023-2024-1'),
('计科2301','C语言程序设计','李明','实验楼B201',1,3,4,'2023-2024-1'),
('计科2301','大学英语(一)','张丽华','外语楼C301',2,1,2,'2023-2024-1'),
('计科2301','线性代数','陈伟','教学楼A203',2,3,4,'2023-2024-1'),
('计科2301','计算机导论','赵志强','教学楼A305',3,1,2,'2023-2024-1'),
('计科2301','高等数学A','王建国','教学楼A101',3,3,4,'2023-2024-1'),
('计科2301','思想道德与法治','刘芳','教学楼A102',4,1,2,'2023-2024-1'),
('计科2301','体育(一)','孙强','体育馆',5,1,2,'2023-2024-1');

-- ===== 计科2301 大一下学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('计科2301','高等数学A(下)','王建国','教学楼A101',1,1,2,'2023-2024-2'),
('计科2301','C++程序设计','李明','实验楼B201',1,3,4,'2023-2024-2'),
('计科2301','大学英语(二)','张丽华','外语楼C301',2,1,2,'2023-2024-2'),
('计科2301','概率论与数理统计','陈伟','教学楼A203',2,3,4,'2023-2024-2'),
('计科2301','离散数学','赵志强','教学楼A305',3,1,2,'2023-2024-2'),
('计科2301','高等数学A(下)','王建国','教学楼A101',3,3,4,'2023-2024-2'),
('计科2301','中国近现代史纲要','刘芳','教学楼A102',4,1,2,'2023-2024-2'),
('计科2301','体育(二)','孙强','体育馆',5,1,2,'2023-2024-2');

-- ===== 计科2201 大一上学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('计科2201','高等数学A','王建国','教学楼A101',1,1,2,'2022-2023-1'),
('计科2201','C语言程序设计','李明','实验楼B201',1,3,4,'2022-2023-1'),
('计科2201','大学英语(一)','张丽华','外语楼C301',2,1,2,'2022-2023-1'),
('计科2201','线性代数','陈伟','教学楼A203',2,3,4,'2022-2023-1'),
('计科2201','计算机导论','赵志强','教学楼A305',3,1,2,'2022-2023-1'),
('计科2201','高等数学A','王建国','教学楼A101',3,3,4,'2022-2023-1'),
('计科2201','思想道德与法治','刘芳','教学楼A102',4,1,2,'2022-2023-1'),
('计科2201','体育(一)','孙强','体育馆',5,1,2,'2022-2023-1');

-- ===== 计科2201 大一下学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('计科2201','高等数学A(下)','王建国','教学楼A101',1,1,2,'2022-2023-2'),
('计科2201','C++程序设计','李明','实验楼B201',1,3,4,'2022-2023-2'),
('计科2201','大学英语(二)','张丽华','外语楼C301',2,1,2,'2022-2023-2'),
('计科2201','概率论与数理统计','陈伟','教学楼A203',2,3,4,'2022-2023-2'),
('计科2201','离散数学','赵志强','教学楼A305',3,1,2,'2022-2023-2'),
('计科2201','中国近现代史纲要','刘芳','教学楼A102',4,1,2,'2022-2023-2'),
('计科2201','体育(二)','孙强','体育馆',5,1,2,'2022-2023-2');

-- ===== 计科2201 大二上学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('计科2201','数据结构','周明','实验楼B301',1,1,2,'2023-2024-1'),
('计科2201','计算机组成原理','赵志强','教学楼A303',1,3,4,'2023-2024-1'),
('计科2201','大学英语(三)','张丽华','外语楼C302',2,1,2,'2023-2024-1'),
('计科2201','数字逻辑','吴强','教学楼A201',2,3,4,'2023-2024-1'),
('计科2201','数据结构','周明','实验楼B301',3,1,2,'2023-2024-1'),
('计科2201','马克思主义基本原理','刘芳','教学楼A102',3,5,6,'2023-2024-1'),
('计科2201','面向对象程序设计','李明','实验楼B201',4,1,2,'2023-2024-1'),
('计科2201','体育(三)','孙强','体育馆',5,1,2,'2023-2024-1');

-- ===== 计科2201 大二下学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('计科2201','操作系统','周明','教学楼A201',1,1,2,'2023-2024-2'),
('计科2201','数据库原理','吴强','实验楼B301',1,3,4,'2023-2024-2'),
('计科2201','大学英语(四)','张丽华','外语楼C302',2,1,2,'2023-2024-2'),
('计科2201','计算机网络','赵志强','教学楼A303',2,3,4,'2023-2024-2'),
('计科2201','操作系统','周明','教学楼A201',3,1,2,'2023-2024-2'),
('计科2201','毛泽东思想概论','刘芳','教学楼A102',3,5,6,'2023-2024-2'),
('计科2201','软件工程','钱伟','教学楼A305',4,1,2,'2023-2024-2'),
('计科2201','体育(四)','孙强','体育馆',5,1,2,'2023-2024-2');

-- ===== 计科2101 大一上学期 =====
INSERT INTO `course_schedule` (`class_name`, `course_name`, `teacher_name`, `location`, `day_of_week`, `period_start`, `period_end`, `semester`) VALUES
('计科2101','高等数学A','王建国','教学楼A101',1,1,2,'2021-2022-1'),
('计科2101','C语言程序设计','李明','实验楼B201',1,3,4,'2021-2022-1'),
('计科2101','大学英语(一)','张丽华','外语楼C301',2,1,2,'2021-2022-1'),
('计科2101','线性代数','陈伟','教学楼A203',2,3,4,'2021-2022-1'),
('计科2101','计算机导论','赵志强','教学楼A305',3,1,2,'2021-2022-1'),
('计科2101','思想道德与法治','刘芳','教学楼A102',4,1,2,'2021-2022-1'),
('计科2101','体育(一)','孙强','体育馆',5,1,2,'2021-2022-1');

-- ============================================================
-- 6. 选课数据
-- ============================================================
INSERT INTO `course_selection` (`course_name`, `course_type`, `teacher_name`, `location`, `max_students`, `current_students`, `credit`, `semester`, `day_of_week`, `period_start`, `period_end`, `status`, `college`, `grade`, `is_open`) VALUES
('人文经典导读','选修','刘芳','教学楼A401',120,45,2,'2024-2025-1',2,5,6,'open','计算机学院',1,1),
('大学生心理健康','选修','王芳','教学楼A402',100,60,2,'2024-2025-1',3,5,6,'open','计算机学院',1,1),
('摄影艺术鉴赏','选修','张伟','艺术楼F101',80,55,2,'2024-2025-1',4,5,6,'open','计算机学院',1,1),
('创新创业基础','选修','马丽','教学楼B401',150,80,2,'2024-2025-1',1,5,6,'open','经济管理学院',1,1),
('商务礼仪','选修','林芳','教学楼B402',100,40,2,'2024-2025-1',2,5,6,'open','经济管理学院',1,1),
('西方文化概论','选修','Smith','外语楼C401',80,35,2,'2024-2025-1',3,5,6,'open','外国语学院',1,1),
('建筑美学','选修','张伟','设计楼E401',60,30,2,'2024-2025-1',4,5,6,'open','土木工程学院',1,1),
('物联网应用开发','选修','孙强','实验楼D401',80,50,2,'2024-2025-1',1,5,6,'open','电子信息学院',1,1),
('体育(篮球)','实践','孙强','体育馆',40,30,1,'2024-2025-1',2,7,8,'open',NULL,NULL,1),
('体育(排球)','实践','李强','体育馆',40,25,1,'2024-2025-1',3,7,8,'open',NULL,NULL,1),
('体育(乒乓球)','实践','王强','体育馆',30,20,1,'2024-2025-1',4,7,8,'open',NULL,NULL,1),
('体育(羽毛球)','实践','赵强','体育馆',30,28,1,'2024-2025-1',1,7,8,'open',NULL,NULL,1);

-- ============================================================
-- 7. 宿舍数据
-- ============================================================
INSERT INTO `dormitory` (`building`, `room_number`, `capacity`, `current_count`, `gender`, `college`, `status`) VALUES
-- 1号楼 计算机学院男生
('1号楼','101',4,3,'男','计算机学院','available'),
('1号楼','102',4,4,'男','计算机学院','full'),
('1号楼','103',4,2,'男','计算机学院','available'),
('1号楼','201',4,3,'男','计算机学院','available'),
('1号楼','202',4,1,'男','计算机学院','available'),
('1号楼','203',4,4,'男','计算机学院','full'),
-- 2号楼 计算机学院女生
('2号楼','101',4,3,'女','计算机学院','available'),
('2号楼','102',4,2,'女','计算机学院','available'),
('2号楼','103',4,4,'女','计算机学院','full'),
('2号楼','201',4,1,'女','计算机学院','available'),
-- 3号楼 经管学院
('3号楼','101',4,2,'男','经济管理学院','available'),
('3号楼','102',4,3,'女','经济管理学院','available'),
('3号楼','103',4,4,'女','经济管理学院','full'),
('3号楼','201',4,1,'男','经济管理学院','available'),
-- 4号楼 外国语学院
('4号楼','101',4,2,'女','外国语学院','available'),
('4号楼','102',4,3,'女','外国语学院','available'),
('4号楼','103',4,1,'男','外国语学院','available'),
-- 5号楼 土木/电信学院
('5号楼','101',4,3,'男','土木工程学院','available'),
('5号楼','102',4,2,'男','电子信息学院','available'),
('5号楼','103',4,4,'男','土木工程学院','full'),
('5号楼','201',4,1,'女','土木工程学院','available'),
('5号楼','202',4,2,'女','电子信息学院','available');

-- ============================================================
-- 8. 成绩数据（部分示例）
-- ============================================================
INSERT INTO `score` (`student_id`, `course_name`, `course_type`, `score`, `credit`, `semester`, `class_name`) VALUES
-- 计科2401 王建明 大一上学期成绩
(22,'高等数学A','必修',88,5,'2024-2025-1','计科2401'),
(22,'C语言程序设计','必修',92,4,'2024-2025-1','计科2401'),
(22,'大学英语(一)','必修',78,3,'2024-2025-1','计科2401'),
(22,'线性代数','必修',85,3,'2024-2025-1','计科2401'),
(22,'计算机导论','必修',90,2,'2024-2025-1','计科2401'),
(22,'思想道德与法治','必修',82,3,'2024-2025-1','计科2401'),
(22,'体育(一)','实践',85,1,'2024-2025-1','计科2401'),
-- 计科2401 李晓雅 大一上学期成绩
(23,'高等数学A','必修',95,5,'2024-2025-1','计科2401'),
(23,'C语言程序设计','必修',88,4,'2024-2025-1','计科2401'),
(23,'大学英语(一)','必修',92,3,'2024-2025-1','计科2401'),
(23,'线性代数','必修',90,3,'2024-2025-1','计科2401'),
(23,'计算机导论','必修',87,2,'2024-2025-1','计科2401'),
(23,'思想道德与法治','必修',88,3,'2024-2025-1','计科2401'),
(23,'体育(一)','实践',90,1,'2024-2025-1','计科2401'),
-- 计科2301 张浩龙 大二上学期成绩
(24,'数据结构','必修',86,4,'2024-2025-1','计科2301'),
(24,'数字逻辑','必修',78,3,'2024-2025-1','计科2301'),
(24,'大学英语(三)','必修',82,3,'2024-2025-1','计科2301'),
(24,'计算机组成原理','必修',75,4,'2024-2025-1','计科2301'),
(24,'马克思主义基本原理','必修',88,3,'2024-2025-1','计科2301'),
(24,'算法设计与分析','必修',80,3,'2024-2025-1','计科2301'),
(24,'面向对象程序设计(Java)','必修',85,3,'2024-2025-1','计科2301'),
(24,'体育(三)','实践',90,1,'2024-2025-1','计科2301'),
-- 计科2201 刘志伟 大三上学期成绩
(26,'编译原理','必修',72,3,'2024-2025-1','计科2201'),
(26,'人工智能导论','必修',85,3,'2024-2025-1','计科2201'),
(26,'计算机体系结构','必修',68,3,'2024-2025-1','计科2201'),
(26,'大数据技术','必修',78,3,'2024-2025-1','计科2201'),
(26,'信息安全','必修',82,3,'2024-2025-1','计科2201');

-- ============================================================
-- 9. 公告数据
-- ============================================================
INSERT INTO `notice` (`title`, `content`, `category`, `author_id`, `is_top`) VALUES
('2024-2025学年第一学期选课通知','各位同学，2024-2025学年第一学期选课将于下周一正式开始，请各位同学提前查看课程安排，合理规划选课。具体选课时间安排如下：大一9:00-12:00，大二13:00-16:00，大三17:00-20:00。','通知',1,1),
('关于宿舍安全检查的通知','为保障学生住宿安全，学校将于下周进行宿舍安全大检查，请各位同学注意用电安全，不得使用大功率电器。','通知',1,0),
('校园招聘会通知','本校将于下月举办2025届毕业生校园招聘会，届时将有100余家企业参加，请各位同学提前准备简历。','活动',1,0);

-- ============================================================
-- 10. 活动数据
-- ============================================================
INSERT INTO `activity` (`title`, `description`, `location`, `start_time`, `end_time`, `max_participants`, `current_participants`, `organizer_id`, `status`) VALUES
('2024年秋季运动会','一年一度的校运动会，欢迎各位同学踊跃报名参加！','田径场','2024-11-15 08:00:00','2024-11-17 17:00:00',500,120,1,'active'),
('编程大赛','面向全校学生的编程竞赛，设有一等奖、二等奖、三等奖若干。','实验楼B301','2024-12-01 09:00:00','2024-12-01 17:00:00',100,45,1,'active'),
('英语演讲比赛','展示你的英语口语能力，提升自我！','外语楼C101','2024-12-10 14:00:00','2024-12-10 17:00:00',50,20,1,'active');
