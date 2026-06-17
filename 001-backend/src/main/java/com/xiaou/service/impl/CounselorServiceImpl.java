package com.xiaou.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiaou.entity.Counselor;
import com.xiaou.entity.User;
import com.xiaou.mapper.CounselorMapper;
import com.xiaou.mapper.UserMapper;
import com.xiaou.service.CounselorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class CounselorServiceImpl extends ServiceImpl<CounselorMapper, Counselor> implements CounselorService {

    @Autowired
    private UserMapper userMapper;

    @Override
    public Page<Counselor> getCounselorPage(int pageNum, int pageSize, String college, Integer grade) {
        Page<Counselor> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<Counselor> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(college)) {
            wrapper.eq(Counselor::getCollege, college);
        }
        if (grade != null) {
            wrapper.eq(Counselor::getGrade, grade);
        }
        wrapper.orderByDesc(Counselor::getCreateTime);
        Page<Counselor> result = this.page(page, wrapper);
        // 填充用户信息
        result.getRecords().forEach(c -> {
            User user = userMapper.selectById(c.getUserId());
            c.setUser(user);
        });
        return result;
    }

    @Override
    public Counselor getByUserId(Long userId) {
        LambdaQueryWrapper<Counselor> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Counselor::getUserId, userId);
        return getOne(wrapper);
    }
}
