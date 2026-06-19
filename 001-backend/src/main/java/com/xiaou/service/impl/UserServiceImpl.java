package com.xiaou.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiaou.common.BusinessException;
import com.xiaou.entity.User;
import com.xiaou.mapper.UserMapper;
import com.xiaou.service.UserService;
import com.xiaou.utils.JwtUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.DigestUtils;

import java.util.Map;

/**
 * 用户Service实现类
 * @author xiaou
 */
@Slf4j
@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {
    
    @Autowired
    private JwtUtil jwtUtil;
    
    @Override
    public String login(String username, String password) {
        // 查询用户
        User user = getUserByUsername(username);
        if (user == null) {
            throw new BusinessException("用户名或密码错误");
        }
        
        // 验证密码
        String md5Password = DigestUtils.md5DigestAsHex(password.getBytes());
        if (!md5Password.equals(user.getPassword())) {
            throw new BusinessException("用户名或密码错误");
        }
        
        // 生成token
        return jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole());
    }
    
    @Override
    public void register(User user) {
        // 检查用户名是否存在（未删除的记录）
        User existUser = getUserByUsername(user.getUsername());
        if (existUser != null) {
            throw new BusinessException("用户名已存在");
        }
        
        // 密码加密
        String md5Password = DigestUtils.md5DigestAsHex(user.getPassword().getBytes());
        user.setPassword(md5Password);
        
        // 默认角色为学生
        if (user.getRole() == null || user.getRole().isEmpty()) {
            user.setRole("student");
        }
        
        // 检查是否有同名的软删除记录（username有唯一约束，软删除记录会导致插入失败）
        UserMapper userMapper = (UserMapper) baseMapper;
        User softDeletedUser = userMapper.selectSoftDeletedByUsername(user.getUsername());
        if (softDeletedUser != null) {
            // 物理删除软删除记录，然后插入新记录
            userMapper.physicalDeleteSoftDeletedByUsername(user.getUsername());
        }
        
        // 保存用户
        save(user);
    }
    
    @Override
    public User getUserByUsername(String username) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getUsername, username);
        return getOne(wrapper);
    }
    
    @Override
    public Page<User> getUserPage(int pageNum, int pageSize, String keyword) {
        return getUserPage(pageNum, pageSize, keyword, null);
    }
    
    @Override
    public Page<User> getUserPage(int pageNum, int pageSize, String keyword, String role) {
        Page<User> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        
        if (role != null && !role.isEmpty()) {
            wrapper.eq(User::getRole, role);
        }
        
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like(User::getUsername, keyword)
                    .or().like(User::getRealName, keyword)
                    .or().like(User::getPhone, keyword)
                    .or().like(User::getStudentNo, keyword));
        }
        
        wrapper.orderByDesc(User::getCreateTime);
        return page(page, wrapper);
    }
    
    @Override
    public Page<User> getUserPage(int pageNum, int pageSize, Map<String, Object> params) {
        Page<User> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        
        String role = (String) params.get("role");
        if (role != null && !role.isEmpty()) {
            wrapper.eq(User::getRole, role);
        }
        
        String keyword = (String) params.get("keyword");
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like(User::getUsername, keyword)
                    .or().like(User::getRealName, keyword)
                    .or().like(User::getPhone, keyword)
                    .or().like(User::getStudentNo, keyword));
        }
        
        String studentNo = (String) params.get("studentNo");
        if (studentNo != null && !studentNo.isEmpty()) {
            wrapper.like(User::getStudentNo, studentNo);
        }
        
        String className = (String) params.get("className");
        if (className != null && !className.isEmpty()) {
            wrapper.like(User::getClassName, className);
        }
        
        String college = (String) params.get("college");
        if (college != null && !college.isEmpty()) {
            wrapper.eq(User::getCollege, college);
        }
        
        String major = (String) params.get("major");
        if (major != null && !major.isEmpty()) {
            wrapper.like(User::getMajor, major);
        }
        
        Object gradeObj = params.get("grade");
        if (gradeObj != null && !gradeObj.toString().isEmpty()) {
            wrapper.eq(User::getGrade, Integer.parseInt(gradeObj.toString()));
        }
        
        wrapper.orderByAsc(User::getCollege, User::getClassName, User::getStudentNo);
        return page(page, wrapper);
    }
    
    @Override
    public void changePassword(Long userId, String oldPassword, String newPassword) {
        User user = getById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        
        // 验证旧密码
        String md5OldPassword = DigestUtils.md5DigestAsHex(oldPassword.getBytes());
        if (!md5OldPassword.equals(user.getPassword())) {
            throw new BusinessException("原密码错误");
        }
        
        // 更新密码
        String md5NewPassword = DigestUtils.md5DigestAsHex(newPassword.getBytes());
        user.setPassword(md5NewPassword);
        updateById(user);
    }
}

