package com.xiaou.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.xiaou.entity.ActivitySignup;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Mapper;

/**
 * 活动报名Mapper接口
 * @author xiaou
 */
@Mapper
public interface ActivitySignupMapper extends BaseMapper<ActivitySignup> {
    
    /**
     * 物理删除报名记录（绕过逻辑删除）
     */
    @Delete("DELETE FROM activity_signup WHERE id = #{id}")
    int physicalDeleteById(Long id);
}

