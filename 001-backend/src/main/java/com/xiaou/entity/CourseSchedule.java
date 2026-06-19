package com.xiaou.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("course_schedule")
public class CourseSchedule implements Serializable {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String className;
    private String courseName;
    private String teacherName;
    private String location;
    private Integer dayOfWeek;
    private Integer periodStart;
    private Integer periodEnd;
    private String semester;
    private BigDecimal credit;
    private String courseType;
    private Integer weekStart;
    private Integer weekEnd;
    
    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime createTime;
    
    @TableField(fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime updateTime;
    
    @TableLogic
    private Integer deleted;
}
