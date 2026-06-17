import request from '@/utils/request'

// 获取成绩列表
export const getScoreList = (params) => {
  return request.get('/score/list', { params })
}

// 添加成绩
export const addScore = (data) => {
  return request.post('/score/add', data)
}

// 更新成绩
export const updateScore = (data) => {
  return request.put('/score/update', data)
}

// 删除成绩
export const deleteScore = (id) => {
  return request.delete(`/score/${id}`)
}
