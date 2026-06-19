package com.xiaou.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.xiaou.entity.User;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

/**
 * 用户Mapper接口
 * @author xiaou
 */
@Mapper
public interface UserMapper extends BaseMapper<User> {

    /**
     * 查找同名软删除记录（绕过@TableLogic过滤）
     */
    @Select("SELECT * FROM user WHERE username = #{username} AND deleted = 1 LIMIT 1")
    User selectSoftDeletedByUsername(@Param("username") String username);

    /**
     * 物理删除同名软删除记录（绕过@TableLogic）
     */
    @Delete("DELETE FROM user WHERE username = #{username} AND deleted = 1")
    int physicalDeleteSoftDeletedByUsername(@Param("username") String username);
}

