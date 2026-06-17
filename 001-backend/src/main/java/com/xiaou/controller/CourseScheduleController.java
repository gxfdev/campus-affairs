package com.xiaou.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.xiaou.common.Result;
import com.xiaou.entity.CourseSchedule;
import com.xiaou.service.CourseScheduleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.List;

@RestController
@RequestMapping("/api/course-schedule")
public class CourseScheduleController {

    @Autowired
    private CourseScheduleService courseScheduleService;

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

    @PostMapping("/add")
    public Result<Void> add(@RequestBody CourseSchedule schedule, HttpServletRequest request) {
        String role = (String) request.getAttribute("role");
        if (!"admin".equals(role) && !"teacher".equals(role)) {
            return Result.error(403, "权限不足");
        }
        courseScheduleService.save(schedule);
        return Result.success();
    }

    @PutMapping("/update")
    public Result<Void> update(@RequestBody CourseSchedule schedule, HttpServletRequest request) {
        String role = (String) request.getAttribute("role");
        if (!"admin".equals(role) && !"teacher".equals(role)) {
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
