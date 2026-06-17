<template>
  <div class="settings-container">
    <div class="page-header">
      <div class="page-title">
        <el-icon><Setting /></el-icon>
        <span>系统设置</span>
      </div>
    </div>

    <el-row :gutter="24">
      <!-- 基本设置 -->
      <el-col :xs="24" :lg="12">
        <el-card class="settings-card">
          <template #header>
            <div class="card-header">
              <el-icon><InfoFilled /></el-icon>
              <span>基本设置</span>
            </div>
          </template>
          <el-form label-width="120px" class="settings-form">
            <el-form-item label="系统名称">
              <el-input v-model="settingsForm.systemName" placeholder="校园事务管理系统" />
            </el-form-item>
            <el-form-item label="系统描述">
              <el-input v-model="settingsForm.systemDesc" type="textarea" :rows="3" placeholder="请输入系统描述" />
            </el-form-item>
            <el-form-item label="默认角色">
              <el-select v-model="settingsForm.defaultRole" style="width: 100%">
                <el-option label="学生" value="student" />
                <el-option label="教师" value="teacher" />
              </el-select>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="saveBasicSettings" class="save-btn">
                <el-icon><Check /></el-icon>
                保存设置
              </el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </el-col>

      <!-- 通知设置 -->
      <el-col :xs="24" :lg="12">
        <el-card class="settings-card">
          <template #header>
            <div class="card-header">
              <el-icon><Bell /></el-icon>
              <span>通知设置</span>
            </div>
          </template>
          <el-form label-width="120px" class="settings-form">
            <el-form-item label="系统通知">
              <el-switch v-model="settingsForm.systemNotification" active-text="开启" inactive-text="关闭" />
            </el-form-item>
            <el-form-item label="邮件通知">
              <el-switch v-model="settingsForm.emailNotification" active-text="开启" inactive-text="关闭" />
            </el-form-item>
            <el-form-item label="请假审批通知">
              <el-switch v-model="settingsForm.leaveNotification" active-text="开启" inactive-text="关闭" />
            </el-form-item>
            <el-form-item label="报修处理通知">
              <el-switch v-model="settingsForm.repairNotification" active-text="开启" inactive-text="关闭" />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="saveNotificationSettings" class="save-btn">
                <el-icon><Check /></el-icon>
                保存设置
              </el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </el-col>

      <!-- 安全设置 -->
      <el-col :xs="24" :lg="12" style="margin-top: 24px">
        <el-card class="settings-card">
          <template #header>
            <div class="card-header">
              <el-icon><Lock /></el-icon>
              <span>安全设置</span>
            </div>
          </template>
          <el-form label-width="120px" class="settings-form">
            <el-form-item label="Token有效期">
              <el-select v-model="settingsForm.tokenExpiry" style="width: 100%">
                <el-option label="1小时" value="1h" />
                <el-option label="6小时" value="6h" />
                <el-option label="24小时（默认）" value="24h" />
                <el-option label="7天" value="7d" />
              </el-select>
            </el-form-item>
            <el-form-item label="允许同时登录">
              <el-switch v-model="settingsForm.allowMultiLogin" active-text="允许" inactive-text="禁止" />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="saveSecuritySettings" class="save-btn">
                <el-icon><Check /></el-icon>
                保存设置
              </el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </el-col>

      <!-- 系统信息 -->
      <el-col :xs="24" :lg="12" style="margin-top: 24px">
        <el-card class="settings-card">
          <template #header>
            <div class="card-header">
              <el-icon><Monitor /></el-icon>
              <span>系统信息</span>
            </div>
          </template>
          <el-descriptions :column="1" border class="system-info">
            <el-descriptions-item label="系统版本">1.0.0</el-descriptions-item>
            <el-descriptions-item label="前端框架">Vue 3.4 + Element Plus 2.5</el-descriptions-item>
            <el-descriptions-item label="后端框架">Spring Boot 3.2.0 + MyBatis-Plus 3.5.5</el-descriptions-item>
            <el-descriptions-item label="数据库">MySQL 8.0</el-descriptions-item>
            <el-descriptions-item label="认证方式">JWT (JSON Web Token)</el-descriptions-item>
            <el-descriptions-item label="部署方式">Docker + Docker Compose</el-descriptions-item>
          </el-descriptions>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { reactive } from 'vue'
import { ElMessage } from 'element-plus'

const settingsForm = reactive({
  systemName: '校园事务管理系统',
  systemDesc: '基于Spring Boot + Vue 3的校园事务管理系统',
  defaultRole: 'student',
  systemNotification: true,
  emailNotification: false,
  leaveNotification: true,
  repairNotification: true,
  tokenExpiry: '24h',
  allowMultiLogin: true
})

const saveBasicSettings = () => {
  ElMessage.success('基本设置已保存')
}

const saveNotificationSettings = () => {
  ElMessage.success('通知设置已保存')
}

const saveSecuritySettings = () => {
  ElMessage.success('安全设置已保存')
}
</script>

<style scoped>
.settings-container {
  padding: 0;
}

.page-header {
  margin-bottom: 24px;
  padding: 0 4px;
}

.page-title {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 24px;
  font-weight: 700;
  color: #2C3E50;
}

.page-title .el-icon {
  color: #2E7D32;
  font-size: 28px;
}

.settings-card {
  border-radius: 16px !important;
  border: none !important;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08) !important;
  margin-bottom: 24px;
}

.card-header {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 16px;
  font-weight: 600;
  color: #2C3E50;
}

.card-header .el-icon {
  color: #2E7D32;
}

.settings-form :deep(.el-form-item__label) {
  font-weight: 500;
  color: #2C3E50;
}

.save-btn {
  height: 40px;
  padding: 0 24px;
  font-weight: 600;
  border-radius: 8px;
  background: linear-gradient(135deg, #2E7D32 0%, #4CAF50 100%) !important;
  border: none !important;
}

.system-info :deep(.el-descriptions__label) {
  font-weight: 500;
  color: #606266;
  background: #f8f9fa;
  width: 140px;
}

.system-info :deep(.el-descriptions__content) {
  color: #2C3E50;
}
</style>
