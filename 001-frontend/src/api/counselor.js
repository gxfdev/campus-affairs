import request from '@/utils/request'

// 获取辅导员列表
export const getCounselorList = (params) => {
  return request.get('/counselor/list', { params })
}

// 添加辅导员
export const addCounselor = (data) => {
  return request.post('/counselor/add', data)
}

// 更新辅导员
export const updateCounselor = (data) => {
  return request.put('/counselor/update', data)
}

// 删除辅导员
export const deleteCounselor = (id) => {
  return request.delete(`/counselor/${id}`)
}
