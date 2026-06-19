import { defineStore } from 'pinia'
import { ref } from 'vue'
import { login, getUserInfo } from '@/api/auth'
import { ElMessage } from 'element-plus'
import router from '@/router'

export const useUserStore = defineStore('user', () => {
  const userInfo = ref(null)
  const token = ref(localStorage.getItem('token') || '')

  // 登录
  const userLogin = async (loginForm) => {
    try {
      const res = await login(loginForm)
      if (res.code === 200 && res.data) {
        token.value = res.data.token
        userInfo.value = res.data.user
        
        // 保存到localStorage
        localStorage.setItem('token', res.data.token)
        localStorage.setItem('userInfo', JSON.stringify(res.data.user))
        
        ElMessage.success('登录成功')
        router.push('/')
        return true
      }
    } catch (error) {
      // 静默处理
      return false
    }
  }

  // 获取用户信息
  const fetchUserInfo = async () => {
    // 没有token时不发请求，避免ERR_ABORTED
    if (!token.value) {
      return
    }
    try {
      const res = await getUserInfo()
      if (res.code === 200 && res.data) {
        userInfo.value = res.data
        localStorage.setItem('userInfo', JSON.stringify(res.data))
      }
    } catch (error) {
      // 静默处理，避免控制台报错
      if (error.response && error.response.status !== 401) {
        // 静默处理
      }
    }
  }

  // 登出
  const logout = () => {
    token.value = ''
    userInfo.value = null
    localStorage.removeItem('token')
    localStorage.removeItem('userInfo')
    ElMessage.success('已退出登录')
    router.push('/login')
  }

  // 初始化用户信息（从localStorage恢复）
  const initUserInfo = () => {
    const savedUserInfo = localStorage.getItem('userInfo')
    if (savedUserInfo) {
      try {
        userInfo.value = JSON.parse(savedUserInfo)
      } catch (error) {
        // 静默处理
      }
    }
  }

  return {
    userInfo,
    token,
    userLogin,
    fetchUserInfo,
    logout,
    initUserInfo
  }
})

