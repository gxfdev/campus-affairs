import request from '@/utils/request'

// 提交请假申请
export const applyLeave = (data) => {
  return request.post('/leave/apply', data)
}

// 获取请假列表
export const getLeaveList = (params) => {
  return request.get('/leave/list', { params })
}

// 辅导员获取请假列表（只看自己负责学生的）
export const getLeaveRequests = (params) => {
  return request.get('/leave/counselor/list', { params })
}

// 审批请假
export const approveLeaveRequest = (data) => {
  return request.post('/leave/approve', data)
}

// 审批请假（旧接口兼容）
export const approveLeave = (data) => {
  return request.post('/leave/approve', data)
}

// 获取请假统计
export const getLeaveStatistics = () => {
  return request.get('/leave/statistics')
}
