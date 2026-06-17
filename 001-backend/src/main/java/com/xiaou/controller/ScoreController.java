package com.xiaou.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.xiaou.common.Result;
import com.xiaou.entity.Counselor;
import com.xiaou.entity.Score;
import com.xiaou.entity.User;
import com.xiaou.service.CounselorService;
import com.xiaou.service.ScoreService;
import com.xiaou.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/score")
public class ScoreController {

    @Autowired
    private ScoreService scoreService;

    @Autowired
    private UserService userService;

    @Autowired
    private CounselorService counselorService;

    @GetMapping("/list")
    public Result<Page<Score>> list(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) Long studentId,
            @RequestParam(required = false) String semester,
            @RequestParam(required = false) String courseType,
            HttpServletRequest request) {
        String role = (String) request.getAttribute("role");
        Long userId = (Long) request.getAttribute("userId");
        
        // 学生只能查看自己的成绩
        if ("student".equals(role)) {
            studentId = userId;
        }
        
        // 辅导员只能查看自己负责的学生的成绩
        if ("counselor".equals(role)) {
            Counselor counselor = counselorService.getByUserId(userId);
            if (counselor != null) {
                Page<Score> page = scoreService.getScoreByCounselor(pageNum, pageSize, counselor.getId(), semester, courseType);
                return Result.success(page);
            }
        }
        
        return Result.success(scoreService.getScorePage(pageNum, pageSize, studentId, semester, courseType));
    }

    /**
     * 辅导员添加成绩 - 只能为自己负责的学生添加
     */
    @PostMapping("/add")
    public Result<Void> add(@RequestBody Score score, HttpServletRequest request) {
        String role = (String) request.getAttribute("role");
        Long userId = (Long) request.getAttribute("userId");
        
        if (!"admin".equals(role) && !"counselor".equals(role)) {
            return Result.error(403, "权限不足，只有辅导员和管理员可以录入成绩");
        }
        
        // 辅导员只能为自己负责的学生录入成绩
        if ("counselor".equals(role)) {
            Counselor counselor = counselorService.getByUserId(userId);
            if (counselor == null) {
                return Result.error(403, "辅导员信息不存在");
            }
            User student = userService.getById(score.getStudentId());
            if (student == null) {
                return Result.error(404, "学生不存在");
            }
            if (!counselor.getId().equals(student.getCounselorId())) {
                return Result.error(403, "您只能为自己负责的学生录入成绩");
            }
        }
        
        scoreService.save(score);
        return Result.success();
    }

    /**
     * 辅导员更新成绩 - 只能更新自己负责学生的成绩
     */
    @PutMapping("/update")
    public Result<Void> update(@RequestBody Score score, HttpServletRequest request) {
        String role = (String) request.getAttribute("role");
        Long userId = (Long) request.getAttribute("userId");
        
        if (!"admin".equals(role) && !"counselor".equals(role)) {
            return Result.error(403, "权限不足");
        }
        
        if ("counselor".equals(role)) {
            Counselor counselor = counselorService.getByUserId(userId);
            if (counselor == null) {
                return Result.error(403, "辅导员信息不存在");
            }
            User student = userService.getById(score.getStudentId());
            if (student == null || !counselor.getId().equals(student.getCounselorId())) {
                return Result.error(403, "您只能更新自己负责学生的成绩");
            }
        }
        
        scoreService.updateById(score);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id, HttpServletRequest request) {
        String role = (String) request.getAttribute("role");
        if (!"admin".equals(role)) {
            return Result.error(403, "权限不足");
        }
        scoreService.removeById(id);
        return Result.success();
    }

    /**
     * 辅导员查询自己负责学生的成绩
     */
    @GetMapping("/counselor/list")
    public Result<Page<Score>> counselorList(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String semester,
            @RequestParam(required = false) String courseType,
            HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        String role = (String) request.getAttribute("role");
        
        if (!"counselor".equals(role)) {
            return Result.error(403, "只有辅导员可以使用此接口");
        }
        
        Counselor counselor = counselorService.getByUserId(userId);
        if (counselor == null) {
            return Result.error(403, "辅导员信息不存在");
        }
        
        return Result.success(scoreService.getScoreByCounselor(pageNum, pageSize, counselor.getId(), semester, courseType));
    }
}
