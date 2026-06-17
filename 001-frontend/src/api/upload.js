import request from '@/utils/request'

// 上传头像
export const uploadAvatar = (formData) => {
  return request.post('/file/upload/avatar', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}
