package com.xiaou.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.xiaou.entity.CourseSelection;

public interface CourseSelectionService extends IService<CourseSelection> {
    Page<CourseSelection> getCourseSelectionPage(int pageNum, int pageSize, String courseType, String semester);
    void selectCourse(Long courseId, Long studentId);
    void dropCourse(Long courseId, Long studentId);
}
