package com.xiaou.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiaou.common.BusinessException;
import com.xiaou.entity.Counselor;
import com.xiaou.entity.LeaveRequest;
import com.xiaou.entity.User;
import com.xiaou.mapper.LeaveRequestMapper;
import com.xiaou.service.CounselorService;
import com.xiaou.service.LeaveRequestService;
import com.xiaou.service.UserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 请假申请Service实现类
 * @author xiaou
 */
@Slf4j
@Service
public class LeaveRequestServiceImpl extends ServiceImpl<LeaveRequestMapper, LeaveRequest> implements LeaveRequestService {
    
    @Autowired
    private UserService userService;
    
    @Autowired
    private CounselorService counselorService;
    
    @Override
    public void submitLeaveRequest(LeaveRequest leaveRequest) {
        // 参数校验
        if (leaveRequest.getStartTime() == null || leaveRequest.getEndTime() == null) {
            throw new BusinessException("开始时间和结束时间不能为空");
        }
        if (leaveRequest.getReason() == null || leaveRequest.getReason().trim().isEmpty()) {
            throw new BusinessException("请假理由不能为空");
        }
        if (!leaveRequest.getEndTime().isAfter(leaveRequest.getStartTime())) {
            throw new BusinessException("结束时间必须晚于开始时间");
        }
        if (leaveRequest.getStartTime().isBefore(LocalDateTime.now().minusHours(1))) {
            throw new BusinessException("开始时间不能早于当前时间");
        }

        // 检查时间重叠：同一学生不能在重叠时间段内有多条有效请假（待审批或已通过）
        LambdaQueryWrapper<LeaveRequest> overlapWrapper = new LambdaQueryWrapper<>();
        overlapWrapper.eq(LeaveRequest::getStudentId, leaveRequest.getStudentId());
        overlapWrapper.in(LeaveRequest::getStatus, 0, 1); // 待审批或已通过
        overlapWrapper.lt(LeaveRequest::getStartTime, leaveRequest.getEndTime());
        overlapWrapper.gt(LeaveRequest::getEndTime, leaveRequest.getStartTime());
        long overlapCount = count(overlapWrapper);
        if (overlapCount > 0) {
            throw new BusinessException("该时间段内已存在请假申请，请勿重复提交");
        }

        long days = Duration.between(leaveRequest.getStartTime(), leaveRequest.getEndTime()).toDays();
        leaveRequest.setDays((int) days + 1);
        leaveRequest.setStatus(0);
        save(leaveRequest);
    }
    
    @Override
    public void approveLeaveRequest(Long id, Long approverId, Integer status, String comment) {
        LeaveRequest leaveRequest = getById(id);
        if (leaveRequest == null) {
            throw new BusinessException("请假申请不存在");
        }
        if (leaveRequest.getStatus() != 0) {
            throw new BusinessException("该申请已处理");
        }
        leaveRequest.setApproverId(approverId);
        leaveRequest.setStatus(status);
        leaveRequest.setApprovalComment(comment);
        leaveRequest.setApprovalTime(LocalDateTime.now());
        updateById(leaveRequest);
    }
    
    @Override
    public Page<LeaveRequest> getLeaveRequestPage(int pageNum, int pageSize, Long studentId, Integer status) {
        Page<LeaveRequest> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<LeaveRequest> wrapper = new LambdaQueryWrapper<>();
        if (studentId != null) {
            wrapper.eq(LeaveRequest::getStudentId, studentId);
        }
        if (status != null) {
            wrapper.eq(LeaveRequest::getStatus, status);
        }
        wrapper.orderByDesc(LeaveRequest::getCreateTime);
        Page<LeaveRequest> resultPage = page(page, wrapper);
        fillStudentAndApproverInfo(resultPage);
        return resultPage;
    }
    
    @Override
    public Page<LeaveRequest> getLeaveRequestByCounselor(int pageNum, int pageSize, Long counselorId, Integer status) {
        // 获取该辅导员负责的所有学生ID
        LambdaQueryWrapper<User> userWrapper = new LambdaQueryWrapper<>();
        userWrapper.eq(User::getCounselorId, counselorId);
        List<User> students = userService.list(userWrapper);
        List<Long> studentIds = students.stream().map(User::getId).collect(Collectors.toList());
        
        Page<LeaveRequest> page = new Page<>(pageNum, pageSize);
        if (studentIds.isEmpty()) {
            return page;
        }
        
        LambdaQueryWrapper<LeaveRequest> wrapper = new LambdaQueryWrapper<>();
        wrapper.in(LeaveRequest::getStudentId, studentIds);
        if (status != null) {
            wrapper.eq(LeaveRequest::getStatus, status);
        }
        wrapper.orderByDesc(LeaveRequest::getCreateTime);
        Page<LeaveRequest> resultPage = page(page, wrapper);
        fillStudentAndApproverInfo(resultPage);
        return resultPage;
    }
    
    private void fillStudentAndApproverInfo(Page<LeaveRequest> resultPage) {
        if (resultPage.getRecords().isEmpty()) {
            return;
        }
        // 收集所有学生ID和审批人ID
        List<Long> userIds = new java.util.ArrayList<>();
        for (LeaveRequest record : resultPage.getRecords()) {
            if (record.getStudentId() != null) userIds.add(record.getStudentId());
            if (record.getApproverId() != null) userIds.add(record.getApproverId());
        }
        if (userIds.isEmpty()) return;
        // 批量查询用户信息，避免N+1查询
        List<User> users = userService.listByIds(userIds);
        Map<Long, User> userMap = users.stream()
                .collect(Collectors.toMap(User::getId, u -> u));
        
        for (LeaveRequest record : resultPage.getRecords()) {
            User student = userMap.get(record.getStudentId());
            if (student != null) {
                record.setStudentName(student.getRealName() != null ? student.getRealName() : student.getUsername());
            }
            if (record.getApproverId() != null) {
                User approver = userMap.get(record.getApproverId());
                if (approver != null) {
                    record.setApproverName(approver.getRealName() != null ? approver.getRealName() : approver.getUsername());
                }
            }
        }
    }
    
    @Override
    public Object getLeaveStatistics() {
        Map<String, Object> statistics = new HashMap<>();
        LambdaQueryWrapper<LeaveRequest> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(LeaveRequest::getStatus, 0);
        long pendingCount = count(wrapper);
        wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(LeaveRequest::getStatus, 1);
        long approvedCount = count(wrapper);
        wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(LeaveRequest::getStatus, 2);
        long rejectedCount = count(wrapper);
        statistics.put("pendingCount", pendingCount);
        statistics.put("approvedCount", approvedCount);
        statistics.put("rejectedCount", rejectedCount);
        statistics.put("totalCount", pendingCount + approvedCount + rejectedCount);
        return statistics;
    }
}

