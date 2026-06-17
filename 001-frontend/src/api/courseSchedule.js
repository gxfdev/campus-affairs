import request from '@/utils/request'

// 获取课程表列表（分页）
export const getCourseScheduleList = (params) => {
  return request.get('/course-schedule/list', { params })
}

// 根据班级获取课程表
export const getScheduleByClass = (className, semester) => {
  return request.get(`/course-schedule/class/${className}`, { params: { semester } })
}

// 学生获取自己的课程表
export const getMySchedule = (semester) => {
  return request.get('/course-schedule/my-schedule', { params: { semester } })
}

// 获取学院列表
export const getColleges = () => {
  return request.get('/course-schedule/colleges')
}

// 获取专业列表
export const getMajors = (college) => {
  return request.get('/course-schedule/majors', { params: { college } })
}

// 获取班级列表
export const getClasses = (params) => {
  return request.get('/course-schedule/classes', { params })
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
