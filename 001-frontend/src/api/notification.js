import request from '@/utils/request'

// 获取未读通知列表
export const getUnreadNotifications = () => {
  return request.get('/notification/unread')
}

// 获取未读通知数量
export const getUnreadCount = () => {
  return request.get('/notification/unread-count')
}

// 标记通知为已读
export const markAsRead = (id) => {
  return request.post(`/notification/mark-read/${id}`)
}

// 标记所有通知为已读
export const markAllAsRead = () => {
  return request.post('/notification/mark-all-read')
}
