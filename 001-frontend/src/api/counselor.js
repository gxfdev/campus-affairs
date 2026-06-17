import request from '@/utils/request'

// 获取辅导员列表
export const getCounselorList = (params) => {
  return request.get('/counselor/list', { params })
}

// 辅导员获取自己负责的学生
export const getMyStudents = (params) => {
  return request.get('/counselor/my-students', { params })
}

// 辅导员获取自己负责的所有学生（不分页）
export const getAllMyStudents = () => {
  return request.get('/counselor/all-my-students')
}

// 获取辅导员自己的信息
export const getMyCounselorInfo = () => {
  return request.get('/counselor/my-info')
}

// 获取学院列表
export const getCounselorColleges = () => {
  return request.get('/counselor/colleges')
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
