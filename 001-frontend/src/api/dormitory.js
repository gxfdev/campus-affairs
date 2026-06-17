import request from '@/utils/request'

// 获取宿舍列表
export const getDormitoryList = (params) => {
  return request.get('/dormitory/list', { params })
}

// 选择宿舍
export const selectDormitory = (dormitoryId) => {
  return request.post(`/dormitory/select/${dormitoryId}`)
}

// 我的宿舍
export const getMyDormitory = () => {
  return request.get('/dormitory/my-dormitory')
}

// 添加宿舍（管理员）
export const addDormitory = (data) => {
  return request.post('/dormitory/add', data)
}

// 更新宿舍（管理员）
export const updateDormitory = (data) => {
  return request.put('/dormitory/update', data)
}

// 删除宿舍（管理员）
export const deleteDormitory = (id) => {
  return request.delete(`/dormitory/${id}`)
}
