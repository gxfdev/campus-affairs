package com.xiaou.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiaou.entity.CourseSelection;
import com.xiaou.entity.CourseSelectionRecord;
import com.xiaou.mapper.CourseSelectionMapper;
import com.xiaou.mapper.CourseSelectionRecordMapper;
import com.xiaou.service.CourseSelectionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class CourseSelectionServiceImpl extends ServiceImpl<CourseSelectionMapper, CourseSelection> implements CourseSelectionService {

    @Autowired
    private CourseSelectionRecordMapper recordMapper;

    @Override
    public Page<CourseSelection> getCourseSelectionPage(int pageNum, int pageSize, String courseType, String semester) {
        Page<CourseSelection> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<CourseSelection> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(courseType)) {
            wrapper.eq(CourseSelection::getCourseType, courseType);
        }
        if (StringUtils.hasText(semester)) {
            wrapper.eq(CourseSelection::getSemester, semester);
        }
        wrapper.orderByAsc(CourseSelection::getCourseType, CourseSelection::getCourseName);
        return this.page(page, wrapper);
    }

    @Override
    @Transactional
    public void selectCourse(Long courseId, Long studentId) {
        CourseSelection course = this.getById(courseId);
        if (course == null) {
            throw new RuntimeException("课程不存在");
        }
        if ("full".equals(course.getStatus()) || course.getCurrentStudents() >= course.getMaxStudents()) {
            throw new RuntimeException("课程已满，无法选课");
        }
        // 检查是否已选
        LambdaQueryWrapper<CourseSelectionRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CourseSelectionRecord::getCourseId, courseId)
               .eq(CourseSelectionRecord::getStudentId, studentId)
               .eq(CourseSelectionRecord::getStatus, 1);
        if (recordMapper.selectCount(wrapper) > 0) {
            throw new RuntimeException("您已选择该课程");
        }
        // 创建选课记录
        CourseSelectionRecord record = new CourseSelectionRecord();
        record.setCourseId(courseId);
        record.setStudentId(studentId);
        record.setStatus(1);
        recordMapper.insert(record);
        // 更新课程当前人数
        course.setCurrentStudents(course.getCurrentStudents() + 1);
        if (course.getCurrentStudents() >= course.getMaxStudents()) {
            course.setStatus("full");
        }
        this.updateById(course);
    }

    @Override
    @Transactional
    public void dropCourse(Long courseId, Long studentId) {
        // 查找选课记录
        LambdaQueryWrapper<CourseSelectionRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CourseSelectionRecord::getCourseId, courseId)
               .eq(CourseSelectionRecord::getStudentId, studentId)
               .eq(CourseSelectionRecord::getStatus, 1);
        CourseSelectionRecord record = recordMapper.selectOne(wrapper);
        if (record == null) {
            throw new RuntimeException("未找到选课记录");
        }
        // 退课
        record.setStatus(0);
        recordMapper.updateById(record);
        // 更新课程当前人数
        CourseSelection course = this.getById(courseId);
        if (course != null) {
            course.setCurrentStudents(Math.max(0, course.getCurrentStudents() - 1));
            if ("full".equals(course.getStatus())) {
                course.setStatus("open");
            }
            this.updateById(course);
        }
    }
}
