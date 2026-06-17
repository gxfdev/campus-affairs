package com.xiaou.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.xiaou.entity.Dormitory;

public interface DormitoryService extends IService<Dormitory> {
    Page<Dormitory> getDormitoryPage(int pageNum, int pageSize, String building, String gender, String status);
    void selectDormitory(Long dormitoryId, Long studentId);
}
