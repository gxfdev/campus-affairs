import { ref, onMounted, onUnmounted } from 'vue'
import { useUserStore } from '@/stores/user'
import { ElMessage } from 'element-plus'

// 全局数据同步状态
const syncStatus = ref('idle') // idle | syncing | success | error
const lastSyncTime = ref(null)
const syncInterval = ref(null)
const SYNC_INTERVAL = 5 * 60 * 1000 // 5分钟同步一次

// 数据同步composable
export function useDataSync() {
  const userStore = useUserStore()

  // 手动同步数据
  const syncData = async (showMessage = false) => {
    // 没有token时不发请求，避免ERR_ABORTED
    if (!userStore.token) {
      return
    }
    if (syncStatus.value === 'syncing') return
    syncStatus.value = 'syncing'
    try {
      // 刷新用户信息
      await userStore.fetchUserInfo()
      syncStatus.value = 'success'
      lastSyncTime.value = new Date()
      if (showMessage) {
        ElMessage.success('数据同步成功')
      }
    } catch (error) {
      // 静默处理，避免控制台报错
      syncStatus.value = 'error'
      if (showMessage) {
        ElMessage.error('数据同步失败，请检查网络连接')
      }
    }
  }

  // 启动定时同步
  const startAutoSync = () => {
    if (syncInterval.value) return
    syncInterval.value = setInterval(() => {
      syncData(false)
    }, SYNC_INTERVAL)
  }

  // 停止定时同步
  const stopAutoSync = () => {
    if (syncInterval.value) {
      clearInterval(syncInterval.value)
      syncInterval.value = null
    }
  }

  // 页面可见性变化时同步
  const handleVisibilityChange = () => {
    if (document.visibilityState === 'visible') {
      // 页面重新可见时，如果距上次同步超过2分钟，则同步
      if (lastSyncTime.value) {
        const diff = Date.now() - lastSyncTime.value.getTime()
        if (diff > 2 * 60 * 1000) {
          syncData(false)
        }
      } else {
        syncData(false)
      }
    }
  }

  onMounted(() => {
    startAutoSync()
    document.addEventListener('visibilitychange', handleVisibilityChange)
  })

  onUnmounted(() => {
    stopAutoSync()
    document.removeEventListener('visibilitychange', handleVisibilityChange)
  })

  return {
    syncStatus,
    lastSyncTime,
    syncData,
    startAutoSync,
    stopAutoSync
  }
}
