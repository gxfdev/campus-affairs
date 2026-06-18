package com.xiaou.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.xiaou.common.Result;
import com.xiaou.entity.Counselor;
import com.xiaou.entity.LeaveRequest;
import com.xiaou.entity.User;
import com.xiaou.service.CounselorService;
import com.xiaou.service.LeaveRequestService;
import com.xiaou.service.UserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;

/**
 * 请假申请控制器
 * @author xiaou
 */
@Slf4j
@RestController
@RequestMapping("/api/leave")
public class LeaveRequestController {
    
    @Autowired
    private LeaveRequestService leaveRequestService;
    
    @Autowired
    private UserService userService;
    
    @Autowired
    private CounselorService counselorService;
    
    /**
     * 提交请假申请
     */
    @PostMapping("/apply")
    public Result<Void> submitLeaveRequest(@RequestBody LeaveRequest leaveRequest, 
                                           HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        String role = (String) request.getAttribute("role");
        
        // 只有学生可以提交请假申请
        if (!"student".equals(role)) {
            return Result.error(403, "只有学生可以提交请假申请");
        }
        
        leaveRequest.setStudentId(userId);
        leaveRequestService.submitLeaveRequest(leaveRequest);
        return Result.success();
    }
    
    /**
     * 分页查询请假申请列表
     */
    @GetMapping("/list")
    public Result<Page<LeaveRequest>> getLeaveRequestList(@RequestParam(defaultValue = "1") int pageNum,
                                                          @RequestParam(defaultValue = "10") int pageSize,
                                                          @RequestParam(required = false) Long studentId,
                                                          @RequestParam(required = false) Integer status,
                                                          HttpServletRequest request) {
        Long currentUserId = (Long) request.getAttribute("userId");
        String role = (String) request.getAttribute("role");
        
        // 学生只能查看自己的请假申请
        if ("student".equals(role)) {
            studentId = currentUserId;
        }
        
        // 辅导员只能查看自己负责的学生的请假申请
        if ("counselor".equals(role)) {
            // 获取辅导员信息
            Counselor counselor = counselorService.getByUserId(currentUserId);
            if (counselor != null) {
                // 通过service层筛选该辅导员负责的学生
                Page<LeaveRequest> page = leaveRequestService.getLeaveRequestByCounselor(
                    pageNum, pageSize, counselor.getId(), status);
                return Result.success(page);
            }
        }
        
        Page<LeaveRequest> page = leaveRequestService.getLeaveRequestPage(pageNum, pageSize, studentId, status);
        return Result.success(page);
    }
    
    /**
     * 审批请假申请 - 只有该学生的专属辅导员才能审批
     */
    @PostMapping("/approve")
    public Result<Void> approveLeaveRequest(@RequestBody ApprovalRequest request, 
                                            HttpServletRequest httpRequest) {
        Long approverId = (Long) httpRequest.getAttribute("userId");
        String role = (String) httpRequest.getAttribute("role");
        
        // 只有辅导员可以审批请假
        if (!"counselor".equals(role)) {
            return Result.error(403, "只有辅导员可以审批请假申请");
        }
        
        // 获取请假申请
        LeaveRequest leaveRequest = leaveRequestService.getById(request.getId());
        if (leaveRequest == null) {
            return Result.error(404, "请假申请不存在");
        }
        
        // 获取请假学生信息
        User student = userService.getById(leaveRequest.getStudentId());
        if (student == null) {
            return Result.error(404, "学生不存在");
        }
        
        // 获取审批辅导员信息，验证是否为该学生的专属辅导员
        Counselor counselor = counselorService.getByUserId(approverId);
        if (counselor == null) {
            return Result.error(403, "辅导员信息不存在");
        }
        if (!counselor.getId().equals(student.getCounselorId())) {
            return Result.error(403, "您没有权限审批该学生的请假申请，只有该学生的专属辅导员才能审批");
        }
        
        leaveRequestService.approveLeaveRequest(request.getId(), approverId, 
                                                request.getStatus(), request.getComment());
        return Result.success();
    }
    
    /**
     * 辅导员查询自己负责学生的请假列表
     */
    @GetMapping("/counselor/list")
    public Result<Page<LeaveRequest>> getCounselorLeaveList(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) Integer status,
            HttpServletRequest request) {
        Long currentUserId = (Long) request.getAttribute("userId");
        String role = (String) request.getAttribute("role");
        
        if (!"counselor".equals(role)) {
            return Result.error(403, "只有辅导员可以使用此接口");
        }
        
        Counselor counselor = counselorService.getByUserId(currentUserId);
        if (counselor == null) {
            return Result.error(403, "辅导员信息不存在");
        }
        
        Page<LeaveRequest> page = leaveRequestService.getLeaveRequestByCounselor(
            pageNum, pageSize, counselor.getId(), status);
        return Result.success(page);
    }

    /**
     * 获取请假统计数据
     */
    @GetMapping("/statistics")
    public Result<Object> getLeaveStatistics(HttpServletRequest request) {
        String role = (String) request.getAttribute("role");
        
        // 只有管理员可以查看统计数据
        if (!"admin".equals(role)) {
            return Result.error(403, "权限不足");
        }
        
        Object statistics = leaveRequestService.getLeaveStatistics();
        return Result.success(statistics);
    }
    
    /**
     * 审批请求实体
     */
    public static class ApprovalRequest {
        private Long id;
        private Integer status;
        private String comment;
        
        public Long getId() { return id; }
        public void setId(Long id) { this.id = id; }
        public Integer getStatus() { return status; }
        public void setStatus(Integer status) { this.status = status; }
        public String getComment() { return comment; }
        public void setComment(String comment) { this.comment = comment; }
    }
}
