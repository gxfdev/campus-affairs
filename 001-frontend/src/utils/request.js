import axios from 'axios'
import { ElMessage } from 'element-plus'
import router from '@/router'

// 创建axios实例
const request = axios.create({
  baseURL: '/api',
  timeout: 15000
})

// 请求拦截器
request.interceptors.request.use(
  config => {
    // 从localStorage获取token
    const token = localStorage.getItem('token')
    if (token) {
      // 添加Bearer前缀
      config.headers['Authorization'] = `Bearer ${token}`
    }

    // 统一参数名：前端 current/size -> 后端 pageNum/pageSize
    if (config.params) {
      if (config.params.current !== undefined) {
        config.params.pageNum = config.params.current
        delete config.params.current
      }
      if (config.params.size !== undefined) {
        config.params.pageSize = config.params.size
        delete config.params.size
      }
    }

    return config
  },
  error => {
    return Promise.reject(error)
  }
)

// 响应拦截器
request.interceptors.response.use(
  response => {
    const res = response.data
    
    // 如果返回的是二进制数据，直接返回
    if (response.config.responseType === 'blob') {
      return response
    }
    
    // 统一处理响应
    if (res.code === 200) {
      return res
    } else if (res.code === 401) {
      ElMessage.error('登录已过期，请重新登录')
      localStorage.removeItem('token')
      localStorage.removeItem('userInfo')
      router.push('/login')
      return Promise.reject(new Error(res.message || '登录已过期'))
    } else {
      ElMessage.error(res.message || '请求失败')
      return Promise.reject(new Error(res.message || '请求失败'))
    }
  },
  error => {
    // 静默处理401和请求取消错误，避免控制台报错
    const status = error.response?.status
    const isAborted = error.code === 'ERR_NETWORK' || error.code === 'ECONNABORTED' || error.message === 'Network Error'
    
    if (status === 401) {
      ElMessage.error('登录已过期，请重新登录')
      localStorage.removeItem('token')
      localStorage.removeItem('userInfo')
      router.push('/login')
      return Promise.reject(error)
    }
    
    if (error.response) {
      switch (status) {
        case 403:
          ElMessage.error('没有权限访问')
          break
        case 404:
          ElMessage.error('请求的资源不存在')
          break
        case 500:
          ElMessage.error('服务器错误')
          break
        default:
          ElMessage.error(error.response.data?.message || '请求失败')
      }
    } else if (!isAborted) {
      ElMessage.error('网络错误，请检查网络连接')
    }
    
    return Promise.reject(error)
  }
)

export default request

