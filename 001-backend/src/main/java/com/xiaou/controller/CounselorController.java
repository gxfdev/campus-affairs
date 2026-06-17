package com.xiaou.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.xiaou.common.Result;
import com.xiaou.entity.Counselor;
import com.xiaou.service.CounselorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;

@RestController
@RequestMapping("/api/counselor")
public class CounselorController {

    @Autowired
    private CounselorService counselorService;

    @GetMapping("/list")
    public Result<Page<Counselor>> list(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String college,
            @RequestParam(required = false) Integer grade) {
        return Result.success(counselorService.getCounselorPage(pageNum, pageSize, college, grade));
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
