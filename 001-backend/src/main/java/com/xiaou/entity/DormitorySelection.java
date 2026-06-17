package com.xiaou.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@TableName("dormitory_selection")
public class DormitorySelection implements Serializable {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long dormitoryId;
    private Long studentId;
    private Integer status;
    
    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime createTime;
    
    @TableField(fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime updateTime;
    
    @TableLogic
    private Integer deleted;
    
    /** 关联的宿舍信息（非数据库字段） */
    @TableField(exist = false)
    private Dormitory dormitory;
}
