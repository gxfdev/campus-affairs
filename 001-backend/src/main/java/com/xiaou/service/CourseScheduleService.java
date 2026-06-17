package com.xiaou.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.xiaou.entity.CourseSchedule;

import java.util.List;

public interface CourseScheduleService extends IService<CourseSchedule> {
    List<CourseSchedule> getScheduleByClass(String className, String semester);
    Page<CourseSchedule> getSchedulePage(int pageNum, int pageSize, String className, String semester);
}
