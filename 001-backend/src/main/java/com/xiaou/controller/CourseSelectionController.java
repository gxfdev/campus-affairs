package com.xiaou.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.xiaou.common.Result;
import com.xiaou.entity.CourseSelection;
import com.xiaou.entity.CourseSelectionRecord;
import com.xiaou.mapper.CourseSelectionRecordMapper;
import com.xiaou.service.CourseSelectionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.List;

@RestController
@RequestMapping("/api/course-selection")
public class CourseSelectionController {

    @Autowired
    private CourseSelectionService courseSelectionService;

    @Autowired
    private CourseSelectionRecordMapper recordMapper;

    @GetMapping("/list")
    public Result<Page<CourseSelection>> list(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String courseType,
            @RequestParam(required = false) String semester) {
        return Result.success(courseSelectionService.getCourseSelectionPage(pageNum, pageSize, courseType, semester));
    }

    @PostMapping("/select/{courseId}")
    public Result<Void> selectCourse(@PathVariable Long courseId, HttpServletRequest request) {
        Long studentId = (Long) request.getAttribute("userId");
        String role = (String) request.getAttribute("role");
        if (!"student".equals(role)) {
            return Result.error(403, "仅学生可以选课");
        }
        try {
            courseSelectionService.selectCourse(courseId, studentId);
            return Result.success();
        } catch (RuntimeException e) {
            return Result.error(400, e.getMessage());
        }
    }

    @PostMapping("/drop/{courseId}")
    public Result<Void> dropCourse(@PathVariable Long courseId, HttpServletRequest request) {
        Long studentId = (Long) request.getAttribute("userId");
        String role = (String) request.getAttribute("role");
        if (!"student".equals(role)) {
            return Result.error(403, "仅学生可以退课");
        }
        try {
            courseSelectionService.dropCourse(courseId, studentId);
            return Result.success();
        } catch (RuntimeException e) {
            return Result.error(400, e.getMessage());
        }
    }

    @GetMapping("/my-courses")
    public Result<List<CourseSelectionRecord>> myCourses(HttpServletRequest request) {
        Long studentId = (Long) request.getAttribute("userId");
        LambdaQueryWrapper<CourseSelectionRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CourseSelectionRecord::getStudentId, studentId)
               .eq(CourseSelectionRecord::getStatus, 1);
        List<CourseSelectionRecord> records = recordMapper.selectList(wrapper);
        // 填充课程信息
        records.forEach(r -> r.setCourse(courseSelectionService.getById(r.getCourseId())));
        return Result.success(records);
    }

    @PostMapping("/add")
    public Result<Void> add(@RequestBody CourseSelection course, HttpServletRequest request) {
        String role = (String) request.getAttribute("role");
        if (!"admin".equals(role)) {
            return Result.error(403, "权限不足");
        }
        courseSelectionService.save(course);
        return Result.success();
    }

    @PutMapping("/update")
    public Result<Void> update(@RequestBody CourseSelection course, HttpServletRequest request) {
        String role = (String) request.getAttribute("role");
        if (!"admin".equals(role)) {
            return Result.error(403, "权限不足");
        }
        courseSelectionService.updateById(course);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id, HttpServletRequest request) {
        String role = (String) request.getAttribute("role");
        if (!"admin".equals(role)) {
            return Result.error(403, "权限不足");
        }
        courseSelectionService.removeById(id);
        return Result.success();
    }
}
