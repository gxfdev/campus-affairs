<template>
  <div class="counselor-panel">
    <div class="page-header">
      <div class="page-title">
        <el-icon><Avatar /></el-icon>
        <span>辅导员工作台</span>
      </div>
      <div class="counselor-info" v-if="counselorInfo">
        <el-tag type="primary" size="large">{{ counselorInfo.college }} - {{ gradeMap[counselorInfo.grade] }}</el-tag>
      </div>
    </div>

    <!-- 统计卡片 -->
    <el-row :gutter="20" class="stat-row">
      <el-col :span="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-icon" style="background: rgba(64, 158, 255, 0.1); color: #409EFF">
            <el-icon :size="28"><User /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ studentTotal }}</div>
            <div class="stat-label">负责学生</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-icon" style="background: rgba(103, 194, 58, 0.1); color: #67C23A">
            <el-icon :size="28"><Calendar /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ pendingLeaves }}</div>
            <div class="stat-label">待审批请假</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-icon" style="background: rgba(230, 162, 60, 0.1); color: #E6A23C">
            <el-icon :size="28"><ShoppingCart /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ openCourses }}</div>
            <div class="stat-label">已开放选课</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-icon" style="background: rgba(245, 108, 108, 0.1); color: #F56C6C">
            <el-icon :size="28"><Trophy /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ scoreCount }}</div>
            <div class="stat-label">成绩记录</div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- Tab 面板 -->
    <el-card class="main-card">
      <el-tabs v-model="activeTab" type="border-card">
        <!-- 学生管理 -->
        <el-tab-pane label="学生管理" name="students">
          <div class="tab-header">
            <el-input v-model="studentKeyword" placeholder="搜索学生姓名/学号/班级" style="width: 260px" clearable @clear="fetchStudents" @keyup.enter="fetchStudents">
              <template #prefix><el-icon><Search /></el-icon></template>
            </el-input>
            <el-button type="primary" @click="fetchStudents">查询</el-button>
          </div>
          <el-table :data="studentList" v-loading="studentLoading" stripe>
            <el-table-column prop="studentNo" label="学号" width="120" />
            <el-table-column prop="realName" label="姓名" width="100" />
            <el-table-column prop="gender" label="性别" width="60" align="center" />
            <el-table-column prop="college" label="学院" min-width="140" />
            <el-table-column prop="major" label="专业" min-width="120" />
            <el-table-column prop="className" label="班级" width="100" />
            <el-table-column prop="dormitory" label="宿舍" width="100" />
            <el-table-column prop="enrollmentYear" label="入学年份" width="90" align="center" />
          </el-table>
          <div class="pagination-container">
            <el-pagination
              v-model:current-page="studentPage.current"
              v-model:page-size="studentPage.size"
              :total="studentPage.total"
              layout="total, prev, pager, next"
              @current-change="fetchStudents"
            />
          </div>
        </el-tab-pane>

        <!-- 请假审批 -->
        <el-tab-pane label="请假审批" name="leave">
          <el-table :data="leaveList" v-loading="leaveLoading" stripe>
            <el-table-column prop="studentName" label="学生" width="100" />
            <el-table-column prop="className" label="班级" width="100" />
            <el-table-column prop="leaveType" label="请假类型" width="90" align="center">
              <template #default="{ row }">
                <el-tag :type="row.leaveType === '病假' ? 'danger' : 'warning'" size="small">{{ row.leaveType }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="reason" label="请假原因" min-width="180" show-overflow-tooltip />
            <el-table-column prop="startTime" label="开始时间" width="110" />
            <el-table-column prop="endTime" label="结束时间" width="110" />
            <el-table-column prop="status" label="状态" width="90" align="center">
              <template #default="{ row }">
                <el-tag :type="statusMap[row.status]" size="small">{{ statusLabel[row.status] }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="160" align="center">
              <template #default="{ row }">
                <template v-if="row.status === 0">
                  <el-button type="success" size="small" @click="handleApprove(row.id, 1)">批准</el-button>
                  <el-button type="danger" size="small" @click="handleApprove(row.id, 2)">驳回</el-button>
                </template>
                <span v-else style="color: #909399; font-size: 12px">已处理</span>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>

        <!-- 选课管理 -->
        <el-tab-pane label="选课管理" name="course">
          <div class="tab-header">
            <el-button type="success" @click="handleBatchOpen" :loading="courseLoading">批量开放选课</el-button>
            <el-button type="warning" @click="handleBatchClose" :loading="courseLoading">批量关闭选课</el-button>
          </div>
          <el-table :data="courseList" v-loading="courseLoading" stripe>
            <el-table-column prop="courseName" label="课程名称" min-width="150" />
            <el-table-column prop="teacherName" label="授课教师" width="100" />
            <el-table-column prop="credit" label="学分" width="70" align="center" />
            <el-table-column prop="maxStudents" label="容量" width="70" align="center" />
            <el-table-column prop="currentStudents" label="已选" width="70" align="center" />
            <el-table-column prop="isOpen" label="选课状态" width="100" align="center">
              <template #default="{ row }">
                <el-tag :type="row.isOpen === 1 ? 'success' : 'info'" size="small">
                  {{ row.isOpen === 1 ? '已开放' : '未开放' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="120" align="center">
              <template #default="{ row }">
                <el-button v-if="row.isOpen === 0" type="success" size="small" @click="handleOpenCourse(row.id)">开放</el-button>
                <el-button v-else type="warning" size="small" @click="handleCloseCourse(row.id)">关闭</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>

        <!-- 成绩录入 -->
        <el-tab-pane label="成绩录入" name="score">
          <div class="tab-header">
            <el-button type="primary" @click="showScoreDialog = true">录入成绩</el-button>
            <el-select v-model="scoreSemester" placeholder="选择学期" style="width: 160px; margin-left: 12px" @change="fetchScores">
              <el-option label="2025-2026-1" value="2025-2026-1" />
              <el-option label="2024-2025-2" value="2024-2025-2" />
              <el-option label="2024-2025-1" value="2024-2025-1" />
            </el-select>
          </div>
          <el-table :data="scoreList" v-loading="scoreLoading" stripe>
            <el-table-column prop="studentName" label="学生" width="100" />
            <el-table-column prop="studentNo" label="学号" width="120" />
            <el-table-column prop="courseName" label="课程" min-width="150" />
            <el-table-column prop="score" label="成绩" width="80" align="center">
              <template #default="{ row }">
                <span :style="{ color: row.score < 60 ? '#F56C6C' : '#67C23A', fontWeight: 600 }">{{ row.score }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="credit" label="学分" width="70" align="center" />
            <el-table-column prop="courseType" label="课程类型" width="100" align="center">
              <template #default="{ row }">
                <el-tag size="small" :type="row.courseType === '必修' ? '' : 'warning'">{{ row.courseType }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="semester" label="学期" width="120" />
          </el-table>
          <div class="pagination-container">
            <el-pagination
              v-model:current-page="scorePage.current"
              v-model:page-size="scorePage.size"
              :total="scorePage.total"
              layout="total, prev, pager, next"
              @current-change="fetchScores"
            />
          </div>
        </el-tab-pane>
      </el-tabs>
    </el-card>

    <!-- 成绩录入对话框 -->
    <el-dialog v-model="showScoreDialog" title="录入成绩" width="500px">
      <el-form :model="scoreForm" label-width="80px">
        <el-form-item label="学生">
          <el-select v-model="scoreForm.studentId" filterable placeholder="选择学生" style="width: 100%">
            <el-option v-for="s in allStudents" :key="s.id" :label="`${s.realName}(${s.studentNo})`" :value="s.id" />
          </el-select>
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
        <el-button @click="showScoreDialog = false">取消</el-button>
        <el-button type="primary" @click="handleAddScore">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { useUserStore } from '@/stores/user'
import { getMyStudents, getAllMyStudents, getMyCounselorInfo } from '@/api/counselor'
import { getCourseSelectionList, openCourseSelection, closeCourseSelection } from '@/api/courseSelection'
import { getScoreByCounselor, addScore } from '@/api/score'
import { getLeaveRequests, approveLeaveRequest } from '@/api/leave'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const userInfo = computed(() => userStore.userInfo)
const counselorInfo = ref(null)
const gradeMap = { 1: '大一', 2: '大二', 3: '大三', 4: '大四' }
const statusMap = { 0: 'warning', 1: 'success', 2: 'danger' }
const statusLabel = { 0: '待审批', 1: '已批准', 2: '已驳回' }

const activeTab = ref('students')

// 学生管理
const studentLoading = ref(false)
const studentList = ref([])
const studentKeyword = ref('')
const studentPage = reactive({ current: 1, size: 10, total: 0 })
const studentTotal = ref(0)
const allStudents = ref([])

// 请假管理
const leaveLoading = ref(false)
const leaveList = ref([])
const pendingLeaves = ref(0)

// 选课管理
const courseLoading = ref(false)
const courseList = ref([])
const openCourses = ref(0)

// 成绩管理
const scoreLoading = ref(false)
const scoreList = ref([])
const scoreSemester = ref('2025-2026-1')
const scorePage = reactive({ current: 1, size: 10, total: 0 })
const scoreCount = ref(0)
const showScoreDialog = ref(false)
const scoreForm = ref({
  studentId: null, courseName: '', score: 0, credit: 2, courseType: '必修', semester: '2025-2026-1'
})

const fetchCounselorInfo = async () => {
  try {
    const res = await getMyCounselorInfo()
    if (res.code === 200) counselorInfo.value = res.data
  } catch (e) { /* 静默处理 */ }
}

const fetchStudents = async () => {
  studentLoading.value = true
  try {
    const res = await getMyStudents({
      pageNum: studentPage.current,
      pageSize: studentPage.size,
      keyword: studentKeyword.value
    })
    if (res.code === 200) {
      studentList.value = res.data?.records || []
      studentPage.total = res.data?.total || 0
      studentTotal.value = res.data?.total || 0
    }
  } catch (e) { /* 静默处理 */ } finally { studentLoading.value = false }
}

const fetchAllStudents = async () => {
  try {
    const res = await getAllMyStudents()
    if (res.code === 200) allStudents.value = res.data || []
  } catch (e) { /* 静默处理 */ }
}

const fetchLeaves = async () => {
  leaveLoading.value = true
  try {
    const res = await getLeaveRequests({ pageNum: 1, pageSize: 100 })
    if (res.code === 200) {
      leaveList.value = res.data?.records || []
      pendingLeaves.value = leaveList.value.filter(l => l.status === 0).length
    }
  } catch (e) { /* 静默处理 */ } finally { leaveLoading.value = false }
}

const handleApprove = async (id, status) => {
  try {
    const res = await approveLeaveRequest({ id, status, comment: status === 1 ? '批准' : '驳回' })
    if (res.code === 200) {
      ElMessage.success(status === 1 ? '已批准' : '已驳回')
      fetchLeaves()
    } else {
      ElMessage.error(res.message || '操作失败')
    }
  } catch (e) { ElMessage.error('操作失败') }
}

const fetchCourses = async () => {
  courseLoading.value = true
  try {
    const res = await getCourseSelectionList({ pageNum: 1, pageSize: 100 })
    if (res.code === 200) {
      courseList.value = res.data?.records || []
      openCourses.value = courseList.value.filter(c => c.isOpen === 1).length
    }
  } catch (e) { /* 静默处理 */ } finally { courseLoading.value = false }
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
  for (const c of courseList.value) {
    if (c.isOpen === 0) await handleOpenCourse(c.id)
  }
}

const handleBatchClose = async () => {
  for (const c of courseList.value) {
    if (c.isOpen === 1) await handleCloseCourse(c.id)
  }
}

const fetchScores = async () => {
  scoreLoading.value = true
  try {
    const res = await getScoreByCounselor({
      pageNum: scorePage.current,
      pageSize: scorePage.size,
      semester: scoreSemester.value
    })
    if (res.code === 200) {
      scoreList.value = res.data?.records || []
      scorePage.total = res.data?.total || 0
      scoreCount.value = res.data?.total || 0
    }
  } catch (e) { /* 静默处理 */ } finally { scoreLoading.value = false }
}

const handleAddScore = async () => {
  try {
    const res = await addScore(scoreForm.value)
    if (res.code === 200) {
      ElMessage.success('录入成功')
      showScoreDialog.value = false
      fetchScores()
    } else {
      ElMessage.error(res.message || '录入失败')
    }
  } catch (e) { ElMessage.error('录入失败') }
}

onMounted(async () => {
  await fetchCounselorInfo()
  fetchStudents()
  fetchAllStudents()
  fetchLeaves()
  fetchCourses()
  fetchScores()
})
</script>

<style scoped>
.counselor-panel { padding: 0; }
.page-header {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 24px; flex-wrap: wrap; gap: 12px;
}
.page-title {
  display: flex; align-items: center; gap: 12px;
  font-size: 24px; font-weight: 700; color: #2C3E50;
}
.stat-row { margin-bottom: 24px; }
.stat-card {
  border-radius: 16px !important; border: none !important;
  box-shadow: 0 4px 20px rgba(0,0,0,0.08) !important;
}
.stat-card :deep(.el-card__body) {
  display: flex; align-items: center; gap: 16px; padding: 20px;
}
.stat-icon {
  width: 56px; height: 56px; border-radius: 14px;
  display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
.stat-value { font-size: 28px; font-weight: 700; color: #2C3E50; }
.stat-label { font-size: 13px; color: #909399; margin-top: 4px; }
.main-card {
  border-radius: 16px !important; border: none !important;
  box-shadow: 0 4px 20px rgba(0,0,0,0.08) !important;
}
.tab-header {
  display: flex; align-items: center; margin-bottom: 16px; gap: 8px;
}
.pagination-container {
  display: flex; justify-content: flex-end; padding: 16px 0;
}
</style>
