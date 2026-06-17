package com.xiaou.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("course_selection")
public class CourseSelection implements Serializable {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String courseName;
    private String courseType;
    private String teacherName;
    private String location;
    private Integer maxStudents;
    private Integer currentStudents;
    private BigDecimal credit;
    private String semester;
    private Integer dayOfWeek;
    private Integer periodStart;
    private Integer periodEnd;
    private String status;
    private String college;
    private Integer grade;
    private Integer isOpen;
    private Long openedBy;

    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime createTime;
    
    @TableField(fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime updateTime;
    
    @TableLogic
    private Integer deleted;
}
