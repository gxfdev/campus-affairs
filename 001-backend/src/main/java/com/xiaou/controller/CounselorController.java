package com.xiaou.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.xiaou.common.Result;
import com.xiaou.entity.Counselor;
import com.xiaou.entity.User;
import com.xiaou.service.CounselorService;
import com.xiaou.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.List;

@RestController
@RequestMapping("/api/counselor")
public class CounselorController {

    @Autowired
    private CounselorService counselorService;

    @Autowired
    private UserService userService;

    @GetMapping("/list")
    public Result<Page<Counselor>> list(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String college,
            @RequestParam(required = false) Integer grade) {
        return Result.success(counselorService.getCounselorPage(pageNum, pageSize, college, grade));
    }

    /**
     * 辅导员获取自己负责的学生列表
     */
    @GetMapping("/my-students")
    public Result<Page<User>> myStudents(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String keyword,
            HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        String role = (String) request.getAttribute("role");
        
        if (!"counselor".equals(role)) {
            return Result.error(403, "只有辅导员可以查看自己负责的学生");
        }
        
        Counselor counselor = counselorService.getByUserId(userId);
        if (counselor == null) {
            return Result.error(403, "辅导员信息不存在");
        }
        
        Page<User> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getCounselorId, counselor.getId());
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like(User::getRealName, keyword)
                    .or().like(User::getStudentNo, keyword)
                    .or().like(User::getClassName, keyword));
        }
        wrapper.orderByAsc(User::getClassName, User::getStudentNo);
        Page<User> result = userService.page(page, wrapper);
        // 隐藏密码
        result.getRecords().forEach(u -> u.setPassword(null));
        return Result.success(result);
    }

    /**
     * 辅导员获取自己负责的所有学生（不分页）
     */
    @GetMapping("/all-my-students")
    public Result<List<User>> allMyStudents(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        String role = (String) request.getAttribute("role");
        
        if (!"counselor".equals(role)) {
            return Result.error(403, "只有辅导员可以查看自己负责的学生");
        }
        
        Counselor counselor = counselorService.getByUserId(userId);
        if (counselor == null) {
            return Result.error(403, "辅导员信息不存在");
        }
        
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getCounselorId, counselor.getId());
        wrapper.orderByAsc(User::getClassName, User::getStudentNo);
        List<User> students = userService.list(wrapper);
        students.forEach(u -> u.setPassword(null));
        return Result.success(students);
    }

    /**
     * 获取辅导员自己的信息
     */
    @GetMapping("/my-info")
    public Result<Counselor> myInfo(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        String role = (String) request.getAttribute("role");
        
        if (!"counselor".equals(role)) {
            return Result.error(403, "只有辅导员可以查看此信息");
        }
        
        Counselor counselor = counselorService.getByUserId(userId);
        if (counselor != null) {
            counselor.setUser(userService.getById(counselor.getUserId()));
        }
        return Result.success(counselor);
    }

    /**
     * 获取所有学院列表
     */
    @GetMapping("/colleges")
    public Result<List<String>> getColleges() {
        LambdaQueryWrapper<Counselor> wrapper = new LambdaQueryWrapper<>();
        wrapper.select(Counselor::getCollege).groupBy(Counselor::getCollege);
        List<Counselor> counselors = counselorService.list(wrapper);
        List<String> colleges = counselors.stream().map(Counselor::getCollege).distinct().toList();
        return Result.success(colleges);
    }

    @PostMapping("/add")
    public Result<Void> add(@RequestBody Counselor counselor, HttpServletRequest request) {
        String role = (String) request.getAttribute("role");
        if (!"admin".equals(role)) {
            return Result.error(403, "权限不足");
        }
        counselorService.save(counselor);
        return Result.success();
    }

    @PutMapping("/update")
    public Result<Void> update(@RequestBody Counselor counselor, HttpServletRequest request) {
        String role = (String) request.getAttribute("role");
        if (!"admin".equals(role)) {
            return Result.error(403, "权限不足");
        }
        counselorService.updateById(counselor);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id, HttpServletRequest request) {
        String role = (String) request.getAttribute("role");
        if (!"admin".equals(role)) {
            return Result.error(403, "权限不足");
        }
        counselorService.removeById(id);
        return Result.success();
    }
}
