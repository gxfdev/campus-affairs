package com.xiaou.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.xiaou.common.Result;
import com.xiaou.entity.Score;
import com.xiaou.service.ScoreService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;

@RestController
@RequestMapping("/api/score")
public class ScoreController {

    @Autowired
    private ScoreService scoreService;

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
        return Result.success(scoreService.getScorePage(pageNum, pageSize, studentId, semester, courseType));
    }

    @PostMapping("/add")
    public Result<Void> add(@RequestBody Score score, HttpServletRequest request) {
        String role = (String) request.getAttribute("role");
        if (!"admin".equals(role) && !"teacher".equals(role)) {
            return Result.error(403, "权限不足");
        }
        scoreService.save(score);
        return Result.success();
    }

    @PutMapping("/update")
    public Result<Void> update(@RequestBody Score score, HttpServletRequest request) {
        String role = (String) request.getAttribute("role");
        if (!"admin".equals(role) && !"teacher".equals(role)) {
            return Result.error(403, "权限不足");
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
}
