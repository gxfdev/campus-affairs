package com.xiaou.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiaou.entity.Score;
import com.xiaou.entity.User;
import com.xiaou.mapper.ScoreMapper;
import com.xiaou.mapper.UserMapper;
import com.xiaou.service.ScoreService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ScoreServiceImpl extends ServiceImpl<ScoreMapper, Score> implements ScoreService {

    @Autowired
    private UserMapper userMapper;

    @Override
    public Page<Score> getScorePage(int pageNum, int pageSize, Long studentId, String semester, String courseType) {
        Page<Score> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<Score> wrapper = new LambdaQueryWrapper<>();
        if (studentId != null) {
            wrapper.eq(Score::getStudentId, studentId);
        }
        if (StringUtils.hasText(semester)) {
            wrapper.eq(Score::getSemester, semester);
        }
        if (StringUtils.hasText(courseType)) {
            wrapper.eq(Score::getCourseType, courseType);
        }
        wrapper.orderByDesc(Score::getCreateTime);
        Page<Score> result = this.page(page, wrapper);
        // 填充学生信息
        result.getRecords().forEach(s -> {
            User student = userMapper.selectById(s.getStudentId());
            s.setStudent(student);
        });
        return result;
    }

    @Override
    public Page<Score> getScoreByCounselor(int pageNum, int pageSize, Long counselorId, String semester, String courseType) {
        // 获取该辅导员负责的所有学生ID
        LambdaQueryWrapper<User> userWrapper = new LambdaQueryWrapper<>();
        userWrapper.eq(User::getCounselorId, counselorId);
        List<User> students = userMapper.selectList(userWrapper);
        List<Long> studentIds = students.stream().map(User::getId).collect(Collectors.toList());
        
        Page<Score> page = new Page<>(pageNum, pageSize);
        if (studentIds.isEmpty()) {
            return page;
        }
        
        LambdaQueryWrapper<Score> wrapper = new LambdaQueryWrapper<>();
        wrapper.in(Score::getStudentId, studentIds);
        if (StringUtils.hasText(semester)) {
            wrapper.eq(Score::getSemester, semester);
        }
        if (StringUtils.hasText(courseType)) {
            wrapper.eq(Score::getCourseType, courseType);
        }
        wrapper.orderByDesc(Score::getCreateTime);
        Page<Score> result = this.page(page, wrapper);
        // 填充学生信息
        result.getRecords().forEach(s -> {
            User student = userMapper.selectById(s.getStudentId());
            s.setStudent(student);
        });
        return result;
    }
}
