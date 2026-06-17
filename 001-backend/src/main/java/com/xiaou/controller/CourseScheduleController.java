package com.xiaou.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.xiaou.common.Result;
import com.xiaou.entity.CourseSchedule;
import com.xiaou.entity.User;
import com.xiaou.service.CourseScheduleService;
import com.xiaou.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.List;

@RestController
@RequestMapping("/api/course-schedule")
public class CourseScheduleController {

    @Autowired
    private CourseScheduleService courseScheduleService;

    @Autowired
    private UserService userService;

    @GetMapping("/list")
    public Result<Page<CourseSchedule>> list(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String className,
            @RequestParam(required = false) String semester) {
        return Result.success(courseScheduleService.getSchedulePage(pageNum, pageSize, className, semester));
    }

    @GetMapping("/class/{className}")
    public Result<List<CourseSchedule>> getByClass(
            @PathVariable String className,
            @RequestParam(required = false) String semester) {
        return Result.success(courseScheduleService.getScheduleByClass(className, semester));
    }

    /**
     * 学生获取自己的课程表
     */
    @GetMapping("/my-schedule")
    public Result<List<CourseSchedule>> getMySchedule(
            @RequestParam(required = false) String semester,
            HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        String role = (String) request.getAttribute("role");
        
        if (!"student".equals(role)) {
            return Result.error(403, "仅学生可以查看自己的课程表");
        }
        
        User user = userService.getById(userId);
        if (user == null || user.getClassName() == null) {
            return Result.error(400, "学生信息不完整");
        }
        
        return Result.success(courseScheduleService.getScheduleByClass(user.getClassName(), semester));
    }

    /**
     * 获取所有班级列表
     */
    @GetMapping("/classes")
    public Result<List<String>> getClasses(
            @RequestParam(required = false) String college,
            @RequestParam(required = false) String major,
            @RequestParam(required = false) Integer grade) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getRole, "student");
        if (college != null && !college.isEmpty()) {
            wrapper.eq(User::getCollege, college);
        }
        if (major != null && !major.isEmpty()) {
            wrapper.eq(User::getMajor, major);
        }
        if (grade != null) {
            wrapper.eq(User::getGrade, grade);
        }
        wrapper.select(User::getClassName).groupBy(User::getClassName);
        List<User> users = userService.list(wrapper);
        List<String> classes = users.stream()
            .map(User::getClassName)
            .filter(c -> c != null && !c.isEmpty())
            .distinct()
            .sorted()
            .toList();
        return Result.success(classes);
    }

    /**
     * 获取专业列表
     */
    @GetMapping("/majors")
    public Result<List<String>> getMajors(
            @RequestParam(required = false) String college) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getRole, "student");
        if (college != null && !college.isEmpty()) {
            wrapper.eq(User::getCollege, college);
        }
        wrapper.select(User::getMajor).groupBy(User::getMajor);
        List<User> users = userService.list(wrapper);
        List<String> majors = users.stream()
            .map(User::getMajor)
            .filter(m -> m != null && !m.isEmpty())
            .distinct()
            .sorted()
            .toList();
        return Result.success(majors);
    }

    /**
     * 获取学院列表
     */
    @GetMapping("/colleges")
    public Result<List<String>> getColleges() {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getRole, "student");
        wrapper.select(User::getCollege).groupBy(User::getCollege);
        List<User> users = userService.list(wrapper);
        List<String> colleges = users.stream()
            .map(User::getCollege)
            .filter(c -> c != null && !c.isEmpty())
            .distinct()
            .sorted()
            .toList();
        return Result.success(colleges);
    }

    @PostMapping("/add")
    public Result<Void> add(@RequestBody CourseSchedule schedule, HttpServletRequest request) {
        String role = (String) request.getAttribute("role");
        if (!"admin".equals(role) && !"counselor".equals(role)) {
            return Result.error(403, "权限不足");
        }
        courseScheduleService.save(schedule);
        return Result.success();
    }

    @PutMapping("/update")
    public Result<Void> update(@RequestBody CourseSchedule schedule, HttpServletRequest request) {
        String role = (String) request.getAttribute("role");
        if (!"admin".equals(role) && !"counselor".equals(role)) {
            return Result.error(403, "权限不足");
        }
        courseScheduleService.updateById(schedule);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id, HttpServletRequest request) {
        String role = (String) request.getAttribute("role");
        if (!"admin".equals(role)) {
            return Result.error(403, "权限不足");
        }
        courseScheduleService.removeById(id);
        return Result.success();
    }
}
