<template>
  <div class="score-container">
    <div class="page-header">
      <div class="page-title">
        <el-icon><Trophy /></el-icon>
        <span>成绩查询</span>
      </div>
    </div>

    <el-card class="main-card">
      <!-- 搜索栏 -->
      <div class="search-section">
        <el-form :inline="true" :model="searchForm" class="search-form">
          <el-form-item label="学期" v-if="!isStudent">
            <el-input v-model="searchForm.semester" placeholder="如2024-2025-2" clearable style="width: 180px" />
          </el-form-item>
          <el-form-item label="课程类型">
            <el-select v-model="searchForm.courseType" placeholder="全部" clearable style="width: 140px">
              <el-option label="必修课" value="required" />
              <el-option label="公选课" value="optional" />
              <el-option label="体育课" value="pe" />
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
        <el-table-column prop="courseName" label="课程名称" min-width="150" />
        <el-table-column prop="courseType" label="课程类型" width="120" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.courseType === 'required'" type="">必修</el-tag>
            <el-tag v-else-if="row.courseType === 'optional'" type="success">公选</el-tag>
            <el-tag v-else-if="row.courseType === 'pe'" type="warning">体育</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="credit" label="学分" width="80" align="center" />
        <el-table-column prop="score" label="成绩" width="100" align="center">
          <template #default="{ row }">
            <span :class="getScoreClass(row.score)">{{ row.score ?? '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="semester" label="学期" width="140" align="center" />
        <el-table-column prop="className" label="班级" width="120" align="center" v-if="!isStudent" />
      </el-table>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="pagination.current"
          v-model:page-size="pagination.size"
          :total="pagination.total"
          :page-sizes="[10, 20, 50]"
          layout="total, sizes, prev, pager, next"
          @size-change="fetchScores"
          @current-change="fetchScores"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import { getScoreList } from '@/api/score'

const userStore = useUserStore()
const userInfo = computed(() => userStore.userInfo)
const isStudent = computed(() => userInfo.value?.role === 'student')

const loading = ref(false)
const scoreData = ref([])
const searchForm = reactive({ semester: '', courseType: '' })
const pagination = reactive({ current: 1, size: 20, total: 0 })

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
    const params = {
      pageNum: pagination.current,
      pageSize: pagination.size,
      ...searchForm
    }
    const res = await getScoreList(params)
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

const resetSearch = () => {
  searchForm.semester = ''
  searchForm.courseType = ''
  pagination.current = 1
  fetchScores()
}

onMounted(() => fetchScores())
</script>

<style scoped>
.score-container { padding: 0; }
.page-header {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 24px;
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
.stat-cards {
  display: flex; gap: 16px; margin-bottom: 20px;
}
.stat-card {
  flex: 1; text-align: center; padding: 16px;
  background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 100%);
  border-radius: 12px;
}
.stat-value {
  font-size: 28px; font-weight: 700; color: #409EFF;
}
.stat-label {
  font-size: 13px; color: #909399; margin-top: 4px;
}
.score-excellent { color: #67C23A; font-weight: 700; }
.score-good { color: #409EFF; font-weight: 600; }
.score-pass { color: #E6A23C; }
.score-fail { color: #F56C6C; font-weight: 700; }
.pagination-container {
  display: flex; justify-content: flex-end; padding: 16px 0;
}
@media (max-width: 768px) {
  .stat-cards { flex-direction: column; }
  .search-form :deep(.el-form-item) { margin-bottom: 8px; }
}
</style>
