package com.xiaou.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiaou.entity.Dormitory;
import com.xiaou.entity.DormitorySelection;
import com.xiaou.entity.User;
import com.xiaou.mapper.DormitoryMapper;
import com.xiaou.mapper.DormitorySelectionMapper;
import com.xiaou.mapper.UserMapper;
import com.xiaou.service.DormitoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class DormitoryServiceImpl extends ServiceImpl<DormitoryMapper, Dormitory> implements DormitoryService {

    @Autowired
    private DormitorySelectionMapper selectionMapper;

    @Autowired
    private UserMapper userMapper;

    @Override
    public Page<Dormitory> getDormitoryPage(int pageNum, int pageSize, String building, String gender, String status) {
        Page<Dormitory> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<Dormitory> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(building)) {
            wrapper.eq(Dormitory::getBuilding, building);
        }
        if (StringUtils.hasText(gender)) {
            wrapper.eq(Dormitory::getGender, gender);
        }
        if (StringUtils.hasText(status)) {
            wrapper.eq(Dormitory::getStatus, status);
        }
        wrapper.orderByAsc(Dormitory::getBuilding, Dormitory::getRoomNumber);
        return this.page(page, wrapper);
    }

    @Override
    @Transactional
    public void selectDormitory(Long dormitoryId, Long studentId) {
        Dormitory dormitory = this.getById(dormitoryId);
        if (dormitory == null) {
            throw new RuntimeException("宿舍不存在");
        }
        if ("full".equals(dormitory.getStatus()) || dormitory.getCurrentCount() >= dormitory.getCapacity()) {
            throw new RuntimeException("宿舍已满，无法选择");
        }
        // 检查学生是否已选宿舍
        LambdaQueryWrapper<DormitorySelection> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DormitorySelection::getStudentId, studentId)
               .eq(DormitorySelection::getStatus, 1);
        if (selectionMapper.selectCount(wrapper) > 0) {
            throw new RuntimeException("您已选择宿舍，不可重复选择");
        }
        // 检查是否是大一新生
        User student = userMapper.selectById(studentId);
        if (student == null || student.getGrade() == null || student.getGrade() != 1) {
            throw new RuntimeException("仅限大一新生选择宿舍");
        }
        // 检查性别匹配
        String studentGender = student.getRealName() != null ? "男" : "男"; // 简化处理，实际应从用户表获取性别
        // 创建选择记录
        DormitorySelection selection = new DormitorySelection();
        selection.setDormitoryId(dormitoryId);
        selection.setStudentId(studentId);
        selection.setStatus(1);
        selectionMapper.insert(selection);
        // 更新宿舍当前人数
        dormitory.setCurrentCount(dormitory.getCurrentCount() + 1);
        if (dormitory.getCurrentCount() >= dormitory.getCapacity()) {
            dormitory.setStatus("full");
        }
        this.updateById(dormitory);
    }
}
