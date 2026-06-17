package com.xiaou.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("score")
public class Score implements Serializable {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long studentId;
    private String courseName;
    private String courseType;
    private BigDecimal score;
    private BigDecimal credit;
    private String semester;
    private String className;
    
    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime createTime;
    
    @TableField(fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime updateTime;
    
    @TableLogic
    private Integer deleted;
    
    /** 关联的学生信息（非数据库字段） */
    @TableField(exist = false)
    private User student;
}
