import request from '@/utils/request'

// 获取课程表列表（分页）
export const getCourseScheduleList = (params) => {
  return request.get('/course-schedule/list', { params })
}

// 根据班级获取课程表
export const getScheduleByClass = (className, semester) => {
  return request.get(`/course-schedule/class/${className}`, { params: { semester } })
}

// 添加课程
export const addCourseSchedule = (data) => {
  return request.post('/course-schedule/add', data)
}

// 更新课程
export const updateCourseSchedule = (data) => {
  return request.put('/course-schedule/update', data)
}

// 删除课程
export const deleteCourseSchedule = (id) => {
  return request.delete(`/course-schedule/${id}`)
}
