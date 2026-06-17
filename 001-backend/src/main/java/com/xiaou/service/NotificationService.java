package com.xiaou.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.xiaou.entity.Notification;

import java.util.List;

public interface NotificationService extends IService<Notification> {
    List<Notification> getUnreadNotifications(Long userId);
    int getUnreadCount(Long userId);
    void markAsRead(Long notificationId);
    void markAllAsRead(Long userId);
}
