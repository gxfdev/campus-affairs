<template>
  <div class="selection-container">
    <div class="page-header">
      <div class="page-title">
        <el-icon><ShoppingCart /></el-icon>
        <span>选课中心</span>
      </div>
      <el-button type="primary" @click="showMyCourses = true">
        <el-icon><List /></el-icon>我的选课
      </el-button>
    </div>

    <el-card class="main-card">
      <!-- 类型切换 -->
      <el-tabs v-model="activeTab" @tab-change="fetchCourses">
        <el-tab-pane label="公选课" name="optional" />
        <el-tab-pane label="体育课" name="pe" />
      </el-tabs>

      <!-- 课程列表 -->
      <el-row :gutter="16">
        <el-col :xs="24" :sm="12" :md="8" :lg="6" v-for="course in courseList" :key="course.id">
          <div class="course-card" :class="{ 'is-full': course.status === 'full' }">
            <div class="course-type-badge">
              {{ course.courseType === 'optional' ? '公选' : '体育' }}
            </div>
            <div class="course-name">{{ course.courseName }}</div>
            <div class="course-teacher">{{ course.teacherName }}</div>
            <div class="course-meta">
              <span><el-icon><Location /></el-icon>{{ course.location || '待定' }}</span>
              <span>{{ course.credit }}学分</span>
            </div>
            <div class="course-progress">
              <el-progress
                :percentage="Math.round(course.currentStudents / course.maxStudents * 100)"
                :color="course.status === 'full' ? '#F56C6C' : '#409EFF'"
                :stroke-width="6"
              />
              <span class="progress-text">{{ course.currentStudents }}/{{ course.maxStudents }}</span>
            </div>
            <el-button
              v-if="isStudent"
              :type="course.status === 'full' ? 'info' : 'primary'"
              :disabled="course.status === 'full'"
              @click="handleSelect(course)"
              style="width: 100%; margin-top: 12px"
            >
              {{ course.status === 'full' ? '已满' : '选课' }}
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
          @current-change="fetchCourses"
        />
      </div>
    </el-card>

    <!-- 我的选课对话框 -->
    <el-dialog v-model="showMyCourses" title="我的选课" width="600px">
      <el-table :data="myCoursesList" v-loading="myLoading">
        <el-table-column prop="course.courseName" label="课程名称" />
        <el-table-column prop="course.teacherName" label="教师" width="100" />
        <el-table-column prop="course.credit" label="学分" width="80" align="center" />
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
import { getCourseSelectionList, selectCourse, dropCourse, getMyCourses } from '@/api/courseSelection'
import { ElMessage, ElMessageBox } from 'element-plus'

const userStore = useUserStore()
const userInfo = computed(() => userStore.userInfo)
const isStudent = computed(() => userInfo.value?.role === 'student')

const activeTab = ref('optional')
const courseList = ref([])
const loading = ref(false)
const showMyCourses = ref(false)
const myCoursesList = ref([])
const myLoading = ref(false)
const pagination = reactive({ current: 1, size: 12, total: 0 })

const fetchCourses = async () => {
  loading.value = true
  try {
    const res = await getCourseSelectionList({
      pageNum: pagination.current,
      pageSize: pagination.size,
      courseType: activeTab.value,
      semester: '2025-2026-1'
    })
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
    if (res.code === 200) {
      myCoursesList.value = res.data || []
    }
  } catch (e) {
    console.error('获取我的选课失败', e)
  } finally {
    myLoading.value = false
  }
}

const handleSelect = async (course) => {
  try {
    await ElMessageBox.confirm(`确定选择「${course.courseName}」吗？`, '选课确认', {
      type: 'info'
    })
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
    await ElMessageBox.confirm(`确定退选「${row.course?.courseName}」吗？`, '退课确认', {
      type: 'warning'
    })
    const res = await dropCourse(row.courseId)
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
.main-card {
  border-radius: 16px !important; border: none !important;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08) !important;
}
.main-card :deep(.el-card__body) { padding: 24px; }
.course-card {
  background: white; border: 1px solid #ebeef5; border-radius: 12px;
  padding: 20px; margin-bottom: 16px; position: relative;
  transition: all 0.3s;
}
.course-card:hover {
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}
.course-card.is-full { opacity: 0.7; }
.course-type-badge {
  position: absolute; top: 12px; right: 12px;
  background: #409EFF; color: white; font-size: 12px;
  padding: 2px 8px; border-radius: 10px;
}
.course-name {
  font-size: 16px; font-weight: 700; color: #2C3E50; margin-bottom: 6px;
  padding-right: 50px;
}
.course-teacher { font-size: 13px; color: #606266; margin-bottom: 10px; }
.course-meta {
  display: flex; justify-content: space-between; font-size: 12px; color: #909399;
  margin-bottom: 10px;
}
.course-meta span { display: flex; align-items: center; gap: 4px; }
.course-progress {
  display: flex; align-items: center; gap: 8px;
}
.course-progress :deep(.el-progress) { flex: 1; }
.progress-text { font-size: 12px; color: #909399; white-space: nowrap; }
.pagination-container {
  display: flex; justify-content: center; padding: 16px 0;
}
@media (max-width: 768px) {
  .page-header { flex-direction: column; align-items: flex-start; }
}
</style>
