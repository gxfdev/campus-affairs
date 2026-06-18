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

-- 1. 管理员 (初始密码: 123456)
INSERT INTO `user` (`username`, `password`, `role`, `real_name`, `phone`, `email`, `student_no`, `gender`) VALUES
('admin', 'e10adc3949ba59abbe56e057f20f883e', 'admin', '系统管理员', '13800000000', 'admin@campus.edu', 'ADMIN001', '男');

-- 2. 辅导员（5学院×4届=20个，初始密码: 123456，账号为姓名拼音）
INSERT INTO `user` (`username`, `password`, `role`, `real_name`, `phone`, `email`, `student_no`, `college`, `grade`, `gender`) VALUES
('wangjianguo', 'e10adc3949ba59abbe56e057f20f883e', 'counselor', '王建国', '13901010001', 'wangjg@campus.edu', 'CS24C001', '计算机学院', 1, '男'),
('liumei', 'e10adc3949ba59abbe56e057f20f883e', 'counselor', '刘梅', '13901010002', 'liumei@campus.edu', 'CS23C001', '计算机学院', 2, '女'),
('zhangwei', 'e10adc3949ba59abbe56e057f20f883e', 'counselor', '张伟', '13901010003', 'zhangwei@campus.edu', 'CS22C001', '计算机学院', 3, '男'),
('chenfang', 'e10adc3949ba59abbe56e057f20f883e', 'counselor', '陈芳', '13901010004', 'chenfang@campus.edu', 'CS21C001', '计算机学院', 4, '女'),
('liuyan', 'e10adc3949ba59abbe56e057f20f883e', 'counselor', '刘艳', '13902010001', 'liuyan@campus.edu', 'EM24C001', '经济管理学院', 1, '女'),
('wangqiang', 'e10adc3949ba59abbe56e057f20f883e', 'counselor', '王强', '13902010002', 'wangqiang@campus.edu', 'EM23C001', '经济管理学院', 2, '男'),
('zhaoling', 'e10adc3949ba59abbe56e057f20f883e', 'counselor', '赵玲', '13902010003', 'zhaoling@campus.edu', 'EM22C001', '经济管理学院', 3, '女'),
('sunlei', 'e10adc3949ba59abbe56e057f20f883e', 'counselor', '孙磊', '13902010004', 'sunlei@campus.edu', 'EM21C001', '经济管理学院', 4, '男'),
('zhoumin', 'e10adc3949ba59abbe56e057f20f883e', 'counselor', '周敏', '13903010001', 'zhoumin@campus.edu', 'FL24C001', '外国语学院', 1, '女'),
('wujing', 'e10adc3949ba59abbe56e057f20f883e', 'counselor', '吴静', '13903010002', 'wujing@campus.edu', 'FL23C001', '外国语学院', 2, '女'),
('xuhao', 'e10adc3949ba59abbe56e057f20f883e', 'counselor', '徐浩', '13903010003', 'xuhao@campus.edu', 'FL22C001', '外国语学院', 3, '男'),
('huangli', 'e10adc3949ba59abbe56e057f20f883e', 'counselor', '黄丽', '13903010004', 'huangli@campus.edu', 'FL21C001', '外国语学院', 4, '女'),
('majian', 'e10adc3949ba59abbe56e057f20f883e', 'counselor', '马健', '13904010001', 'majian@campus.edu', 'CE24C001', '土木工程学院', 1, '男'),
('guobin', 'e10adc3949ba59abbe56e057f20f883e', 'counselor', '郭斌', '13904010002', 'guobin@campus.edu', 'CE23C001', '土木工程学院', 2, '男'),
('linxue', 'e10adc3949ba59abbe56e057f20f883e', 'counselor', '林雪', '13904010003', 'linxue@campus.edu', 'CE22C001', '土木工程学院', 3, '女'),
('gaopeng', 'e10adc3949ba59abbe56e057f20f883e', 'counselor', '高鹏', '13904010004', 'gaopeng@campus.edu', 'CE21C001', '土木工程学院', 4, '男'),
('zhengtao', 'e10adc3949ba59abbe56e057f20f883e', 'counselor', '郑涛', '13905010001', 'zhengtao@campus.edu', 'EI24C001', '电子信息学院', 1, '男'),
('tangyu', 'e10adc3949ba59abbe56e057f20f883e', 'counselor', '唐玉', '13905010002', 'tangyu@campus.edu', 'EI23C001', '电子信息学院', 2, '女'),
('fenglei', 'e10adc3949ba59abbe56e057f20f883e', 'counselor', '冯磊', '13905010003', 'fenglei@campus.edu', 'EI22C001', '电子信息学院', 3, '男'),
('xieyun', 'e10adc3949ba59abbe56e057f20f883e', 'counselor', '谢云', '13905010004', 'xieyun@campus.edu', 'EI21C001', '电子信息学院', 4, '女');

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

-- 4. 学生数据（初始密码: 123456，账号为姓名拼音，counselor_id对应counselor表id）
INSERT INTO `user` (`username`, `password`, `role`, `real_name`, `phone`, `email`, `student_no`, `class_name`, `grade`, `college`, `major`, `gender`, `counselor_id`, `enrollment_year`) VALUES
-- 计算机学院-计科
('wangjianming','e10adc3949ba59abbe56e057f20f883e','student','王建明','13810010001','wangjianming@stu.edu','2024010101','计科2401',1,'计算机学院','计算机科学与技术','男',1,2024),
('lixiaoya','e10adc3949ba59abbe56e057f20f883e','student','李晓雅','13810010002','lixiaoya@stu.edu','2024010102','计科2401',1,'计算机学院','计算机科学与技术','女',1,2024),
('zhanghaolong','e10adc3949ba59abbe56e057f20f883e','student','张浩龙','13810010003','zhanghaolong@stu.edu','2023010101','计科2301',2,'计算机学院','计算机科学与技术','男',2,2023),
('chenyujie','e10adc3949ba59abbe56e057f20f883e','student','陈雨洁','13810010004','chenyujie@stu.edu','2023010102','计科2301',2,'计算机学院','计算机科学与技术','女',2,2023),
('liuzhiwei','e10adc3949ba59abbe56e057f20f883e','student','刘志伟','13810010005','liuzhiwei@stu.edu','2022010101','计科2201',3,'计算机学院','计算机科学与技术','男',3,2022),
('zhaoyamin','e10adc3949ba59abbe56e057f20f883e','student','赵雅敏','13810010006','zhaoyamin@stu.edu','2022010102','计科2201',3,'计算机学院','计算机科学与技术','女',3,2022),
('huangxiaoyu','e10adc3949ba59abbe56e057f20f883e','student','黄晓宇','13810010007','huangxiaoyu@stu.edu','2021010101','计科2101',4,'计算机学院','计算机科学与技术','男',4,2021),
('sunyuying','e10adc3949ba59abbe56e057f20f883e','student','孙雨莹','13810010008','sunyuying@stu.edu','2021010102','计科2101',4,'计算机学院','计算机科学与技术','女',4,2021),
-- 计算机学院-网工
('yangxiaochen','e10adc3949ba59abbe56e057f20f883e','student','杨晓晨','13810020001','yangxiaochen@stu.edu','2024010201','网工2401',1,'计算机学院','网络工程','男',1,2024),
('wumengjia','e10adc3949ba59abbe56e057f20f883e','student','吴梦佳','13810020002','wumengjia@stu.edu','2024010202','网工2401',1,'计算机学院','网络工程','女',1,2024),
('guozhiwen','e10adc3949ba59abbe56e057f20f883e','student','郭志文','13810020003','guozhiwen@stu.edu','2023010201','网工2301',2,'计算机学院','网络工程','男',2,2023),
('heyulu','e10adc3949ba59abbe56e057f20f883e','student','何雨露','13810020004','heyulu@stu.edu','2023010202','网工2301',2,'计算机学院','网络工程','女',2,2023),
-- 计算机学院-数据
('tianyiming','e10adc3949ba59abbe56e057f20f883e','student','田一鸣','13810030001','tianyiming@stu.edu','2024010301','数据2401',1,'计算机学院','数据科学与大数据技术','男',1,2024),
('linxinyi','e10adc3949ba59abbe56e057f20f883e','student','林心怡','13810030002','linxinyi@stu.edu','2024010302','数据2401',1,'计算机学院','数据科学与大数据技术','女',1,2024),
-- 计算机学院-物联
('renzihao','e10adc3949ba59abbe56e057f20f883e','student','任子豪','13810040001','renzihao@stu.edu','2024010401','物联2401',1,'计算机学院','物联网工程','男',1,2024),
('zhoumengnan','e10adc3949ba59abbe56e057f20f883e','student','周梦楠','13810040002','zhoumengnan@stu.edu','2024010402','物联2401',1,'计算机学院','物联网工程','女',1,2024),
-- 经管学院-工商
('zhangpengwei','e10adc3949ba59abbe56e057f20f883e','student','张鹏伟','13820010001','zhangpengwei@stu.edu','2024020101','工商2401',1,'经济管理学院','工商管理','男',5,2024),
('liuyaqin','e10adc3949ba59abbe56e057f20f883e','student','刘雅琴','13820010002','liuyaqin@stu.edu','2024020102','工商2401',1,'经济管理学院','工商管理','女',5,2024),
('chengxiaohui','e10adc3949ba59abbe56e057f20f883e','student','程晓辉','13820010003','chengxiaohui@stu.edu','2023020101','工商2301',2,'经济管理学院','工商管理','男',6,2023),
('wangxinyi','e10adc3949ba59abbe56e057f20f883e','student','王欣怡','13820010004','wangxinyi@stu.edu','2023020102','工商2301',2,'经济管理学院','工商管理','女',6,2023),
-- 经管学院-会计
('hanzhiwei','e10adc3949ba59abbe56e057f20f883e','student','韩志伟','13820020001','hanzhiwei@stu.edu','2024020201','会计2401',1,'经济管理学院','会计学','男',5,2024),
('zhangmeiling','e10adc3949ba59abbe56e057f20f883e','student','张美玲','13820020002','zhangmeiling@stu.edu','2024020202','会计2401',1,'经济管理学院','会计学','女',5,2024),
-- 经管学院-营销
('lihaoyu','e10adc3949ba59abbe56e057f20f883e','student','李浩宇','13820030001','lihaoyu@stu.edu','2024020301','营销2401',1,'经济管理学院','市场营销','男',5,2024),
('chenxiaoyan','e10adc3949ba59abbe56e057f20f883e','student','陈晓燕','13820030002','chenxiaoyan@stu.edu','2024020302','营销2401',1,'经济管理学院','市场营销','女',5,2024),
-- 外国语学院-英语
('songziyan','e10adc3949ba59abbe56e057f20f883e','student','宋紫嫣','13830010001','songziyan@stu.edu','2024030101','英语2401',1,'外国语学院','英语','女',9,2024),
('linxiaoqing','e10adc3949ba59abbe56e057f20f883e','student','林晓晴','13830010002','linxiaoqing@stu.edu','2024030102','英语2401',1,'外国语学院','英语','女',9,2024),
('wangyuhang','e10adc3949ba59abbe56e057f20f883e','student','王宇航','13830010003','wangyuhang@stu.edu','2023030101','英语2301',2,'外国语学院','英语','男',10,2023),
('xujiaying','e10adc3949ba59abbe56e057f20f883e','student','许嘉颖','13830010004','xujiaying@stu.edu','2023030102','英语2301',2,'外国语学院','英语','女',10,2023),
-- 外国语学院-日语
('mazihan','e10adc3949ba59abbe56e057f20f883e','student','马子涵','13830020001','mazihan@stu.edu','2024030201','日语2401',1,'外国语学院','日语','男',9,2024),
('yexiaoyu','e10adc3949ba59abbe56e057f20f883e','student','叶晓雨','13830020002','yexiaoyu@stu.edu','2024030202','日语2401',1,'外国语学院','日语','女',9,2024),
-- 土木学院-土木
('dengzhiwei','e10adc3949ba59abbe56e057f20f883e','student','邓志伟','13840010001','dengzhiwei@stu.edu','2024040101','土木2401',1,'土木工程学院','土木工程','男',13,2024),
('luoxiaoyan','e10adc3949ba59abbe56e057f20f883e','student','罗晓燕','13840010002','luoxiaoyan@stu.edu','2024040102','土木2401',1,'土木工程学院','土木工程','女',13,2024),
('songzihao','e10adc3949ba59abbe56e057f20f883e','student','宋子豪','13840010003','songzihao@stu.edu','2023040101','土木2301',2,'土木工程学院','土木工程','男',14,2023),
('huangxiaoyue','e10adc3949ba59abbe56e057f20f883e','student','黄晓月','13840010004','huangxiaoyue@stu.edu','2023040102','土木2301',2,'土木工程学院','土木工程','女',14,2023),
-- 土木学院-建筑
('guziwen','e10adc3949ba59abbe56e057f20f883e','student','顾子文','13840020001','guziwen@stu.edu','2024040201','建筑2401',1,'土木工程学院','建筑学','男',13,2024),
('zhaohuiying','e10adc3949ba59abbe56e057f20f883e','student','赵慧颖','13840020002','zhaohuiying@stu.edu','2024040202','建筑2401',1,'土木工程学院','建筑学','女',13,2024),
-- 电信学院-电信
('lizihao','e10adc3949ba59abbe56e057f20f883e','student','李子豪','13850010001','lizihao@stu.edu','2024050101','电信2401',1,'电子信息学院','电子信息工程','男',17,2024),
('wuxiaoyan','e10adc3949ba59abbe56e057f20f883e','student','吴晓燕','13850010002','wuxiaoyan@stu.edu','2024050102','电信2401',1,'电子信息学院','电子信息工程','女',17,2024),
('zhangjunkai','e10adc3949ba59abbe56e057f20f883e','student','张俊凯','13850010003','zhangjunkai@stu.edu','2023050101','电信2301',2,'电子信息学院','电子信息工程','男',18,2023),
('chenxinyi','e10adc3949ba59abbe56e057f20f883e','student','陈欣怡','13850010004','chenxinyi@stu.edu','2023050102','电信2301',2,'电子信息学院','电子信息工程','女',18,2023),
-- 电信学院-通信
('yangxiaocheng','e10adc3949ba59abbe56e057f20f883e','student','杨晓成','13850020001','yangxiaocheng@stu.edu','2024050201','通信2401',1,'电子信息学院','通信工程','男',17,2024),
('limengnan','e10adc3949ba59abbe56e057f20f883e','student','李梦楠','13850020002','limengnan@stu.edu','2024050202','通信2401',1,'电子信息学院','通信工程','女',17,2024);

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

-- 宿舍分配记录（非大一学生已分配宿舍，大一新生自行选择）
INSERT INTO `dormitory_selection` (`dormitory_id`, `student_id`, `status`) VALUES
-- 计科2301 张浩龙 -> 1号楼101
(1, 24, 1),
-- 计科2301 陈雨洁 -> 2号楼101
(7, 25, 1),
-- 计科2201 刘志伟 -> 1号楼103
(3, 26, 1),
-- 计科2201 赵雅敏 -> 2号楼102
(8, 27, 1),
-- 计科2101 黄晓宇 -> 1号楼201
(4, 28, 1),
-- 计科2101 孙雨莹 -> 2号楼201
(10, 29, 1),
-- 网工2301 郭志文 -> 1号楼101
(1, 32, 1),
-- 网工2301 何雨露 -> 2号楼102
(8, 33, 1),
-- 工商2301 程晓辉 -> 3号楼101
(11, 40, 1),
-- 工商2301 王欣怡 -> 3号楼102
(12, 41, 1),
-- 英语2301 王宇航 -> 4号楼103
(17, 48, 1),
-- 英语2301 许嘉颖 -> 4号楼101
(15, 49, 1),
-- 土木2301 宋子豪 -> 5号楼101
(19, 54, 1),
-- 土木2301 黄晓月 -> 5号楼201
(21, 55, 1),
-- 电信2301 张俊凯 -> 5号楼102
(20, 60, 1),
-- 电信2301 陈欣怡 -> 5号楼202
(22, 61, 1);

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
(26,'信息安全','必修',82,3,'2024-2025-1','计科2201'),
-- 计科2201 赵雅敏 大三上学期成绩
(27,'编译原理','必修',90,3,'2024-2025-1','计科2201'),
(27,'人工智能导论','必修',88,3,'2024-2025-1','计科2201'),
(27,'计算机体系结构','必修',82,3,'2024-2025-1','计科2201'),
(27,'大数据技术','必修',85,3,'2024-2025-1','计科2201'),
(27,'信息安全','必修',90,3,'2024-2025-1','计科2201'),
-- 计科2101 黄晓宇 大四上学期成绩
(28,'毕业设计','实践',85,6,'2024-2025-1','计科2101'),
(28,'软件工程','必修',78,3,'2024-2025-1','计科2101'),
(28,'云计算技术','选修',82,2,'2024-2025-1','计科2101'),
-- 计科2101 孙雨莹 大四上学期成绩
(29,'毕业设计','实践',92,6,'2024-2025-1','计科2101'),
(29,'软件工程','必修',85,3,'2024-2025-1','计科2101'),
(29,'云计算技术','选修',88,2,'2024-2025-1','计科2101'),
-- 计科2301 陈雨洁 大二上学期成绩
(25,'数据结构','必修',90,4,'2024-2025-1','计科2301'),
(25,'数字逻辑','必修',85,3,'2024-2025-1','计科2301'),
(25,'大学英语(三)','必修',88,3,'2024-2025-1','计科2301'),
(25,'计算机组成原理','必修',82,4,'2024-2025-1','计科2301'),
(25,'马克思主义基本原理','必修',90,3,'2024-2025-1','计科2301'),
(25,'算法设计与分析','必修',87,3,'2024-2025-1','计科2301'),
(25,'面向对象程序设计(Java)','必修',92,3,'2024-2025-1','计科2301'),
(25,'体育(三)','实践',85,1,'2024-2025-1','计科2301'),
-- 网工2401 杨晓晨 大一上学期成绩
(30,'高等数学A','必修',82,5,'2024-2025-1','网工2401'),
(30,'C语言程序设计','必修',88,4,'2024-2025-1','网工2401'),
(30,'大学英语(一)','必修',75,3,'2024-2025-1','网工2401'),
(30,'线性代数','必修',80,3,'2024-2025-1','网工2401'),
(30,'计算机导论','必修',85,2,'2024-2025-1','网工2401'),
(30,'思想道德与法治','必修',78,3,'2024-2025-1','网工2401'),
(30,'体育(一)','实践',88,1,'2024-2025-1','网工2401'),
-- 网工2401 吴梦佳 大一上学期成绩
(31,'高等数学A','必修',90,5,'2024-2025-1','网工2401'),
(31,'C语言程序设计','必修',85,4,'2024-2025-1','网工2401'),
(31,'大学英语(一)','必修',88,3,'2024-2025-1','网工2401'),
(31,'线性代数','必修',92,3,'2024-2025-1','网工2401'),
(31,'计算机导论','必修',80,2,'2024-2025-1','网工2401'),
(31,'思想道德与法治','必修',85,3,'2024-2025-1','网工2401'),
(31,'体育(一)','实践',90,1,'2024-2025-1','网工2401'),
-- 网工2301 郭志文 大二上学期成绩
(32,'计算机网络','必修',85,4,'2024-2025-1','网工2301'),
(32,'操作系统','必修',78,4,'2024-2025-1','网工2301'),
(32,'数据库原理','必修',82,3,'2024-2025-1','网工2301'),
(32,'概率论与数理统计','必修',80,3,'2024-2025-1','网工2301'),
(32,'大学英语(三)','必修',75,3,'2024-2025-1','网工2301'),
(32,'马克思主义基本原理','必修',88,3,'2024-2025-1','网工2301'),
(32,'体育(三)','实践',85,1,'2024-2025-1','网工2301'),
-- 网工2301 何雨露 大二上学期成绩
(33,'计算机网络','必修',92,4,'2024-2025-1','网工2301'),
(33,'操作系统','必修',88,4,'2024-2025-1','网工2301'),
(33,'数据库原理','必修',90,3,'2024-2025-1','网工2301'),
(33,'概率论与数理统计','必修',85,3,'2024-2025-1','网工2301'),
(33,'大学英语(三)','必修',90,3,'2024-2025-1','网工2301'),
(33,'马克思主义基本原理','必修',82,3,'2024-2025-1','网工2301'),
(33,'体育(三)','实践',88,1,'2024-2025-1','网工2301'),
-- 数据2401 田一鸣 大一上学期成绩
(34,'高等数学A','必修',85,5,'2024-2025-1','数据2401'),
(34,'Python程序设计','必修',90,4,'2024-2025-1','数据2401'),
(34,'大学英语(一)','必修',78,3,'2024-2025-1','数据2401'),
(34,'线性代数','必修',82,3,'2024-2025-1','数据2401'),
(34,'大数据导论','必修',88,2,'2024-2025-1','数据2401'),
(34,'思想道德与法治','必修',80,3,'2024-2025-1','数据2401'),
(34,'体育(一)','实践',85,1,'2024-2025-1','数据2401'),
-- 数据2401 林心怡 大一上学期成绩
(35,'高等数学A','必修',92,5,'2024-2025-1','数据2401'),
(35,'Python程序设计','必修',88,4,'2024-2025-1','数据2401'),
(35,'大学英语(一)','必修',90,3,'2024-2025-1','数据2401'),
(35,'线性代数','必修',85,3,'2024-2025-1','数据2401'),
(35,'大数据导论','必修',92,2,'2024-2025-1','数据2401'),
(35,'思想道德与法治','必修',88,3,'2024-2025-1','数据2401'),
(35,'体育(一)','实践',90,1,'2024-2025-1','数据2401'),
-- 物联2401 任子豪 大一上学期成绩
(36,'高等数学A','必修',80,5,'2024-2025-1','物联2401'),
(36,'C语言程序设计','必修',85,4,'2024-2025-1','物联2401'),
(36,'大学英语(一)','必修',82,3,'2024-2025-1','物联2401'),
(36,'线性代数','必修',78,3,'2024-2025-1','物联2401'),
(36,'物联网导论','必修',88,2,'2024-2025-1','物联2401'),
(36,'思想道德与法治','必修',85,3,'2024-2025-1','物联2401'),
(36,'体育(一)','实践',80,1,'2024-2025-1','物联2401'),
-- 物联2401 周梦楠 大一上学期成绩
(37,'高等数学A','必修',88,5,'2024-2025-1','物联2401'),
(37,'C语言程序设计','必修',92,4,'2024-2025-1','物联2401'),
(37,'大学英语(一)','必修',85,3,'2024-2025-1','物联2401'),
(37,'线性代数','必修',90,3,'2024-2025-1','物联2401'),
(37,'物联网导论','必修',80,2,'2024-2025-1','物联2401'),
(37,'思想道德与法治','必修',88,3,'2024-2025-1','物联2401'),
(37,'体育(一)','实践',92,1,'2024-2025-1','物联2401'),
-- 工商2401 张鹏伟 大一上学期成绩
(38,'管理学原理','必修',85,3,'2024-2025-1','工商2401'),
(38,'微观经济学','必修',80,3,'2024-2025-1','工商2401'),
(38,'大学英语(一)','必修',78,3,'2024-2025-1','工商2401'),
(38,'高等数学B','必修',82,4,'2024-2025-1','工商2401'),
(38,'思想道德与法治','必修',88,3,'2024-2025-1','工商2401'),
(38,'体育(一)','实践',85,1,'2024-2025-1','工商2401'),
-- 工商2401 刘雅琴 大一上学期成绩
(39,'管理学原理','必修',90,3,'2024-2025-1','工商2401'),
(39,'微观经济学','必修',88,3,'2024-2025-1','工商2401'),
(39,'大学英语(一)','必修',92,3,'2024-2025-1','工商2401'),
(39,'高等数学B','必修',85,4,'2024-2025-1','工商2401'),
(39,'思想道德与法治','必修',90,3,'2024-2025-1','工商2401'),
(39,'体育(一)','实践',88,1,'2024-2025-1','工商2401'),
-- 工商2301 程晓辉 大二上学期成绩
(40,'宏观经济学','必修',82,3,'2024-2025-1','工商2301'),
(40,'市场营销学','必修',78,3,'2024-2025-1','工商2301'),
(40,'财务管理','必修',85,3,'2024-2025-1','工商2301'),
(40,'组织行为学','必修',80,3,'2024-2025-1','工商2301'),
(40,'大学英语(三)','必修',75,3,'2024-2025-1','工商2301'),
(40,'马克思主义基本原理','必修',88,3,'2024-2025-1','工商2301'),
(40,'体育(三)','实践',90,1,'2024-2025-1','工商2301'),
-- 工商2301 王欣怡 大二上学期成绩
(41,'宏观经济学','必修',90,3,'2024-2025-1','工商2301'),
(41,'市场营销学','必修',88,3,'2024-2025-1','工商2301'),
(41,'财务管理','必修',92,3,'2024-2025-1','工商2301'),
(41,'组织行为学','必修',85,3,'2024-2025-1','工商2301'),
(41,'大学英语(三)','必修',88,3,'2024-2025-1','工商2301'),
(41,'马克思主义基本原理','必修',90,3,'2024-2025-1','工商2301'),
(41,'体育(三)','实践',85,1,'2024-2025-1','工商2301'),
-- 会计2401 韩志伟 大一上学期成绩
(42,'基础会计','必修',88,4,'2024-2025-1','会计2401'),
(42,'微观经济学','必修',82,3,'2024-2025-1','会计2401'),
(42,'大学英语(一)','必修',78,3,'2024-2025-1','会计2401'),
(42,'高等数学B','必修',85,4,'2024-2025-1','会计2401'),
(42,'思想道德与法治','必修',80,3,'2024-2025-1','会计2401'),
(42,'体育(一)','实践',88,1,'2024-2025-1','会计2401'),
-- 会计2401 张美玲 大一上学期成绩
(43,'基础会计','必修',92,4,'2024-2025-1','会计2401'),
(43,'微观经济学','必修',88,3,'2024-2025-1','会计2401'),
(43,'大学英语(一)','必修',90,3,'2024-2025-1','会计2401'),
(43,'高等数学B','必修',90,4,'2024-2025-1','会计2401'),
(43,'思想道德与法治','必修',85,3,'2024-2025-1','会计2401'),
(43,'体育(一)','实践',92,1,'2024-2025-1','会计2401'),
-- 营销2401 李浩宇 大一上学期成绩
(44,'市场营销学','必修',85,3,'2024-2025-1','营销2401'),
(44,'管理学原理','必修',80,3,'2024-2025-1','营销2401'),
(44,'大学英语(一)','必修',82,3,'2024-2025-1','营销2401'),
(44,'高等数学B','必修',78,4,'2024-2025-1','营销2401'),
(44,'思想道德与法治','必修',88,3,'2024-2025-1','营销2401'),
(44,'体育(一)','实践',85,1,'2024-2025-1','营销2401'),
-- 营销2401 陈晓燕 大一上学期成绩
(45,'市场营销学','必修',90,3,'2024-2025-1','营销2401'),
(45,'管理学原理','必修',88,3,'2024-2025-1','营销2401'),
(45,'大学英语(一)','必修',85,3,'2024-2025-1','营销2401'),
(45,'高等数学B','必修',92,4,'2024-2025-1','营销2401'),
(45,'思想道德与法治','必修',90,3,'2024-2025-1','营销2401'),
(45,'体育(一)','实践',88,1,'2024-2025-1','营销2401'),
-- 英语2401 宋紫嫣 大一上学期成绩
(46,'综合英语(一)','必修',88,4,'2024-2025-1','英语2401'),
(46,'英语听力(一)','必修',85,2,'2024-2025-1','英语2401'),
(46,'英语口语(一)','必修',90,2,'2024-2025-1','英语2401'),
(46,'英语阅读(一)','必修',82,2,'2024-2025-1','英语2401'),
(46,'思想道德与法治','必修',80,3,'2024-2025-1','英语2401'),
(46,'体育(一)','实践',85,1,'2024-2025-1','英语2401'),
-- 英语2401 林晓晴 大一上学期成绩
(47,'综合英语(一)','必修',92,4,'2024-2025-1','英语2401'),
(47,'英语听力(一)','必修',90,2,'2024-2025-1','英语2401'),
(47,'英语口语(一)','必修',88,2,'2024-2025-1','英语2401'),
(47,'英语阅读(一)','必修',95,2,'2024-2025-1','英语2401'),
(47,'思想道德与法治','必修',85,3,'2024-2025-1','英语2401'),
(47,'体育(一)','实践',90,1,'2024-2025-1','英语2401'),
-- 英语2301 王宇航 大二上学期成绩
(48,'综合英语(三)','必修',85,4,'2024-2025-1','英语2301'),
(48,'英汉翻译','必修',80,3,'2024-2025-1','英语2301'),
(48,'英语国家概况','必修',82,2,'2024-2025-1','英语2301'),
(48,'英语写作(一)','必修',78,2,'2024-2025-1','英语2301'),
(48,'马克思主义基本原理','必修',88,3,'2024-2025-1','英语2301'),
(48,'体育(三)','实践',85,1,'2024-2025-1','英语2301'),
-- 英语2301 许嘉颖 大二上学期成绩
(49,'综合英语(三)','必修',90,4,'2024-2025-1','英语2301'),
(49,'英汉翻译','必修',88,3,'2024-2025-1','英语2301'),
(49,'英语国家概况','必修',92,2,'2024-2025-1','英语2301'),
(49,'英语写作(一)','必修',85,2,'2024-2025-1','英语2301'),
(49,'马克思主义基本原理','必修',90,3,'2024-2025-1','英语2301'),
(49,'体育(三)','实践',88,1,'2024-2025-1','英语2301'),
-- 日语2401 马子涵 大一上学期成绩
(50,'基础日语(一)','必修',85,4,'2024-2025-1','日语2401'),
(50,'日语听力(一)','必修',80,2,'2024-2025-1','日语2401'),
(50,'日语口语(一)','必修',88,2,'2024-2025-1','日语2401'),
(50,'日本概况','必修',82,2,'2024-2025-1','日语2401'),
(50,'思想道德与法治','必修',85,3,'2024-2025-1','日语2401'),
(50,'体育(一)','实践',90,1,'2024-2025-1','日语2401'),
-- 日语2401 叶晓雨 大一上学期成绩
(51,'基础日语(一)','必修',92,4,'2024-2025-1','日语2401'),
(51,'日语听力(一)','必修',88,2,'2024-2025-1','日语2401'),
(51,'日语口语(一)','必修',90,2,'2024-2025-1','日语2401'),
(51,'日本概况','必修',95,2,'2024-2025-1','日语2401'),
(51,'思想道德与法治','必修',90,3,'2024-2025-1','日语2401'),
(51,'体育(一)','实践',85,1,'2024-2025-1','日语2401'),
-- 土木2401 邓志伟 大一上学期成绩
(52,'高等数学A','必修',82,5,'2024-2025-1','土木2401'),
(52,'工程制图','必修',85,3,'2024-2025-1','土木2401'),
(52,'大学英语(一)','必修',78,3,'2024-2025-1','土木2401'),
(52,'土木工程概论','必修',80,2,'2024-2025-1','土木2401'),
(52,'思想道德与法治','必修',88,3,'2024-2025-1','土木2401'),
(52,'体育(一)','实践',85,1,'2024-2025-1','土木2401'),
-- 土木2401 罗晓燕 大一上学期成绩
(53,'高等数学A','必修',90,5,'2024-2025-1','土木2401'),
(53,'工程制图','必修',92,3,'2024-2025-1','土木2401'),
(53,'大学英语(一)','必修',85,3,'2024-2025-1','土木2401'),
(53,'土木工程概论','必修',88,2,'2024-2025-1','土木2401'),
(53,'思想道德与法治','必修',90,3,'2024-2025-1','土木2401'),
(53,'体育(一)','实践',88,1,'2024-2025-1','土木2401'),
-- 土木2301 宋子豪 大二上学期成绩
(54,'材料力学','必修',78,4,'2024-2025-1','土木2301'),
(54,'结构力学','必修',82,4,'2024-2025-1','土木2301'),
(54,'土木工程材料','必修',80,3,'2024-2025-1','土木2301'),
(54,'大学英语(三)','必修',75,3,'2024-2025-1','土木2301'),
(54,'马克思主义基本原理','必修',88,3,'2024-2025-1','土木2301'),
(54,'体育(三)','实践',85,1,'2024-2025-1','土木2301'),
-- 土木2301 黄晓月 大二上学期成绩
(55,'材料力学','必修',88,4,'2024-2025-1','土木2301'),
(55,'结构力学','必修',92,4,'2024-2025-1','土木2301'),
(55,'土木工程材料','必修',90,3,'2024-2025-1','土木2301'),
(55,'大学英语(三)','必修',85,3,'2024-2025-1','土木2301'),
(55,'马克思主义基本原理','必修',90,3,'2024-2025-1','土木2301'),
(55,'体育(三)','实践',88,1,'2024-2025-1','土木2301'),
-- 建筑2401 顾子文 大一上学期成绩
(56,'建筑设计基础','必修',85,4,'2024-2025-1','建筑2401'),
(56,'建筑制图','必修',88,3,'2024-2025-1','建筑2401'),
(56,'大学英语(一)','必修',80,3,'2024-2025-1','建筑2401'),
(56,'高等数学B','必修',82,4,'2024-2025-1','建筑2401'),
(56,'思想道德与法治','必修',85,3,'2024-2025-1','建筑2401'),
(56,'体育(一)','实践',90,1,'2024-2025-1','建筑2401'),
-- 建筑2401 赵慧颖 大一上学期成绩
(57,'建筑设计基础','必修',92,4,'2024-2025-1','建筑2401'),
(57,'建筑制图','必修',90,3,'2024-2025-1','建筑2401'),
(57,'大学英语(一)','必修',88,3,'2024-2025-1','建筑2401'),
(57,'高等数学B','必修',90,4,'2024-2025-1','建筑2401'),
(57,'思想道德与法治','必修',88,3,'2024-2025-1','建筑2401'),
(57,'体育(一)','实践',85,1,'2024-2025-1','建筑2401'),
-- 电信2401 李子豪 大一上学期成绩
(58,'高等数学A','必修',80,5,'2024-2025-1','电信2401'),
(58,'电路分析基础','必修',85,4,'2024-2025-1','电信2401'),
(58,'大学英语(一)','必修',82,3,'2024-2025-1','电信2401'),
(58,'线性代数','必修',78,3,'2024-2025-1','电信2401'),
(58,'电子信息导论','必修',88,2,'2024-2025-1','电信2401'),
(58,'思想道德与法治','必修',85,3,'2024-2025-1','电信2401'),
(58,'体育(一)','实践',80,1,'2024-2025-1','电信2401'),
-- 电信2401 吴晓燕 大一上学期成绩
(59,'高等数学A','必修',88,5,'2024-2025-1','电信2401'),
(59,'电路分析基础','必修',92,4,'2024-2025-1','电信2401'),
(59,'大学英语(一)','必修',85,3,'2024-2025-1','电信2401'),
(59,'线性代数','必修',90,3,'2024-2025-1','电信2401'),
(59,'电子信息导论','必修',85,2,'2024-2025-1','电信2401'),
(59,'思想道德与法治','必修',90,3,'2024-2025-1','电信2401'),
(59,'体育(一)','实践',92,1,'2024-2025-1','电信2401'),
-- 电信2301 张俊凯 大二上学期成绩
(60,'信号与系统','必修',82,4,'2024-2025-1','电信2301'),
(60,'模拟电子技术','必修',78,4,'2024-2025-1','电信2301'),
(60,'数字电子技术','必修',85,3,'2024-2025-1','电信2301'),
(60,'单片机原理','必修',80,3,'2024-2025-1','电信2301'),
(60,'大学英语(三)','必修',75,3,'2024-2025-1','电信2301'),
(60,'马克思主义基本原理','必修',88,3,'2024-2025-1','电信2301'),
(60,'体育(三)','实践',85,1,'2024-2025-1','电信2301'),
-- 电信2301 陈欣怡 大二上学期成绩
(61,'信号与系统','必修',90,4,'2024-2025-1','电信2301'),
(61,'模拟电子技术','必修',88,4,'2024-2025-1','电信2301'),
(61,'数字电子技术','必修',92,3,'2024-2025-1','电信2301'),
(61,'单片机原理','必修',85,3,'2024-2025-1','电信2301'),
(61,'大学英语(三)','必修',90,3,'2024-2025-1','电信2301'),
(61,'马克思主义基本原理','必修',92,3,'2024-2025-1','电信2301'),
(61,'体育(三)','实践',88,1,'2024-2025-1','电信2301'),
-- 通信2401 杨晓成 大一上学期成绩
(62,'高等数学A','必修',85,5,'2024-2025-1','通信2401'),
(62,'电路分析基础','必修',88,4,'2024-2025-1','通信2401'),
(62,'大学英语(一)','必修',80,3,'2024-2025-1','通信2401'),
(62,'线性代数','必修',82,3,'2024-2025-1','通信2401'),
(62,'通信导论','必修',85,2,'2024-2025-1','通信2401'),
(62,'思想道德与法治','必修',88,3,'2024-2025-1','通信2401'),
(62,'体育(一)','实践',85,1,'2024-2025-1','通信2401'),
-- 通信2401 李梦楠 大一上学期成绩
(63,'高等数学A','必修',92,5,'2024-2025-1','通信2401'),
(63,'电路分析基础','必修',85,4,'2024-2025-1','通信2401'),
(63,'大学英语(一)','必修',88,3,'2024-2025-1','通信2401'),
(63,'线性代数','必修',90,3,'2024-2025-1','通信2401'),
(63,'通信导论','必修',90,2,'2024-2025-1','通信2401'),
(63,'思想道德与法治','必修',85,3,'2024-2025-1','通信2401'),
(63,'体育(一)','实践',90,1,'2024-2025-1','通信2401');

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
