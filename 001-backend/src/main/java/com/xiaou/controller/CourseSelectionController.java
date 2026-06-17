package com.xiaou.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.xiaou.common.Result;
import com.xiaou.entity.Counselor;
import com.xiaou.entity.CourseSelection;
import com.xiaou.entity.CourseSelectionRecord;
import com.xiaou.entity.User;
import com.xiaou.mapper.CourseSelectionRecordMapper;
import com.xiaou.service.CounselorService;
import com.xiaou.service.CourseSelectionService;
import com.xiaou.service.UserService;
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

    @Autowired
    private CounselorService counselorService;

    @Autowired
    private UserService userService;

    @GetMapping("/list")
    public Result<Page<CourseSelection>> list(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String courseType,
            @RequestParam(required = false) String semester,
            HttpServletRequest request) {
        String role = (String) request.getAttribute("role");
        Long userId = (Long) request.getAttribute("userId");
        
        Page<CourseSelection> page = courseSelectionService.getCourseSelectionPage(pageNum, pageSize, courseType, semester);
        
        // 辅导员只能看到自己学院和年级的选课
        if ("counselor".equals(role)) {
            Counselor counselor = counselorService.getByUserId(userId);
            if (counselor != null) {
                // 过滤结果
                page.getRecords().removeIf(c -> 
                    !counselor.getCollege().equals(c.getCollege()) || 
                    !counselor.getGrade().equals(c.getGrade()));
            }
        }
        
        return Result.success(page);
    }

    /**
     * 辅导员开放选课
     */
    @PostMapping("/open/{courseId}")
    public Result<Void> openCourseSelection(@PathVariable Long courseId, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        String role = (String) request.getAttribute("role");
        
        if (!"counselor".equals(role) && !"admin".equals(role)) {
            return Result.error(403, "只有辅导员或管理员可以开放选课");
        }
        
        CourseSelection course = courseSelectionService.getById(courseId);
        if (course == null) {
            return Result.error(404, "课程不存在");
        }
        
        // 辅导员只能开放自己学院和年级的选课
        if ("counselor".equals(role)) {
            Counselor counselor = counselorService.getByUserId(userId);
            if (counselor == null) {
                return Result.error(403, "辅导员信息不存在");
            }
            if (!counselor.getCollege().equals(course.getCollege()) || 
                !counselor.getGrade().equals(course.getGrade())) {
                return Result.error(403, "您没有权限开放该课程的选课，只能开放自己负责学院和年级的课程");
            }
        }
        
        course.setIsOpen(1);
        course.setOpenedBy(userId);
        courseSelectionService.updateById(course);
        return Result.success();
    }

    /**
     * 辅导员关闭选课
     */
    @PostMapping("/close/{courseId}")
    public Result<Void> closeCourseSelection(@PathVariable Long courseId, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        String role = (String) request.getAttribute("role");
        
        if (!"counselor".equals(role) && !"admin".equals(role)) {
            return Result.error(403, "只有辅导员或管理员可以关闭选课");
        }
        
        CourseSelection course = courseSelectionService.getById(courseId);
        if (course == null) {
            return Result.error(404, "课程不存在");
        }
        
        if ("counselor".equals(role)) {
            Counselor counselor = counselorService.getByUserId(userId);
            if (counselor == null || !counselor.getCollege().equals(course.getCollege()) || 
                !counselor.getGrade().equals(course.getGrade())) {
                return Result.error(403, "您没有权限关闭该课程的选课");
            }
        }
        
        course.setIsOpen(0);
        courseSelectionService.updateById(course);
        return Result.success();
    }

    @PostMapping("/select/{courseId}")
    public Result<Void> selectCourse(@PathVariable Long courseId, HttpServletRequest request) {
        Long studentId = (Long) request.getAttribute("userId");
        String role = (String) request.getAttribute("role");
        if (!"student".equals(role)) {
            return Result.error(403, "仅学生可以选课");
        }
        
        // 检查课程是否已开放选课
        CourseSelection course = courseSelectionService.getById(courseId);
        if (course == null) {
            return Result.error(404, "课程不存在");
        }
        if (course.getIsOpen() == null || course.getIsOpen() != 1) {
            return Result.error(400, "该课程尚未开放选课，请等待辅导员开放");
        }
        
        // 检查学生是否属于该课程开放的学院和年级
        User student = userService.getById(studentId);
        if (student == null) {
            return Result.error(403, "学生信息不存在");
        }
        if (course.getCollege() != null && !course.getCollege().equals(student.getCollege())) {
            return Result.error(403, "该课程不面向您所在的学院");
        }
        if (course.getGrade() != null && !course.getGrade().equals(student.getGrade())) {
            return Result.error(403, "该课程不面向您所在的年级");
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
        records.forEach(r -> r.setCourse(courseSelectionService.getById(r.getCourseId())));
        return Result.success(records);
    }

    @PostMapping("/add")
    public Result<Void> add(@RequestBody CourseSelection course, HttpServletRequest request) {
        String role = (String) request.getAttribute("role");
        if (!"admin".equals(role) && !"counselor".equals(role)) {
            return Result.error(403, "权限不足");
        }
        course.setIsOpen(0);
        courseSelectionService.save(course);
        return Result.success();
    }

    @PutMapping("/update")
    public Result<Void> update(@RequestBody CourseSelection course, HttpServletRequest request) {
        String role = (String) request.getAttribute("role");
        if (!"admin".equals(role) && !"counselor".equals(role)) {
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
