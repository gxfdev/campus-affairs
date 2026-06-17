package com.xiaou.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiaou.entity.CourseSchedule;
import com.xiaou.mapper.CourseScheduleMapper;
import com.xiaou.service.CourseScheduleService;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;

@Service
public class CourseScheduleServiceImpl extends ServiceImpl<CourseScheduleMapper, CourseSchedule> implements CourseScheduleService {

    @Override
    public List<CourseSchedule> getScheduleByClass(String className, String semester) {
        LambdaQueryWrapper<CourseSchedule> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CourseSchedule::getClassName, className);
        if (StringUtils.hasText(semester)) {
            wrapper.eq(CourseSchedule::getSemester, semester);
        }
        wrapper.orderByAsc(CourseSchedule::getDayOfWeek, CourseSchedule::getPeriodStart);
        return this.list(wrapper);
    }

    @Override
    public Page<CourseSchedule> getSchedulePage(int pageNum, int pageSize, String className, String semester) {
        Page<CourseSchedule> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<CourseSchedule> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(className)) {
            wrapper.eq(CourseSchedule::getClassName, className);
        }
        if (StringUtils.hasText(semester)) {
            wrapper.eq(CourseSchedule::getSemester, semester);
        }
        wrapper.orderByAsc(CourseSchedule::getClassName, CourseSchedule::getDayOfWeek, CourseSchedule::getPeriodStart);
        return this.page(page, wrapper);
    }
}
