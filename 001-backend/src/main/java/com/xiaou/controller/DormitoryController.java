package com.xiaou.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.xiaou.common.Result;
import com.xiaou.entity.Dormitory;
import com.xiaou.entity.DormitorySelection;
import com.xiaou.mapper.DormitorySelectionMapper;
import com.xiaou.service.DormitoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.List;

@RestController
@RequestMapping("/api/dormitory")
public class DormitoryController {

    @Autowired
    private DormitoryService dormitoryService;

    @Autowired
    private DormitorySelectionMapper selectionMapper;

    @GetMapping("/list")
    public Result<Page<Dormitory>> list(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String building,
            @RequestParam(required = false) String gender,
            @RequestParam(required = false) String status) {
        return Result.success(dormitoryService.getDormitoryPage(pageNum, pageSize, building, gender, status));
    }

    @PostMapping("/select/{dormitoryId}")
    public Result<Void> selectDormitory(@PathVariable Long dormitoryId, HttpServletRequest request) {
        Long studentId = (Long) request.getAttribute("userId");
        String role = (String) request.getAttribute("role");
        if (!"student".equals(role)) {
            return Result.error(403, "仅学生可以选择宿舍");
        }
        try {
            dormitoryService.selectDormitory(dormitoryId, studentId);
            return Result.success();
        } catch (RuntimeException e) {
            return Result.error(400, e.getMessage());
        }
    }

    @GetMapping("/my-dormitory")
    public Result<DormitorySelection> myDormitory(HttpServletRequest request) {
        Long studentId = (Long) request.getAttribute("userId");
        LambdaQueryWrapper<DormitorySelection> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DormitorySelection::getStudentId, studentId)
               .eq(DormitorySelection::getStatus, 1);
        DormitorySelection selection = selectionMapper.selectOne(wrapper);
        if (selection != null) {
            selection.setDormitory(dormitoryService.getById(selection.getDormitoryId()));
        }
        return Result.success(selection);
    }

    @PostMapping("/add")
    public Result<Void> add(@RequestBody Dormitory dormitory, HttpServletRequest request) {
        String role = (String) request.getAttribute("role");
        if (!"admin".equals(role)) {
            return Result.error(403, "权限不足");
        }
        dormitoryService.save(dormitory);
        return Result.success();
    }

    @PutMapping("/update")
    public Result<Void> update(@RequestBody Dormitory dormitory, HttpServletRequest request) {
        String role = (String) request.getAttribute("role");
        if (!"admin".equals(role)) {
            return Result.error(403, "权限不足");
        }
        dormitoryService.updateById(dormitory);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id, HttpServletRequest request) {
        String role = (String) request.getAttribute("role");
        if (!"admin".equals(role)) {
            return Result.error(403, "权限不足");
        }
        dormitoryService.removeById(id);
        return Result.success();
    }
}
