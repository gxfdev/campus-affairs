<template>
  <div class="counselor-container">
    <div class="page-header">
      <div class="page-title">
        <el-icon><Avatar /></el-icon>
        <span>辅导员管理</span>
      </div>
      <el-button type="primary" @click="showAddDialog = true">
        <el-icon><Plus /></el-icon>添加辅导员
      </el-button>
    </div>

    <el-card class="main-card">
      <!-- 搜索 -->
      <div class="search-section">
        <el-form :inline="true" :model="searchForm">
          <el-form-item label="学院">
            <el-input v-model="searchForm.college" placeholder="请输入学院" clearable style="width: 160px" />
          </el-form-item>
          <el-form-item label="年级">
            <el-select v-model="searchForm.grade" placeholder="全部" clearable style="width: 120px">
              <el-option label="大一" :value="1" />
              <el-option label="大二" :value="2" />
              <el-option label="大三" :value="3" />
              <el-option label="大四" :value="4" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="fetchCounselors">查询</el-button>
            <el-button @click="resetSearch">重置</el-button>
          </el-form-item>
        </el-form>
      </div>

      <!-- 表格 -->
      <el-table :data="counselorList" v-loading="loading" stripe>
        <el-table-column prop="id" label="ID" width="80" align="center" />
        <el-table-column label="辅导员" min-width="120">
          <template #default="{ row }">
            {{ row.user?.realName || row.user?.username || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="college" label="负责学院" min-width="150" />
        <el-table-column prop="grade" label="负责年级" width="100" align="center">
          <template #default="{ row }">
            {{ gradeMap[row.grade] || row.grade }}
          </template>
        </el-table-column>
        <el-table-column prop="description" label="简介" min-width="200" />
        <el-table-column label="操作" width="160" align="center">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row.id)">删除</el-button>
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
          @current-change="fetchCounselors"
        />
      </div>
    </el-card>

    <!-- 添加/编辑对话框 -->
    <el-dialog v-model="showAddDialog" :title="editingItem ? '编辑辅导员' : '添加辅导员'" width="500px">
      <el-form :model="form" label-width="80px">
        <el-form-item label="用户ID">
          <el-input v-model="form.userId" placeholder="关联的用户ID" :disabled="!!editingItem" />
        </el-form-item>
        <el-form-item label="负责学院">
          <el-input v-model="form.college" placeholder="请输入学院名称" />
        </el-form-item>
        <el-form-item label="负责年级">
          <el-select v-model="form.grade" style="width: 100%">
            <el-option label="大一" :value="1" />
            <el-option label="大二" :value="2" />
            <el-option label="大三" :value="3" />
            <el-option label="大四" :value="4" />
          </el-select>
        </el-form-item>
        <el-form-item label="简介">
          <el-input v-model="form.description" type="textarea" :rows="3" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAddDialog = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getCounselorList, addCounselor, updateCounselor, deleteCounselor } from '@/api/counselor'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const counselorList = ref([])
const showAddDialog = ref(false)
const editingItem = ref(null)
const searchForm = reactive({ college: '', grade: null })
const pagination = reactive({ current: 1, size: 10, total: 0 })
const gradeMap = { 1: '大一', 2: '大二', 3: '大三', 4: '大四' }

const form = ref({ userId: '', college: '', grade: 1, description: '' })

const fetchCounselors = async () => {
  loading.value = true
  try {
    const res = await getCounselorList({
      pageNum: pagination.current,
      pageSize: pagination.size,
      ...searchForm
    })
    if (res.code === 200) {
      counselorList.value = res.data?.records || []
      pagination.total = res.data?.total || 0
    }
  } catch (e) {
    console.error('获取辅导员列表失败', e)
  } finally {
    loading.value = false
  }
}

const resetSearch = () => {
  searchForm.college = ''
  searchForm.grade = null
  pagination.current = 1
  fetchCounselors()
}

const handleEdit = (row) => {
  editingItem.value = row
  form.value = { ...row }
  showAddDialog.value = true
}

const handleSubmit = async () => {
  try {
    const res = editingItem.value
      ? await updateCounselor({ id: editingItem.value.id, ...form.value })
      : await addCounselor(form.value)
    if (res.code === 200) {
      ElMessage.success(editingItem.value ? '更新成功' : '添加成功')
      showAddDialog.value = false
      editingItem.value = null
      form.value = { userId: '', college: '', grade: 1, description: '' }
      fetchCounselors()
    } else {
      ElMessage.error(res.message || '操作失败')
    }
  } catch (e) {
    ElMessage.error('操作失败')
  }
}

const handleDelete = async (id) => {
  try {
    await ElMessageBox.confirm('确定删除该辅导员吗？', '提示', { type: 'warning' })
    const res = await deleteCounselor(id)
    if (res.code === 200) {
      ElMessage.success('删除成功')
      fetchCounselors()
    }
  } catch (e) {
    // 取消
  }
}

onMounted(() => fetchCounselors())
</script>

<style scoped>
.counselor-container { padding: 0; }
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
.search-section :deep(.el-form-item) { margin-bottom: 0; }
.pagination-container {
  display: flex; justify-content: flex-end; padding: 16px 0;
}
</style>
