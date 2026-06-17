<template>
  <div class="score-container">
    <div class="page-header">
      <div class="page-title">
        <el-icon><Trophy /></el-icon>
        <span>成绩查询</span>
      </div>
      <el-button v-if="isCounselor || isAdmin" type="primary" @click="showAddDialog = true">
        <el-icon><Plus /></el-icon>录入成绩
      </el-button>
    </div>

    <el-card class="main-card">
      <!-- 搜索栏 -->
      <div class="search-section">
        <el-form :inline="true" :model="searchForm" class="search-form">
          <el-form-item label="学期">
            <el-select v-model="searchForm.semester" placeholder="选择学期" clearable style="width: 180px">
              <el-option label="2025-2026-1" value="2025-2026-1" />
              <el-option label="2024-2025-2" value="2024-2025-2" />
              <el-option label="2024-2025-1" value="2024-2025-1" />
              <el-option label="2023-2024-2" value="2023-2024-2" />
              <el-option label="2023-2024-1" value="2023-2024-1" />
            </el-select>
          </el-form-item>
          <el-form-item label="课程类型">
            <el-select v-model="searchForm.courseType" placeholder="全部" clearable style="width: 140px">
              <el-option label="必修" value="必修" />
              <el-option label="选修" value="选修" />
              <el-option label="实践" value="实践" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="fetchScores">查询</el-button>
            <el-button @click="resetSearch">重置</el-button>
          </el-form-item>
        </el-form>
      </div>

      <!-- 统计卡片 -->
      <div class="stat-cards" v-if="scoreData.length > 0">
        <div class="stat-card">
          <div class="stat-value">{{ totalCredits }}</div>
          <div class="stat-label">总学分</div>
        </div>
        <div class="stat-card">
          <div class="stat-value">{{ avgScore }}</div>
          <div class="stat-label">平均分</div>
        </div>
        <div class="stat-card">
          <div class="stat-value">{{ scoreData.length }}</div>
          <div class="stat-label">课程数</div>
        </div>
      </div>

      <!-- 表格 -->
      <el-table :data="scoreData" v-loading="loading" stripe style="width: 100%">
        <el-table-column prop="studentName" label="学生" width="100" v-if="!isStudent" />
        <el-table-column prop="studentNo" label="学号" width="120" v-if="!isStudent" />
        <el-table-column prop="courseName" label="课程名称" min-width="150" />
        <el-table-column prop="courseType" label="课程类型" width="100" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.courseType === '必修'" type="">必修</el-tag>
            <el-tag v-else-if="row.courseType === '选修'" type="success">选修</el-tag>
            <el-tag v-else-if="row.courseType === '实践'" type="warning">实践</el-tag>
            <el-tag v-else>{{ row.courseType }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="credit" label="学分" width="80" align="center" />
        <el-table-column prop="score" label="成绩" width="100" align="center">
          <template #default="{ row }">
            <span :class="getScoreClass(row.score)">{{ row.score ?? '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="semester" label="学期" width="130" align="center" />
      </el-table>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="pagination.current"
          v-model:page-size="pagination.size"
          :total="pagination.total"
          layout="total, prev, pager, next"
          @current-change="fetchScores"
        />
      </div>
    </el-card>

    <!-- 录入成绩对话框 -->
    <el-dialog v-model="showAddDialog" title="录入成绩" width="500px">
      <el-form :model="scoreForm" label-width="80px">
        <el-form-item label="学生" v-if="isCounselor">
          <el-select v-model="scoreForm.studentId" filterable placeholder="选择学生" style="width: 100%">
            <el-option v-for="s in allStudents" :key="s.id" :label="`${s.realName}(${s.studentNo})`" :value="s.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="学生ID" v-if="isAdmin">
          <el-input v-model="scoreForm.studentId" placeholder="学生用户ID" />
        </el-form-item>
        <el-form-item label="课程名称">
          <el-input v-model="scoreForm.courseName" placeholder="请输入课程名称" />
        </el-form-item>
        <el-form-item label="成绩">
          <el-input-number v-model="scoreForm.score" :min="0" :max="100" style="width: 100%" />
        </el-form-item>
        <el-form-item label="学分">
          <el-input-number v-model="scoreForm.credit" :min="0.5" :max="10" :step="0.5" style="width: 100%" />
        </el-form-item>
        <el-form-item label="课程类型">
          <el-select v-model="scoreForm.courseType" style="width: 100%">
            <el-option label="必修" value="必修" />
            <el-option label="选修" value="选修" />
            <el-option label="实践" value="实践" />
          </el-select>
        </el-form-item>
        <el-form-item label="学期">
          <el-input v-model="scoreForm.semester" placeholder="如：2025-2026-1" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAddDialog = false">取消</el-button>
        <el-button type="primary" @click="handleAddScore">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import { getScoreList, getScoreByCounselor, addScore } from '@/api/score'
import { getAllMyStudents } from '@/api/counselor'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const userInfo = computed(() => userStore.userInfo)
const isStudent = computed(() => userInfo.value?.role === 'student')
const isCounselor = computed(() => userInfo.value?.role === 'counselor')
const isAdmin = computed(() => userInfo.value?.role === 'admin')

const loading = ref(false)
const showAddDialog = ref(false)
const scoreData = ref([])
const allStudents = ref([])
const searchForm = reactive({ semester: '', courseType: '' })
const pagination = reactive({ current: 1, size: 20, total: 0 })

const scoreForm = ref({
  studentId: null, courseName: '', score: 0, credit: 2, courseType: '必修', semester: '2025-2026-1'
})

const totalCredits = computed(() => {
  return scoreData.value.reduce((sum, s) => sum + (s.credit || 0), 0).toFixed(1)
})

const avgScore = computed(() => {
  const valid = scoreData.value.filter(s => s.score != null)
  if (valid.length === 0) return '-'
  return (valid.reduce((sum, s) => sum + s.score, 0) / valid.length).toFixed(1)
})

const getScoreClass = (score) => {
  if (score == null) return ''
  if (score >= 90) return 'score-excellent'
  if (score >= 80) return 'score-good'
  if (score >= 60) return 'score-pass'
  return 'score-fail'
}

const fetchScores = async () => {
  loading.value = true
  try {
    let res
    if (isCounselor.value) {
      res = await getScoreByCounselor({
        pageNum: pagination.current,
        pageSize: pagination.size,
        ...searchForm
      })
    } else {
      res = await getScoreList({
        pageNum: pagination.current,
        pageSize: pagination.size,
        ...searchForm
      })
    }
    if (res.code === 200) {
      scoreData.value = res.data?.records || []
      pagination.total = res.data?.total || 0
    }
  } catch (e) {
    console.error('获取成绩失败', e)
  } finally {
    loading.value = false
  }
}

const fetchAllStudents = async () => {
  if (!isCounselor.value) return
  try {
    const res = await getAllMyStudents()
    if (res.code === 200) allStudents.value = res.data || []
  } catch (e) { console.error(e) }
}

const handleAddScore = async () => {
  try {
    const res = await addScore(scoreForm.value)
    if (res.code === 200) {
      ElMessage.success('录入成功')
      showAddDialog.value = false
      fetchScores()
    } else {
      ElMessage.error(res.message || '录入失败')
    }
  } catch (e) {
    ElMessage.error('录入失败')
  }
}

const resetSearch = () => {
  searchForm.semester = ''
  searchForm.courseType = ''
  pagination.current = 1
  fetchScores()
}

onMounted(() => {
  fetchScores()
  fetchAllStudents()
})
</script>

<style scoped>
.score-container { padding: 0; }
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
.search-section {
  margin-bottom: 20px; padding: 16px; background: #f8f9fa; border-radius: 12px;
}
.search-form :deep(.el-form-item) { margin-bottom: 0; }
.stat-cards { display: flex; gap: 16px; margin-bottom: 20px; }
.stat-card {
  flex: 1; text-align: center; padding: 16px;
  background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 100%);
  border-radius: 12px;
}
.stat-value { font-size: 28px; font-weight: 700; color: #409EFF; }
.stat-label { font-size: 13px; color: #909399; margin-top: 4px; }
.score-excellent { color: #67C23A; font-weight: 700; }
.score-good { color: #409EFF; font-weight: 600; }
.score-pass { color: #E6A23C; }
.score-fail { color: #F56C6C; font-weight: 700; }
.pagination-container { display: flex; justify-content: flex-end; padding: 16px 0; }
</style>
