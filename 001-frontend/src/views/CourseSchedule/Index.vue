<template>
  <div class="schedule-container">
    <div class="page-header">
      <div class="page-title">
        <el-icon><Notebook /></el-icon>
        <span>课程表</span>
      </div>
      <div class="header-actions">
        <el-select v-model="currentSemester" placeholder="选择学期" style="width: 180px" @change="fetchSchedule">
          <el-option label="2025-2026-1" value="2025-2026-1" />
          <el-option label="2024-2025-2" value="2024-2025-2" />
          <el-option label="2024-2025-1" value="2024-2025-1" />
        </el-select>
        <el-select v-model="currentClass" placeholder="选择班级" style="width: 150px; margin-left: 12px" @change="fetchSchedule" v-if="isAdmin">
          <el-option label="计科2401" value="计科2401" />
          <el-option label="计科2301" value="计科2301" />
          <el-option label="计科2201" value="计科2201" />
          <el-option label="计科2101" value="计科2101" />
        </el-select>
        <el-button type="primary" @click="showAddDialog = true" v-if="isAdmin || isTeacher" style="margin-left: 12px">
          <el-icon><Plus /></el-icon>添加课程
        </el-button>
      </div>
    </div>

    <el-card class="main-card">
      <!-- 课程表网格 -->
      <div class="schedule-grid" v-loading="loading">
        <div class="schedule-header">
          <div class="time-col">节次</div>
          <div class="day-col" v-for="day in days" :key="day.value">{{ day.label }}</div>
        </div>
        <div class="schedule-body">
          <div class="period-row" v-for="period in periods" :key="period">
            <div class="time-col">
              <div class="period-num">第{{ period }}节</div>
            </div>
            <div class="day-col" v-for="day in 5" :key="day">
              <div
                v-for="course in getCourseForSlot(day, period)"
                :key="course.id"
                class="course-cell"
                :style="{ background: getCourseColor(course.courseName) }"
              >
                <div class="course-name">{{ course.courseName }}</div>
                <div class="course-info">{{ course.teacherName }}</div>
                <div class="course-info">{{ course.location }}</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </el-card>

    <!-- 添加课程对话框 -->
    <el-dialog v-model="showAddDialog" title="添加课程" width="500px">
      <el-form :model="courseForm" label-width="80px">
        <el-form-item label="班级">
          <el-input v-model="courseForm.className" placeholder="如：计科2401" />
        </el-form-item>
        <el-form-item label="课程名称">
          <el-input v-model="courseForm.courseName" placeholder="请输入课程名称" />
        </el-form-item>
        <el-form-item label="授课教师">
          <el-input v-model="courseForm.teacherName" placeholder="请输入教师姓名" />
        </el-form-item>
        <el-form-item label="上课地点">
          <el-input v-model="courseForm.location" placeholder="请输入上课地点" />
        </el-form-item>
        <el-form-item label="星期">
          <el-select v-model="courseForm.dayOfWeek" style="width: 100%">
            <el-option v-for="d in days" :key="d.value" :label="d.label" :value="d.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="节次">
          <el-row :gutter="10">
            <el-col :span="12">
              <el-input-number v-model="courseForm.periodStart" :min="1" :max="12" style="width: 100%" placeholder="开始" />
            </el-col>
            <el-col :span="12">
              <el-input-number v-model="courseForm.periodEnd" :min="1" :max="12" style="width: 100%" placeholder="结束" />
            </el-col>
          </el-row>
        </el-form-item>
        <el-form-item label="学期">
          <el-input v-model="courseForm.semester" placeholder="如：2025-2026-1" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAddDialog = false">取消</el-button>
        <el-button type="primary" @click="handleAddCourse">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import { getScheduleByClass, addCourseSchedule } from '@/api/courseSchedule'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const userInfo = computed(() => userStore.userInfo)
const isAdmin = computed(() => userInfo.value?.role === 'admin')
const isTeacher = computed(() => userInfo.value?.role === 'teacher')

const loading = ref(false)
const showAddDialog = ref(false)
const currentSemester = ref('2025-2026-1')
const currentClass = ref('计科2401')
const scheduleData = ref([])

const days = [
  { label: '周一', value: 1 },
  { label: '周二', value: 2 },
  { label: '周三', value: 3 },
  { label: '周四', value: 4 },
  { label: '周五', value: 5 }
]
const periods = [1, 2, 3, 4, 5, 6, 7, 8]

const courseForm = ref({
  className: '',
  courseName: '',
  teacherName: '',
  location: '',
  dayOfWeek: 1,
  periodStart: 1,
  periodEnd: 2,
  semester: '2025-2026-1'
})

const colorMap = {}
let colorIndex = 0
const colors = [
  'rgba(64, 158, 255, 0.15)', 'rgba(103, 194, 58, 0.15)', 'rgba(230, 162, 60, 0.15)',
  'rgba(245, 108, 108, 0.15)', 'rgba(144, 147, 153, 0.15)', 'rgba(102, 177, 255, 0.15)',
  'rgba(149, 238, 105, 0.15)', 'rgba(255, 195, 0, 0.15)'
]

const getCourseColor = (name) => {
  if (!colorMap[name]) {
    colorMap[name] = colors[colorIndex % colors.length]
    colorIndex++
  }
  return colorMap[name]
}

const getCourseForSlot = (day, period) => {
  return scheduleData.value.filter(c =>
    c.dayOfWeek === day && period >= c.periodStart && period <= c.periodEnd
  )
}

const fetchSchedule = async () => {
  loading.value = true
  try {
    const className = isAdmin.value || isTeacher.value ? currentClass.value : userInfo.value?.className
    if (!className) {
      loading.value = false
      return
    }
    const res = await getScheduleByClass(className, currentSemester.value)
    if (res.code === 200) {
      scheduleData.value = res.data || []
    }
  } catch (e) {
    console.error('获取课程表失败', e)
  } finally {
    loading.value = false
  }
}

const handleAddCourse = async () => {
  try {
    const res = await addCourseSchedule(courseForm.value)
    if (res.code === 200) {
      ElMessage.success('添加成功')
      showAddDialog.value = false
      fetchSchedule()
    } else {
      ElMessage.error(res.message || '添加失败')
    }
  } catch (e) {
    ElMessage.error('添加失败')
  }
}

onMounted(() => {
  if (userInfo.value?.className) {
    currentClass.value = userInfo.value.className
  }
  fetchSchedule()
})
</script>

<style scoped>
.schedule-container {
  padding: 0;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  flex-wrap: wrap;
  gap: 12px;
}

.page-title {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 24px;
  font-weight: 700;
  color: #2C3E50;
}

.header-actions {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px;
}

.main-card {
  border-radius: 16px !important;
  border: none !important;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08) !important;
}

.schedule-grid {
  overflow-x: auto;
}

.schedule-header {
  display: flex;
  border-bottom: 2px solid #ebeef5;
}

.schedule-header .time-col,
.schedule-header .day-col {
  padding: 12px 8px;
  text-align: center;
  font-weight: 600;
  color: #2C3E50;
  background: #f8f9fa;
}

.time-col {
  min-width: 70px;
  flex-shrink: 0;
}

.day-col {
  min-width: 140px;
  flex: 1;
}

.period-row {
  display: flex;
  border-bottom: 1px solid #ebeef5;
  min-height: 60px;
}

.period-row .time-col {
  display: flex;
  align-items: center;
  justify-content: center;
  background: #fafbfc;
}

.period-num {
  font-size: 13px;
  color: #606266;
  font-weight: 500;
}

.period-row .day-col {
  border-left: 1px solid #ebeef5;
  padding: 4px;
  position: relative;
}

.course-cell {
  border-radius: 8px;
  padding: 8px;
  margin: 2px;
  cursor: pointer;
  transition: transform 0.2s;
}

.course-cell:hover {
  transform: scale(1.02);
}

.course-name {
  font-size: 13px;
  font-weight: 600;
  color: #2C3E50;
  margin-bottom: 4px;
}

.course-info {
  font-size: 11px;
  color: #909399;
}

@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    align-items: flex-start;
  }
  .header-actions {
    width: 100%;
  }
  .day-col {
    min-width: 100px;
  }
}
</style>
