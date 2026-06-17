package com.xiaou.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.xiaou.entity.Counselor;

public interface CounselorService extends IService<Counselor> {
    Page<Counselor> getCounselorPage(int pageNum, int pageSize, String college, Integer grade);
}
