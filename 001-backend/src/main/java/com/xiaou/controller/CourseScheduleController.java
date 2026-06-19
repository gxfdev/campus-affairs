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
            @RequestParam(required = false) String semester,
            @RequestParam(required = false, defaultValue = "0") int week) {
        List<CourseSchedule> list = courseScheduleService.getScheduleByClass(className, semester);
        // 如果指定了周次，过滤出该周有课的课程
        if (week > 0) {
            list = list.stream()
                .filter(c -> c.getWeekStart() != null && c.getWeekEnd() != null
                    && week >= c.getWeekStart() && week <= c.getWeekEnd())
                .collect(java.util.stream.Collectors.toList());
        }
        return Result.success(list);
    }

    /**
     * 获取班级所有学期列表
     */
    @GetMapping("/semesters/{className}")
    public Result<List<String>> getSemesters(@PathVariable String className) {
        LambdaQueryWrapper<CourseSchedule> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CourseSchedule::getClassName, className);
        wrapper.select(CourseSchedule::getSemester);
        wrapper.groupBy(CourseSchedule::getSemester);
        wrapper.orderByDesc(CourseSchedule::getSemester);
        List<CourseSchedule> list = courseScheduleService.list(wrapper);
        List<String> semesters = list.stream()
            .map(CourseSchedule::getSemester)
            .distinct()
            .sorted((a, b) -> b.compareTo(a))
            .toList();
        return Result.success(semesters);
    }

    /**
     * 获取自己的课程表（学生查看本班课表）
     */
    @GetMapping("/my-schedule")
    public Result<List<CourseSchedule>> getMySchedule(
            @RequestParam(required = false) String semester,
            HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        String role = (String) request.getAttribute("role");

        User user = userService.getById(userId);
        if (user == null || user.getClassName() == null) {
            return Result.error(400, "用户信息不完整，未关联班级");
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
        wrapper.isNotNull(User::getClassName).ne(User::getClassName, "");
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
        wrapper.isNotNull(User::getMajor).ne(User::getMajor, "");
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
        wrapper.isNotNull(User::getCollege).ne(User::getCollege, "");
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
        // 参数校验
        if (schedule.getClassName() == null || schedule.getClassName().trim().isEmpty()) {
            return Result.error(400, "班级名称不能为空");
        }
        if (schedule.getCourseName() == null || schedule.getCourseName().trim().isEmpty()) {
            return Result.error(400, "课程名称不能为空");
        }
        if (schedule.getDayOfWeek() == null || schedule.getDayOfWeek() < 1 || schedule.getDayOfWeek() > 7) {
            return Result.error(400, "星期参数无效");
        }
        if (schedule.getPeriodStart() == null || schedule.getPeriodEnd() == null
            || schedule.getPeriodStart() >= schedule.getPeriodEnd()) {
            return Result.error(400, "节次参数无效，开始节次必须小于结束节次");
        }
        // 设置默认周次（整学期1-20周）
        if (schedule.getWeekStart() == null) schedule.setWeekStart(1);
        if (schedule.getWeekEnd() == null) schedule.setWeekEnd(20);
        if (schedule.getWeekStart() < 1 || schedule.getWeekEnd() > 20 || schedule.getWeekStart() > schedule.getWeekEnd()) {
            return Result.error(400, "周次参数无效");
        }

        // 检查时间冲突：同一班级、同一天、节次重叠、周次重叠
        LambdaQueryWrapper<CourseSchedule> conflictWrapper = new LambdaQueryWrapper<>();
        conflictWrapper.eq(CourseSchedule::getClassName, schedule.getClassName());
        conflictWrapper.eq(CourseSchedule::getDayOfWeek, schedule.getDayOfWeek());
        conflictWrapper.eq(CourseSchedule::getDeleted, 0);
        if (schedule.getSemester() != null) {
            conflictWrapper.eq(CourseSchedule::getSemester, schedule.getSemester());
        }
        // 节次重叠：newStart < existingEnd AND newEnd > existingStart
        conflictWrapper.lt(CourseSchedule::getPeriodStart, schedule.getPeriodEnd());
        conflictWrapper.gt(CourseSchedule::getPeriodEnd, schedule.getPeriodStart());
        // 周次重叠：newWeekStart <= existingWeekEnd AND newWeekEnd >= existingWeekStart
        conflictWrapper.le(CourseSchedule::getWeekStart, schedule.getWeekEnd());
        conflictWrapper.ge(CourseSchedule::getWeekEnd, schedule.getWeekStart());

        long conflictCount = courseScheduleService.count(conflictWrapper);
        if (conflictCount > 0) {
            return Result.error(400, "时间冲突：该时段已有其他课程，请检查课表");
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
