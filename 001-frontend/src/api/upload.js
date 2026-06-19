import request from '@/utils/request'

// 上传头像
export const uploadAvatar = (formData) => {
  // 不要手动设置 Content-Type，让浏览器自动设置 boundary
  // 手动设置 multipart/form-data 会导致缺少 boundary 参数，服务器无法解析
  return request.post('/file/upload/avatar', formData, {
    timeout: 30000
  })
}
