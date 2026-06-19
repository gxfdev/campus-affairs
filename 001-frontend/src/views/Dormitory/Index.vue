<template>
  <div class="dormitory-container">
    <div class="page-header">
      <div class="page-title">
        <el-icon><HomeFilled /></el-icon>
        <span>宿舍选择</span>
      </div>
      <el-button type="primary" @click="fetchMyDormitory" v-if="isStudent">
        <el-icon><View /></el-icon>我的宿舍
      </el-button>
    </div>

    <!-- 提示信息 -->
    <el-alert
      v-if="isStudent && !isFreshman"
      title="仅限大一新生选择宿舍"
      type="warning"
      :closable="false"
      show-icon
      style="margin-bottom: 20px"
    />

    <el-card class="main-card">
      <!-- 筛选 -->
      <div class="filter-section">
        <el-form :inline="true">
          <el-form-item label="楼栋">
            <el-select v-model="filter.building" placeholder="全部" clearable style="width: 120px">
              <el-option label="1号楼" value="1号楼" />
              <el-option label="2号楼" value="2号楼" />
              <el-option label="3号楼" value="3号楼" />
              <el-option label="4号楼" value="4号楼" />
              <el-option label="5号楼" value="5号楼" />
            </el-select>
          </el-form-item>
          <el-form-item label="性别">
            <el-select v-model="filter.gender" placeholder="全部" clearable style="width: 100px">
              <el-option label="男" value="男" />
              <el-option label="女" value="女" />
            </el-select>
          </el-form-item>
          <el-form-item label="学院" v-if="isAdmin">
            <el-input v-model="filter.college" placeholder="学院" clearable style="width: 140px" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="fetchDormitories">查询</el-button>
          </el-form-item>
        </el-form>
      </div>

      <!-- 宿舍列表 -->
      <el-row :gutter="16">
        <el-col :xs="24" :sm="12" :md="8" :lg="6" v-for="dorm in dormList" :key="dorm.id">
          <div class="dorm-card" :class="{ 'is-full': dorm.status === 'full', 'is-maintenance': dorm.status === 'maintenance' }">
            <div class="dorm-header">
              <div class="dorm-building">{{ dorm.building }}</div>
              <el-tag :type="dorm.status === 'available' ? 'success' : dorm.status === 'full' ? 'danger' : 'warning'" size="small">
                {{ dorm.status === 'available' ? '可选' : dorm.status === 'full' ? '已满' : '维护中' }}
              </el-tag>
            </div>
            <div class="dorm-room">{{ dorm.roomNumber }}室</div>
            <div class="dorm-info">
              <span>性别：{{ dorm.gender }}</span>
              <span>容量：{{ dorm.currentCount }}/{{ dorm.capacity }}人</span>
            </div>
            <el-progress
              :percentage="Math.round(dorm.currentCount / dorm.capacity * 100)"
              :color="dorm.status === 'full' ? '#F56C6C' : '#67C23A'"
              :stroke-width="8"
              style="margin-top: 12px"
            />
            <el-button
              v-if="isStudent && isFreshman"
              type="primary"
              :disabled="dorm.status !== 'available'"
              @click="handleSelectDorm(dorm)"
              style="width: 100%; margin-top: 12px"
            >
              {{ dorm.status === 'available' ? '选择此宿舍' : '不可选' }}
            </el-button>
          </div>
        </el-col>
      </el-row>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="pagination.current"
          v-model:page-size="pagination.size"
          :total="pagination.total"
          layout="prev, pager, next"
          @current-change="fetchDormitories"
        />
      </div>
    </el-card>

    <!-- 我的宿舍对话框 -->
    <el-dialog v-model="showMyDorm" title="我的宿舍" width="400px">
      <div v-if="myDormInfo" class="my-dorm-info">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="楼栋">{{ myDormInfo.dormitory?.building }}</el-descriptions-item>
          <el-descriptions-item label="房间号">{{ myDormInfo.dormitory?.roomNumber }}</el-descriptions-item>
          <el-descriptions-item label="性别">{{ myDormInfo.dormitory?.gender }}</el-descriptions-item>
        </el-descriptions>
      </div>
      <el-empty v-else description="暂未选择宿舍" />
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import { getDormitoryList, selectDormitory, getMyDormitory } from '@/api/dormitory'
import { ElMessage, ElMessageBox } from 'element-plus'

const userStore = useUserStore()
const userInfo = computed(() => userStore.userInfo)
const isStudent = computed(() => userInfo.value?.role === 'student')
const isAdmin = computed(() => userInfo.value?.role === 'admin')
const isFreshman = computed(() => userInfo.value?.grade === 1)

const dormList = ref([])
const loading = ref(false)
const showMyDorm = ref(false)
const myDormInfo = ref(null)
const filter = reactive({ building: '', gender: '', college: '' })
const pagination = reactive({ current: 1, size: 12, total: 0 })

const fetchDormitories = async () => {
  loading.value = true
  try {
    const params = {
      pageNum: pagination.current,
      pageSize: pagination.size,
      ...filter
    }
    // 学生自动按学院和性别筛选
    if (isStudent.value && userInfo.value?.college) {
      params.college = userInfo.value.college
    }
    if (isStudent.value && userInfo.value?.gender) {
      params.gender = userInfo.value.gender
    }
    const res = await getDormitoryList(params)
    if (res.code === 200) {
      dormList.value = res.data?.records || []
      pagination.total = res.data?.total || 0
    }
  } catch (e) {
    // 静默处理
  } finally {
    loading.value = false
  }
}

const fetchMyDormitory = async () => {
  showMyDorm.value = true
  try {
    const res = await getMyDormitory()
    if (res.code === 200) {
      myDormInfo.value = res.data
    }
  } catch (e) {
    // 静默处理
  }
}

const handleSelectDorm = async (dorm) => {
  try {
    await ElMessageBox.confirm(`确定选择「${dorm.building} ${dorm.roomNumber}室」吗？`, '宿舍选择确认', {
      type: 'info'
    })
    const res = await selectDormitory(dorm.id)
    if (res.code === 200) {
      ElMessage.success('选择成功')
      fetchDormitories()
    } else {
      ElMessage.error(res.message || '选择失败')
    }
  } catch (e) {
    if (e !== 'cancel') ElMessage.error('选择失败')
  }
}

onMounted(() => fetchDormitories())
</script>

<style scoped>
.dormitory-container { padding: 0; }
.page-header {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 24px; flex-wrap: wrap; gap: 12px;
}
.page-title {
  display: flex; align-items: center; gap: 12px;
  font-size: 24px; font-weight: 700; color: #2C3E50;
}
.main-card {
  border-radius: 16px !important; border: none !important;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08) !important;
}
.main-card :deep(.el-card__body) { padding: 24px; }
.filter-section {
  margin-bottom: 20px; padding: 16px; background: #f8f9fa; border-radius: 12px;
}
.filter-section :deep(.el-form-item) { margin-bottom: 0; }
.dorm-card {
  background: white; border: 1px solid #ebeef5; border-radius: 12px;
  padding: 20px; margin-bottom: 16px; transition: all 0.3s;
}
.dorm-card:hover { box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1); transform: translateY(-2px); }
.dorm-card.is-full { opacity: 0.7; }
.dorm-card.is-maintenance { opacity: 0.5; }
.dorm-header {
  display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;
}
.dorm-building { font-size: 14px; color: #909399; }
.dorm-room { font-size: 20px; font-weight: 700; color: #2C3E50; margin-bottom: 10px; }
.dorm-info {
  display: flex; justify-content: space-between; font-size: 13px; color: #606266;
}
.pagination-container {
  display: flex; justify-content: center; padding: 16px 0;
}
.my-dorm-info { padding: 16px 0; }
@media (max-width: 768px) {
  .page-header { flex-direction: column; align-items: flex-start; }
}
</style>
