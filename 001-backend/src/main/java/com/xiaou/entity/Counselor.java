package com.xiaou.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@TableName("counselor")
public class Counselor implements Serializable {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private String college;
    private Integer grade;
    private String description;
    
    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime createTime;
    
    @TableField(fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime updateTime;
    
    @TableLogic
    private Integer deleted;
    
    /** 关联的用户信息（非数据库字段） */
    @TableField(exist = false)
    private User user;
}
