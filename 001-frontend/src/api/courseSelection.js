import request from '@/utils/request'

// 获取选课列表
export const getCourseSelectionList = (params) => {
  return request.get('/course-selection/list', { params })
}

// 选课
export const selectCourse = (courseId) => {
  return request.post(`/course-selection/select/${courseId}`)
}

// 退课
export const dropCourse = (courseId) => {
  return request.post(`/course-selection/drop/${courseId}`)
}

// 我的选课记录
export const getMyCourses = () => {
  return request.get('/course-selection/my-courses')
}

// 辅导员开放选课
export const openCourseSelection = (courseId) => {
  return request.post(`/course-selection/open/${courseId}`)
}

// 辅导员关闭选课
export const closeCourseSelection = (courseId) => {
  return request.post(`/course-selection/close/${courseId}`)
}

// 添加选课（管理员/辅导员）
export const addCourseSelection = (data) => {
  return request.post('/course-selection/add', data)
}

// 更新选课（管理员/辅导员）
export const updateCourseSelection = (data) => {
  return request.put('/course-selection/update', data)
}

// 删除选课（管理员）
export const deleteCourseSelection = (id) => {
  return request.delete(`/course-selection/${id}`)
}
