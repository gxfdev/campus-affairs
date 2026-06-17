package com.xiaou.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.xiaou.entity.Score;

public interface ScoreService extends IService<Score> {
    Page<Score> getScorePage(int pageNum, int pageSize, Long studentId, String semester, String courseType);
}
