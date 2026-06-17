<template>
  <div class="selection-container">
    <div class="page-header">
      <div class="page-title">
        <el-icon><ShoppingCart /></el-icon>
        <span>选课中心</span>
      </div>
      <div class="header-actions">
        <el-button v-if="isStudent" type="primary" @click="showMyCourses = true">
          <el-icon><List /></el-icon>我的选课
        </el-button>
      </div>
    </div>

    <el-card class="main-card">
      <!-- 搜索与筛选 -->
      <div class="search-section">
        <el-form :inline="true" :model="searchForm">
          <el-form-item label="课程类型">
            <el-select v-model="searchForm.courseType" placeholder="全部" clearable style="width: 140px">
              <el-option label="选修" value="选修" />
              <el-option label="必修" value="必修" />
              <el-option label="实践" value="实践" />
            </el-select>
          </el-form-item>
          <el-form-item label="选课状态" v-if="isCounselor || isAdmin">
            <el-select v-model="searchForm.isOpen" placeholder="全部" clearable style="width: 120px">
              <el-option label="已开放" :value="1" />
              <el-option label="未开放" :value="0" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="fetchCourses">查询</el-button>
          </el-form-item>
        </el-form>
      </div>

      <!-- 辅导员批量操作 -->
      <div class="batch-actions" v-if="isCounselor || isAdmin">
        <el-button type="success" @click="handleBatchOpen">批量开放选课</el-button>
        <el-button type="warning" @click="handleBatchClose">批量关闭选课</el-button>
      </div>

      <!-- 课程列表 -->
      <el-table :data="courseList" v-loading="loading" stripe>
        <el-table-column prop="courseName" label="课程名称" min-width="150" />
        <el-table-column prop="teacherName" label="授课教师" width="100" />
        <el-table-column prop="credit" label="学分" width="70" align="center" />
        <el-table-column prop="courseType" label="类型" width="80" align="center">
          <template #default="{ row }">
            <el-tag size="small">{{ row.courseType }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="location" label="地点" width="120" />
        <el-table-column label="容量" width="90" align="center">
          <template #default="{ row }">
            {{ row.currentStudents || 0 }}/{{ row.maxStudents || 0 }}
          </template>
        </el-table-column>
        <el-table-column prop="isOpen" label="选课状态" width="100" align="center" v-if="isCounselor || isAdmin">
          <template #default="{ row }">
            <el-tag :type="row.isOpen === 1 ? 'success' : 'info'" size="small">
              {{ row.isOpen === 1 ? '已开放' : '未开放' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" align="center">
          <template #default="{ row }">
            <!-- 学生：选课/退课 -->
            <template v-if="isStudent">
              <el-button v-if="row.isOpen !== 1" type="info" size="small" disabled>未开放</el-button>
              <el-button v-else type="primary" size="small" @click="handleSelect(row)">选课</el-button>
            </template>
            <!-- 辅导员/管理员：开放/关闭 -->
            <template v-if="isCounselor || isAdmin">
              <el-button v-if="row.isOpen === 0" type="success" size="small" @click="handleOpenCourse(row.id)">开放</el-button>
              <el-button v-if="row.isOpen === 1" type="warning" size="small" @click="handleCloseCourse(row.id)">关闭</el-button>
            </template>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="pagination.current"
          v-model:page-size="pagination.size"
          :total="pagination.total"
          layout="total, prev, pager, next"
          @current-change="fetchCourses"
        />
      </div>
    </el-card>

    <!-- 我的选课对话框 -->
    <el-dialog v-model="showMyCourses" title="我的选课" width="600px">
      <el-table :data="myCoursesList" v-loading="myLoading">
        <el-table-column prop="courseName" label="课程名称" min-width="150" />
        <el-table-column prop="teacherName" label="教师" width="100" />
        <el-table-column prop="credit" label="学分" width="80" align="center" />
        <el-table-column label="操作" width="100" align="center">
          <template #default="{ row }">
            <el-button type="danger" size="small" @click="handleDrop(row)">退课</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import { getCourseSelectionList, selectCourse, dropCourse, getMyCourses, openCourseSelection, closeCourseSelection } from '@/api/courseSelection'
import { ElMessage, ElMessageBox } from 'element-plus'

const userStore = useUserStore()
const userInfo = computed(() => userStore.userInfo)
const isStudent = computed(() => userInfo.value?.role === 'student')
const isCounselor = computed(() => userInfo.value?.role === 'counselor')
const isAdmin = computed(() => userInfo.value?.role === 'admin')

const loading = ref(false)
const courseList = ref([])
const showMyCourses = ref(false)
const myCoursesList = ref([])
const myLoading = ref(false)
const searchForm = reactive({ courseType: '', isOpen: null })
const pagination = reactive({ current: 1, size: 20, total: 0 })

const fetchCourses = async () => {
  loading.value = true
  try {
    const params = {
      pageNum: pagination.current,
      pageSize: pagination.size,
      ...searchForm
    }
    const res = await getCourseSelectionList(params)
    if (res.code === 200) {
      courseList.value = res.data?.records || []
      pagination.total = res.data?.total || 0
    }
  } catch (e) {
    console.error('获取选课列表失败', e)
  } finally {
    loading.value = false
  }
}

const fetchMyCourses = async () => {
  myLoading.value = true
  try {
    const res = await getMyCourses()
    if (res.code === 200) myCoursesList.value = res.data || []
  } catch (e) {
    console.error('获取我的选课失败', e)
  } finally {
    myLoading.value = false
  }
}

const handleSelect = async (course) => {
  if (course.isOpen !== 1) {
    ElMessage.warning('该课程尚未开放选课，请等待辅导员开放')
    return
  }
  try {
    await ElMessageBox.confirm(`确定选择「${course.courseName}」吗？`, '选课确认', { type: 'info' })
    const res = await selectCourse(course.id)
    if (res.code === 200) {
      ElMessage.success('选课成功')
      fetchCourses()
    } else {
      ElMessage.error(res.message || '选课失败')
    }
  } catch (e) {
    if (e !== 'cancel') ElMessage.error('选课失败')
  }
}

const handleDrop = async (row) => {
  try {
    await ElMessageBox.confirm(`确定退选「${row.courseName}」吗？`, '退课确认', { type: 'warning' })
    const res = await dropCourse(row.id || row.courseId)
    if (res.code === 200) {
      ElMessage.success('退课成功')
      fetchMyCourses()
      fetchCourses()
    } else {
      ElMessage.error(res.message || '退课失败')
    }
  } catch (e) {
    if (e !== 'cancel') ElMessage.error('退课失败')
  }
}

const handleOpenCourse = async (id) => {
  try {
    const res = await openCourseSelection(id)
    if (res.code === 200) { ElMessage.success('已开放选课'); fetchCourses() }
    else ElMessage.error(res.message || '操作失败')
  } catch (e) { ElMessage.error('操作失败') }
}

const handleCloseCourse = async (id) => {
  try {
    const res = await closeCourseSelection(id)
    if (res.code === 200) { ElMessage.success('已关闭选课'); fetchCourses() }
    else ElMessage.error(res.message || '操作失败')
  } catch (e) { ElMessage.error('操作失败') }
}

const handleBatchOpen = async () => {
  try {
    await ElMessageBox.confirm('确定批量开放所有未开放的课程吗？', '批量开放', { type: 'info' })
    for (const c of courseList.value) {
      if (c.isOpen === 0) await openCourseSelection(c.id)
    }
    ElMessage.success('批量开放完成')
    fetchCourses()
  } catch (e) { /* cancel */ }
}

const handleBatchClose = async () => {
  try {
    await ElMessageBox.confirm('确定批量关闭所有已开放的课程吗？', '批量关闭', { type: 'warning' })
    for (const c of courseList.value) {
      if (c.isOpen === 1) await closeCourseSelection(c.id)
    }
    ElMessage.success('批量关闭完成')
    fetchCourses()
  } catch (e) { /* cancel */ }
}

onMounted(() => {
  fetchCourses()
  if (isStudent.value) fetchMyCourses()
})
</script>

<style scoped>
.selection-container { padding: 0; }
.page-header {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 24px; flex-wrap: wrap; gap: 12px;
}
.page-title {
  display: flex; align-items: center; gap: 12px;
  font-size: 24px; font-weight: 700; color: #2C3E50;
}
.header-actions { display: flex; gap: 8px; }
.main-card {
  border-radius: 16px !important; border: none !important;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08) !important;
}
.main-card :deep(.el-card__body) { padding: 24px; }
.search-section {
  margin-bottom: 16px; padding: 16px; background: #f8f9fa; border-radius: 12px;
}
.search-section :deep(.el-form-item) { margin-bottom: 0; }
.batch-actions { margin-bottom: 16px; display: flex; gap: 8px; }
.pagination-container { display: flex; justify-content: flex-end; padding: 16px 0; }
</style>
