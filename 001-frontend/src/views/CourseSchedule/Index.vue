<template>
  <div class="schedule-container">
    <div class="page-header">
      <div class="page-title">
        <el-icon><Notebook /></el-icon>
        <span>课程表</span>
      </div>
      <div class="header-actions">
        <!-- 学院选择 -->
        <el-select v-model="currentCollege" placeholder="选择学院" style="width: 160px" @change="onCollegeChange">
          <el-option v-for="c in colleges" :key="c" :label="c" :value="c" />
        </el-select>
        <!-- 专业选择 -->
        <el-select v-model="currentMajor" placeholder="选择专业" style="width: 180px; margin-left: 8px" @change="onMajorChange">
          <el-option v-for="m in majors" :key="m" :label="m" :value="m" />
        </el-select>
        <!-- 班级选择 -->
        <el-select v-model="currentClass" placeholder="选择班级" style="width: 150px; margin-left: 8px" @change="onClassChange">
          <el-option v-for="cls in classes" :key="cls" :label="cls" :value="cls" />
        </el-select>
        <!-- 学期选择 -->
        <el-select v-model="currentSemester" placeholder="选择学期" style="width: 180px; margin-left: 8px" @change="fetchSchedule">
          <el-option v-for="s in semesters" :key="s" :label="formatSemester(s)" :value="s" />
        </el-select>
        <!-- 周次选择 -->
        <el-select v-model="currentWeek" placeholder="选择周次" style="width: 120px; margin-left: 8px" @change="onWeekChange">
          <el-option v-for="w in 20" :key="w" :label="`第${w}周`" :value="w" />
        </el-select>
        <el-button type="primary" @click="showAddDialog = true" v-if="isAdmin || isCounselor" style="margin-left: 12px">
          <el-icon><Plus /></el-icon>添加课程
        </el-button>
      </div>
    </div>

    <!-- 当前班级信息 -->
    <div class="class-info" v-if="scheduleData.length > 0">
      <el-tag type="primary" size="large">{{ displayClassName }} - {{ formatSemester(currentSemester) }}</el-tag>
      <el-tag type="info" style="margin-left: 8px">第{{ currentWeek }}周</el-tag>
      <el-tag type="success" style="margin-left: 8px">共 {{ courseNames.length }} 门课程</el-tag>
      <el-tag type="warning" style="margin-left: 8px">总学分 {{ totalCredits }} 分</el-tag>
    </div>

    <el-card class="main-card">
      <!-- 课程表网格 -->
      <div class="schedule-grid" v-loading="loading">
        <div class="schedule-header">
          <div class="time-col">节次</div>
          <div class="day-col" v-for="day in days" :key="day.value">{{ day.label }}</div>
        </div>
        <div class="schedule-body">
          <template v-for="period in periodSlots" :key="period.label">
            <div class="period-divider" v-if="period.label === '下午'">
              <div class="divider-line"></div>
              <div class="divider-text">午 休</div>
              <div class="divider-line"></div>
            </div>
            <div class="period-row" v-for="p in period.slots" :key="p">
              <div class="time-col">
                <div class="period-num">第{{ p }}-{{ p+1 }}节</div>
                <div class="period-time">{{ getPeriodTime(p) }}</div>
              </div>
              <div class="day-col" v-for="day in 5" :key="day">
                <div
                  v-for="course in getCourseForSlot(day, p)"
                  :key="course.id"
                  class="course-cell"
                  :style="{ background: getCourseColor(course.courseName), borderLeft: '3px solid ' + getCourseBorderColor(course.courseName) }"
                  @click="showCourseDetail(course)"
                >
                  <div class="course-name">{{ course.courseName }}</div>
                  <div class="course-info">{{ course.teacherName }}</div>
                  <div class="course-info">{{ course.location }}</div>
                  <div class="course-tags">
                    <span class="course-tag" v-if="course.courseType">{{ course.courseType }}</span>
                    <span class="course-tag" v-if="course.credit">{{ course.credit }}学分</span>
                  </div>
                </div>
              </div>
            </div>
          </template>
        </div>
      </div>
      <el-empty v-if="!loading && scheduleData.length === 0" description="暂无课程表数据" />

      <!-- 课程列表视图 -->
      <div class="course-list-view" v-if="scheduleData.length > 0">
        <el-divider content-position="left">课程列表</el-divider>
        <el-table :data="courseListData" stripe class="course-table">
          <el-table-column prop="courseName" label="课程名称" min-width="150" />
          <el-table-column prop="teacherName" label="授课教师" width="100" />
          <el-table-column prop="location" label="上课地点" width="120" />
          <el-table-column label="上课时间" width="120">
            <template #default="{ row }">
              {{ getDayName(row.dayOfWeek) }} 第{{ row.periodStart }}-{{ row.periodEnd }}节
            </template>
          </el-table-column>
          <el-table-column prop="courseType" label="课程类型" width="80" />
          <el-table-column prop="credit" label="学分" width="60" />
        </el-table>
      </div>
    </el-card>

    <!-- 课程详情对话框 -->
    <el-dialog v-model="showDetailDialog" title="课程详情" width="450px">
      <el-descriptions :column="1" border v-if="currentCourse">
        <el-descriptions-item label="课程名称">{{ currentCourse.courseName }}</el-descriptions-item>
        <el-descriptions-item label="授课教师">{{ currentCourse.teacherName }}</el-descriptions-item>
        <el-descriptions-item label="上课地点">{{ currentCourse.location }}</el-descriptions-item>
        <el-descriptions-item label="上课时间">{{ getDayName(currentCourse.dayOfWeek) }} 第{{ currentCourse.periodStart }}-{{ currentCourse.periodEnd }}节</el-descriptions-item>
        <el-descriptions-item label="学期">{{ formatSemester(currentCourse.semester) }}</el-descriptions-item>
        <el-descriptions-item label="课程类型">{{ currentCourse.courseType || '必修' }}</el-descriptions-item>
        <el-descriptions-item label="学分">{{ currentCourse.credit || '2.0' }} 分</el-descriptions-item>
          <el-descriptions-item label="周次">第{{ currentCourse.weekStart || 1 }}-{{ currentCourse.weekEnd || 20 }}周</el-descriptions-item>
      </el-descriptions>
    </el-dialog>

    <!-- 添加课程对话框 -->
    <el-dialog v-model="showAddDialog" title="添加课程" width="520px">
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
        <el-form-item label="课程类型">
          <el-select v-model="courseForm.courseType" style="width: 100%">
            <el-option label="必修" value="必修" />
            <el-option label="选修" value="选修" />
            <el-option label="实践" value="实践" />
            <el-option label="综合实验" value="综合实验" />
          </el-select>
        </el-form-item>
        <el-form-item label="学分">
          <el-input-number v-model="courseForm.credit" :min="0.5" :max="6" :step="0.5" style="width: 100%" />
        </el-form-item>
        <el-form-item label="起止周次">
          <el-row :gutter="10">
            <el-col :span="12">
              <el-input-number v-model="courseForm.weekStart" :min="1" :max="20" style="width: 100%" placeholder="开始周" />
            </el-col>
            <el-col :span="12">
              <el-input-number v-model="courseForm.weekEnd" :min="1" :max="20" style="width: 100%" placeholder="结束周" />
            </el-col>
          </el-row>
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
import { getScheduleByClass, addCourseSchedule, getColleges, getMajors, getClasses, getSemesters } from '@/api/courseSchedule'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const userInfo = computed(() => userStore.userInfo)
const isAdmin = computed(() => userInfo.value?.role === 'admin')
const isCounselor = computed(() => userInfo.value?.role === 'counselor')
const isStudent = computed(() => userInfo.value?.role === 'student')

const loading = ref(false)
const showAddDialog = ref(false)
const showDetailDialog = ref(false)
const currentCourse = ref(null)
const currentSemester = ref('')
const currentWeek = ref(1)
const currentClass = ref('')
const currentCollege = ref('')
const currentMajor = ref('')
const scheduleData = ref([])
const colleges = ref([])
const majors = ref([])
const classes = ref([])
const semesters = ref([])

const days = [
  { label: '周一', value: 1 },
  { label: '周二', value: 2 },
  { label: '周三', value: 3 },
  { label: '周四', value: 4 },
  { label: '周五', value: 5 }
]

// 上午1-4节，下午5-8节
const periodSlots = [
  { label: '上午', slots: [1, 3] },
  { label: '下午', slots: [5, 7] }
]

// 节次对应时间
const periodTimes = {
  1: '08:00-09:40',
  3: '10:00-11:40',
  5: '14:00-15:40',
  7: '16:00-17:40'
}

const courseForm = ref({
  className: '',
  courseName: '',
  teacherName: '',
  location: '',
  dayOfWeek: 1,
  periodStart: 1,
  periodEnd: 2,
  semester: '2025-2026-1',
  credit: 2.0,
  courseType: '必修',
  weekStart: 1,
  weekEnd: 20
})

const displayClassName = computed(() => {
  if (isStudent.value) return userInfo.value?.className || ''
  return currentClass.value
})

const courseNames = computed(() => {
  return [...new Set(scheduleData.value.map(c => c.courseName))]
})

const totalCredits = computed(() => {
  const names = courseNames.value
  let total = 0
  names.forEach(name => {
    const course = scheduleData.value.find(c => c.courseName === name)
    if (course && course.credit) {
      total += parseFloat(course.credit)
    }
  })
  return total.toFixed(1)
})

const courseListData = computed(() => {
  // 去重，每个课程只显示一次
  const seen = new Set()
  return scheduleData.value.filter(c => {
    if (seen.has(c.courseName)) return false
    seen.add(c.courseName)
    return true
  })
})

const colorMap = {}
let colorIndex = 0
const colorPairs = [
  { bg: 'rgba(64, 158, 255, 0.12)', border: '#409EFF' },
  { bg: 'rgba(103, 194, 58, 0.12)', border: '#67C23A' },
  { bg: 'rgba(230, 162, 60, 0.12)', border: '#E6A23C' },
  { bg: 'rgba(245, 108, 108, 0.12)', border: '#F56C6C' },
  { bg: 'rgba(144, 147, 153, 0.12)', border: '#909399' },
  { bg: 'rgba(102, 177, 255, 0.12)', border: '#66B1FF' },
  { bg: 'rgba(149, 238, 105, 0.12)', border: '#95EE69' },
  { bg: 'rgba(255, 195, 0, 0.12)', border: '#FFC300' },
  { bg: 'rgba(232, 121, 249, 0.12)', border: '#E879F9' },
  { bg: 'rgba(45, 211, 111, 0.12)', border: '#2DD36F' }
]

const getCourseColor = (name) => {
  if (!colorMap[name]) {
    colorMap[name] = colorPairs[colorIndex % colorPairs.length].bg
    colorIndex++
  }
  return colorMap[name]
}

const getCourseBorderColor = (name) => {
  if (!colorMap[name]) {
    getCourseColor(name)
  }
  const keys = Object.keys(colorMap)
  const i = keys.indexOf(name)
  return colorPairs[i % colorPairs.length].border
}

const getCourseForSlot = (day, period) => {
  return scheduleData.value.filter(c =>
    c.dayOfWeek === day && period >= c.periodStart && period <= c.periodEnd
  )
}

const getPeriodTime = (p) => {
  return periodTimes[p] || ''
}

const getDayName = (day) => {
  const d = days.find(d => d.value === day)
  return d ? d.label : ''
}

const formatSemester = (s) => {
  if (!s) return ''
  // 2025-2026-1 -> 2025-2026学年第一学期
  const parts = s.split('-')
  if (parts.length === 3) {
    return `${parts[0]}-${parts[1]}学年第${parts[2] === '1' ? '一' : '二'}学期`
  }
  return s
}

const showCourseDetail = (course) => {
  currentCourse.value = course
  showDetailDialog.value = true
}

const onCollegeChange = async () => {
  currentMajor.value = ''
  currentClass.value = ''
  majors.value = []
  classes.value = []
  semesters.value = []
  scheduleData.value = []
  if (currentCollege.value) {
    const res = await getMajors(currentCollege.value)
    if (res.code === 200) majors.value = res.data || []
  }
}

const onMajorChange = async () => {
  currentClass.value = ''
  classes.value = []
  semesters.value = []
  scheduleData.value = []
  if (currentMajor.value) {
    const res = await getClasses({ college: currentCollege.value, major: currentMajor.value })
    if (res.code === 200) classes.value = res.data || []
  }
}

const onClassChange = async () => {
  semesters.value = []
  scheduleData.value = []
  currentSemester.value = ''
  if (currentClass.value) {
    await loadSemesters(currentClass.value)
  }
}

const onWeekChange = () => {
  // 按周次重新获取课程数据
  fetchSchedule()
}

const loadSemesters = async (className) => {
  try {
    const res = await getSemesters(className)
    if (res.code === 200) {
      semesters.value = res.data || []
      if (semesters.value.length > 0) {
        currentSemester.value = semesters.value[0]
        await fetchSchedule()
      }
    }
  } catch (e) {
    // 静默处理
  }
}

const fetchSchedule = async () => {
  loading.value = true
  try {
    const className = currentClass.value
    if (!className) {
      loading.value = false
      scheduleData.value = []
      return
    }
    const res = await getScheduleByClass(className, currentSemester.value, currentWeek.value)
    if (res.code === 200) scheduleData.value = res.data || []
  } catch (e) {
    // 静默处理
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

onMounted(async () => {
  // 加载学院列表
  const res = await getColleges()
  if (res.code === 200) colleges.value = res.data || []
  // 如果有班级信息，自动加载本班课表
  if (userInfo.value?.className) {
    currentClass.value = userInfo.value.className
    // 自动设置学院和专业
    if (userInfo.value?.college) {
      currentCollege.value = userInfo.value.college
      const majorRes = await getMajors(currentCollege.value)
      if (majorRes.code === 200) majors.value = majorRes.data || []
    }
    if (userInfo.value?.major) {
      currentMajor.value = userInfo.value.major
      const classRes = await getClasses({ college: currentCollege.value, major: currentMajor.value })
      if (classRes.code === 200) classes.value = classRes.data || []
    }
    await loadSemesters(currentClass.value)
  }
})
</script>

<style scoped>
.schedule-container { padding: 0; }

.page-header {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 24px; flex-wrap: wrap; gap: 12px;
}
.page-title {
  display: flex; align-items: center; gap: 12px;
  font-size: 24px; font-weight: 700; color: #2C3E50;
}
.header-actions {
  display: flex; align-items: center; flex-wrap: wrap; gap: 4px;
}
.class-info {
  margin-bottom: 16px; display: flex; align-items: center; flex-wrap: wrap; gap: 4px;
}
.main-card {
  border-radius: 16px !important; border: none !important;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08) !important;
}
.schedule-grid { overflow-x: auto; }
.schedule-header { display: flex; border-bottom: 2px solid #ebeef5; }
.schedule-header .time-col, .schedule-header .day-col {
  padding: 12px 8px; text-align: center; font-weight: 600; color: #2C3E50; background: #f8f9fa;
}
.time-col { min-width: 90px; flex-shrink: 0; }
.day-col { min-width: 150px; flex: 1; }
.period-divider {
  display: flex; align-items: center; padding: 8px 0; gap: 12px;
}
.divider-line { flex: 1; height: 1px; background: #e4e7ed; }
.divider-text { font-size: 12px; color: #909399; white-space: nowrap; }
.period-row { display: flex; border-bottom: 1px solid #ebeef5; min-height: 80px; }
.period-row .time-col {
  display: flex; flex-direction: column; align-items: center; justify-content: center; background: #fafbfc;
}
.period-num { font-size: 13px; color: #606266; font-weight: 500; }
.period-time { font-size: 11px; color: #C0C4CC; margin-top: 2px; }
.period-row .day-col { border-left: 1px solid #ebeef5; padding: 4px; position: relative; }
.course-cell {
  border-radius: 8px; padding: 8px 10px; margin: 2px; cursor: pointer; transition: transform 0.2s;
}
.course-cell:hover { transform: scale(1.02); }
.course-name { font-size: 13px; font-weight: 600; color: #2C3E50; margin-bottom: 4px; }
.course-info { font-size: 11px; color: #909399; }
.course-tags { margin-top: 4px; display: flex; gap: 4px; flex-wrap: wrap; }
.course-tag {
  font-size: 10px; padding: 1px 6px; border-radius: 4px;
  background: rgba(255,255,255,0.6); color: #606266;
}

/* 课程列表视图 */
.course-list-view { margin-top: 24px; }
.course-table { border-radius: 8px; overflow: hidden; }

@media (max-width: 768px) {
  .page-header { flex-direction: column; align-items: flex-start; }
  .header-actions { width: 100%; }
  .day-col { min-width: 110px; }
  .time-col { min-width: 70px; }
}
</style>
