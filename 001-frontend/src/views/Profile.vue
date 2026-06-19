<template>
  <div class="profile-container">
    <!-- 页面标题 -->
    <div class="page-header">
      <div class="page-title">
        <el-icon><User /></el-icon>
        <span>个人中心</span>
      </div>
    </div>

    <el-row :gutter="24">
      <!-- 个人信息卡片 -->
      <el-col :xs="24" :lg="8">
        <el-card class="profile-card">
          <div class="user-info">
            <div class="avatar-container" @click="triggerUpload">
              <el-avatar :size="100" class="avatar" :src="avatarUrl">
                <template v-if="!avatarUrl">{{ userInfo?.username?.charAt(0) }}</template>
              </el-avatar>
              <div class="avatar-badge">
                <el-icon><Camera /></el-icon>
              </div>
              <input
                ref="fileInput"
                type="file"
                accept=".jpg,.jpeg,.png"
                style="display: none"
                @change="handleFileChange"
              />
            </div>
            <h3 class="username">{{ userInfo?.username }}</h3>
            <el-tag :type="getRoleType(userInfo?.role)" size="large" class="role-tag">
              {{ getRoleName(userInfo?.role) }}
            </el-tag>
            <el-divider />
            <el-descriptions :column="1" class="info-descriptions">
              <el-descriptions-item label="真实姓名">
                <el-icon><User /></el-icon>
                {{ userInfo?.realName }}
              </el-descriptions-item>
              <el-descriptions-item label="手机号">
                <el-icon><Phone /></el-icon>
                {{ userInfo?.phone }}
              </el-descriptions-item>
              <el-descriptions-item label="邮箱">
                <el-icon><Message /></el-icon>
                {{ userInfo?.email }}
              </el-descriptions-item>
              <el-descriptions-item label="注册时间">
                <el-icon><Calendar /></el-icon>
                {{ userInfo?.createTime }}
              </el-descriptions-item>
            </el-descriptions>
          </div>
        </el-card>
      </el-col>

      <!-- 编辑信息 -->
      <el-col :xs="24" :lg="16">
        <el-card class="edit-card">
          <template #header>
            <div class="card-header">
              <el-tabs v-model="activeTab" class="custom-tabs">
                <el-tab-pane label="修改信息" name="info" />
                <el-tab-pane label="修改密码" name="password" />
              </el-tabs>
            </div>
          </template>

          <!-- 修改信息表单 -->
          <el-form
            v-if="activeTab === 'info'"
            ref="infoFormRef"
            :model="infoForm"
            :rules="infoRules"
            label-width="100px"
            class="profile-form"
          >
            <el-form-item label="真实姓名" prop="realName">
              <el-input v-model="infoForm.realName" placeholder="请输入真实姓名" class="custom-input" />
            </el-form-item>
            <el-form-item label="手机号" prop="phone">
              <el-input v-model="infoForm.phone" placeholder="请输入手机号" class="custom-input" />
            </el-form-item>
            <el-form-item label="邮箱" prop="email">
              <el-input v-model="infoForm.email" placeholder="请输入邮箱" class="custom-input" />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleUpdateInfo" :loading="submitting" class="save-btn">
                <el-icon><Check /></el-icon>
                保存修改
              </el-button>
            </el-form-item>
          </el-form>

          <!-- 修改密码表单 -->
          <el-form
            v-if="activeTab === 'password'"
            ref="passwordFormRef"
            :model="passwordForm"
            :rules="passwordRules"
            label-width="100px"
            class="profile-form"
          >
            <el-form-item label="原密码" prop="oldPassword">
              <el-input
                v-model="passwordForm.oldPassword"
                type="password"
                placeholder="请输入原密码"
                show-password
                class="custom-input"
              />
            </el-form-item>
            <el-form-item label="新密码" prop="newPassword">
              <el-input
                v-model="passwordForm.newPassword"
                type="password"
                placeholder="请输入新密码"
                show-password
                class="custom-input"
              />
            </el-form-item>
            <el-form-item label="确认密码" prop="confirmPassword">
              <el-input
                v-model="passwordForm.confirmPassword"
                type="password"
                placeholder="请再次输入新密码"
                show-password
                class="custom-input"
              />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleChangePassword" :loading="submitting" class="save-btn">
                <el-icon><Key /></el-icon>
                修改密码
              </el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </el-col>
    </el-row>

    <!-- 头像裁剪对话框 -->
    <el-dialog v-model="showCropDialog" title="裁剪头像" width="600px" @close="onCropDialogClose" :close-on-click-modal="false">
      <div class="crop-container">
        <div class="crop-canvas-wrapper" ref="cropWrapper">
          <canvas
            ref="cropCanvas"
            class="crop-canvas"
            @mousedown="onCropStart"
            @mousemove="onCropMove"
            @mouseup="onCropEnd"
            @mouseleave="onCropEnd"
            @wheel.prevent="onWheel"
          ></canvas>
          <div class="crop-hint">
            <el-text type="info" size="small">拖拽选择裁剪区域 · 滚轮缩放图片</el-text>
          </div>
        </div>
        <div class="crop-preview-section">
          <div class="crop-preview-label">预览效果</div>
          <div class="crop-preview-box">
            <canvas ref="previewCanvas" class="crop-preview-canvas" width="120" height="120"></canvas>
          </div>
        </div>
        <div class="crop-actions">
          <el-button @click="rotateImage" :icon="RefreshRight">旋转90°</el-button>
          <el-button @click="resetCrop" :icon="RefreshLeft">重置</el-button>
          <el-button @click="zoomIn" :icon="ZoomIn">放大</el-button>
          <el-button @click="zoomOut" :icon="ZoomOut">缩小</el-button>
        </div>
      </div>
      <template #footer>
        <el-button @click="showCropDialog = false">取消</el-button>
        <el-button type="primary" @click="handleCropConfirm" :loading="uploading">确认上传</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, nextTick } from 'vue'
import { useUserStore } from '@/stores/user'
import { updateUser } from '@/api/user'
import { changePassword } from '@/api/auth'
import { uploadAvatar } from '@/api/upload'
import { ElMessage } from 'element-plus'
import { RefreshRight, RefreshLeft, ZoomIn, ZoomOut } from '@element-plus/icons-vue'

const userStore = useUserStore()
const userInfo = computed(() => userStore.userInfo)

const activeTab = ref('info')
const submitting = ref(false)
const infoFormRef = ref(null)
const passwordFormRef = ref(null)
const fileInput = ref(null)

// 头像裁剪相关
const showCropDialog = ref(false)
const uploading = ref(false)
const previewUrl = ref('')
const cropCanvas = ref(null)
const previewCanvas = ref(null)
const cropWrapper = ref(null)
const originalFile = ref(null)
const originalImage = ref(null)

// 裁剪状态
const cropState = reactive({
  imgX: 0,      // 图片在canvas中的x偏移
  imgY: 0,      // 图片在canvas中的y偏移
  scale: 1,    // 缩放比例
  rotate: 0,    // 旋转角度
  cropX: 0,     // 裁剪框x
  cropY: 0,     // 裁剪框y
  cropW: 200,   // 裁剪框宽
  cropH: 200,   // 裁剪框高
  isDragging: false,
  dragStartX: 0,
  dragStartY: 0,
  imgNaturalW: 0,
  imgNaturalH: 0,
  canvasW: 500,
  canvasH: 400
})

const avatarUrl = computed(() => {
  const avatar = userInfo.value?.avatar
  if (!avatar) return ''
  return avatar
})

const infoForm = reactive({
  realName: '',
  phone: '',
  email: ''
})

const passwordForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const validateConfirmPassword = (rule, value, callback) => {
  if (value === '') {
    callback(new Error('请再次输入密码'))
  } else if (value !== passwordForm.newPassword) {
    callback(new Error('两次输入密码不一致'))
  } else {
    callback()
  }
}

const infoRules = {
  realName: [{ required: true, message: '请输入真实姓名', trigger: 'blur' }],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
  ]
}

const passwordRules = {
  oldPassword: [
    { required: true, message: '请输入原密码', trigger: 'blur' }
  ],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能小于6位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, validator: validateConfirmPassword, trigger: 'blur' }
  ]
}

// 触发文件上传
const triggerUpload = () => {
  fileInput.value?.click()
}

// 处理文件选择 - 先预览，再裁剪后上传
const handleFileChange = async (event) => {
  const file = event.target.files?.[0]
  if (!file) return

  // 检查文件类型
  const validTypes = ['image/jpeg', 'image/png', 'image/jpg']
  if (!validTypes.includes(file.type)) {
    ElMessage.error('仅支持JPG和PNG格式的图片')
    event.target.value = ''
    return
  }

  // 检查文件大小（5MB）
  if (file.size > 5 * 1024 * 1024) {
    ElMessage.error('图片大小不能超过5MB')
    event.target.value = ''
    return
  }

  // 保存原始文件，显示裁剪对话框
  originalFile.value = file
  previewUrl.value = URL.createObjectURL(file)
  showCropDialog.value = true

  // 清空input，允许重复选择同一文件
  event.target.value = ''

  // 等待对话框渲染后初始化canvas
  await nextTick()
  await initCropCanvas()
}

// 初始化裁剪canvas
const initCropCanvas = async () => {
  const img = new Image()
  img.src = previewUrl.value
  await new Promise((resolve) => { img.onload = resolve; img.onerror = resolve })
  originalImage.value = img

  const canvas = cropCanvas.value
  if (!canvas) return

  // 设置canvas尺寸
  const wrapper = cropWrapper.value
  const wrapperW = wrapper.clientWidth || 500
  cropState.canvasW = Math.min(wrapperW, 500)
  cropState.canvasH = 400
  canvas.width = cropState.canvasW
  canvas.height = cropState.canvasH

  // 计算图片初始缩放，使其适应canvas
  cropState.imgNaturalW = img.width
  cropState.imgNaturalH = img.height
  const fitScale = Math.min(
    cropState.canvasW / img.width,
    cropState.canvasH / img.height
  ) * 0.8
  cropState.scale = fitScale

  // 居中图片
  cropState.imgX = (cropState.canvasW - img.width * cropState.scale) / 2
  cropState.imgY = (cropState.canvasH - img.height * cropState.scale) / 2

  // 初始化裁剪框（居中正方形）
  cropState.cropW = 200
  cropState.cropH = 200
  cropState.cropX = (cropState.canvasW - cropState.cropW) / 2
  cropState.cropY = (cropState.canvasH - cropState.cropH) / 2

  cropState.rotate = 0

  drawCropCanvas()
}

// 绘制裁剪canvas
const drawCropCanvas = () => {
  const canvas = cropCanvas.value
  if (!canvas || !originalImage.value) return
  const ctx = canvas.getContext('2d')

  // 清空canvas
  ctx.fillStyle = '#1a1a1a'
  ctx.fillRect(0, 0, cropState.canvasW, cropState.canvasH)

  // 绘制图片（带旋转和缩放）
  ctx.save()
  const cx = cropState.imgX + (originalImage.value.width * cropState.scale) / 2
  const cy = cropState.imgY + (originalImage.value.height * cropState.scale) / 2
  ctx.translate(cx, cy)
  ctx.rotate((cropState.rotate * Math.PI) / 180)
  ctx.scale(cropState.scale, cropState.scale)
  ctx.drawImage(originalImage.value, -originalImage.value.width / 2, -originalImage.value.height / 2)
  ctx.restore()

  // 绘制半透明遮罩
  ctx.fillStyle = 'rgba(0, 0, 0, 0.5)'
  ctx.fillRect(0, 0, cropState.canvasW, cropState.canvasH)

  // 清除裁剪框区域（显示原图）
  ctx.save()
  ctx.beginPath()
  ctx.rect(cropState.cropX, cropState.cropY, cropState.cropW, cropState.cropH)
  ctx.clip()
  ctx.drawImage(canvas, 0, 0)
  ctx.restore()

  // 重新绘制裁剪框内的图片
  ctx.save()
  ctx.beginPath()
  ctx.rect(cropState.cropX, cropState.cropY, cropState.cropW, cropState.cropH)
  ctx.clip()
  ctx.fillStyle = '#1a1a1a'
  ctx.fillRect(cropState.cropX, cropState.cropY, cropState.cropW, cropState.cropH)
  ctx.translate(cx, cy)
  ctx.rotate((cropState.rotate * Math.PI) / 180)
  ctx.scale(cropState.scale, cropState.scale)
  ctx.drawImage(originalImage.value, -originalImage.value.width / 2, -originalImage.value.height / 2)
  ctx.restore()

  // 绘制裁剪框边框
  ctx.strokeStyle = '#409EFF'
  ctx.lineWidth = 2
  ctx.strokeRect(cropState.cropX, cropState.cropY, cropState.cropW, cropState.cropH)

  // 绘制网格线（九宫格辅助线）
  ctx.strokeStyle = 'rgba(255, 255, 255, 0.3)'
  ctx.lineWidth = 1
  for (let i = 1; i < 3; i++) {
    ctx.beginPath()
    ctx.moveTo(cropState.cropX + (cropState.cropW / 3) * i, cropState.cropY)
    ctx.lineTo(cropState.cropX + (cropState.cropW / 3) * i, cropState.cropY + cropState.cropH)
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo(cropState.cropX, cropState.cropY + (cropState.cropH / 3) * i)
    ctx.lineTo(cropState.cropX + cropState.cropW, cropState.cropY + (cropState.cropH / 3) * i)
    ctx.stroke()
  }

  // 绘制8个调整手柄
  ctx.fillStyle = '#409EFF'
  const handles = getCropHandles()
  handles.forEach(h => {
    ctx.fillRect(h.x - 4, h.y - 4, 8, 8)
  })

  // 更新预览
  updatePreview()
}

// 获取裁剪框8个手柄位置
const getCropHandles = () => {
  const { cropX, cropY, cropW, cropH } = cropState
  return [
    { x: cropX, y: cropY },
    { x: cropX + cropW / 2, y: cropY },
    { x: cropX + cropW, y: cropY },
    { x: cropX, y: cropY + cropH / 2 },
    { x: cropX + cropW, y: cropY + cropH / 2 },
    { x: cropX, y: cropY + cropH },
    { x: cropX + cropW / 2, y: cropY + cropH },
    { x: cropX + cropW, y: cropY + cropH }
  ]
}

// 判断点在裁剪框内
const isPointInCrop = (x, y) => {
  return x >= cropState.cropX && x <= cropState.cropX + cropState.cropW &&
         y >= cropState.cropY && y <= cropState.cropY + cropState.cropH
}

// 鼠标按下 - 开始拖拽
const onCropStart = (e) => {
  const rect = cropCanvas.value.getBoundingClientRect()
  const x = e.clientX - rect.left
  const y = e.clientY - rect.top

  if (isPointInCrop(x, y)) {
    cropState.isDragging = true
    cropState.dragStartX = x - cropState.cropX
    cropState.dragStartY = y - cropState.cropY
    cropCanvas.value.style.cursor = 'move'
  }
}

// 鼠标移动 - 拖拽中
const onCropMove = (e) => {
  if (!cropState.isDragging) return
  const rect = cropCanvas.value.getBoundingClientRect()
  const x = e.clientX - rect.left
  const y = e.clientY - rect.top

  // 移动裁剪框，限制在canvas范围内
  cropState.cropX = Math.max(0, Math.min(x - cropState.dragStartX, cropState.canvasW - cropState.cropW))
  cropState.cropY = Math.max(0, Math.min(y - cropState.dragStartY, cropState.canvasH - cropState.cropH))

  drawCropCanvas()
}

// 鼠标抬起 - 结束拖拽
const onCropEnd = () => {
  cropState.isDragging = false
  if (cropCanvas.value) {
    cropCanvas.value.style.cursor = 'crosshair'
  }
}

// 滚轮缩放
const onWheel = (e) => {
  const delta = e.deltaY > 0 ? 0.9 : 1.1
  const newScale = cropState.scale * delta
  // 限制缩放范围
  if (newScale > 0.1 && newScale < 10) {
    // 以canvas中心为缩放原点
    const centerX = cropState.canvasW / 2
    const centerY = cropState.canvasH / 2
    cropState.imgX = centerX - (centerX - cropState.imgX) * delta
    cropState.imgY = centerY - (centerY - cropState.imgY) * delta
    cropState.scale = newScale
    drawCropCanvas()
  }
}

// 放大
const zoomIn = () => {
  const newScale = cropState.scale * 1.2
  if (newScale < 10) {
    const centerX = cropState.canvasW / 2
    const centerY = cropState.canvasH / 2
    cropState.imgX = centerX - (centerX - cropState.imgX) * 1.2
    cropState.imgY = centerY - (centerY - cropState.imgY) * 1.2
    cropState.scale = newScale
    drawCropCanvas()
  }
}

// 缩小
const zoomOut = () => {
  const newScale = cropState.scale * 0.8
  if (newScale > 0.1) {
    const centerX = cropState.canvasW / 2
    const centerY = cropState.canvasH / 2
    cropState.imgX = centerX - (centerX - cropState.imgX) * 0.8
    cropState.imgY = centerY - (centerY - cropState.imgY) * 0.8
    cropState.scale = newScale
    drawCropCanvas()
  }
}

// 旋转图片
const rotateImage = () => {
  cropState.rotate = (cropState.rotate + 90) % 360
  drawCropCanvas()
}

// 重置裁剪
const resetCrop = () => {
  if (!originalImage.value) return
  const fitScale = Math.min(
    cropState.canvasW / originalImage.value.width,
    cropState.canvasH / originalImage.value.height
  ) * 0.8
  cropState.scale = fitScale
  cropState.imgX = (cropState.canvasW - originalImage.value.width * fitScale) / 2
  cropState.imgY = (cropState.canvasH - originalImage.value.height * fitScale) / 2
  cropState.rotate = 0
  cropState.cropW = 200
  cropState.cropH = 200
  cropState.cropX = (cropState.canvasW - cropState.cropW) / 2
  cropState.cropY = (cropState.canvasH - cropState.cropH) / 2
  drawCropCanvas()
}

// 更新预览
const updatePreview = () => {
  const pCanvas = previewCanvas.value
  if (!pCanvas) return
  const pCtx = pCanvas.getContext('2d')
  pCtx.clearRect(0, 0, 120, 120)

  // 计算裁剪框对应的原图区域
  const img = originalImage.value
  if (!img) return

  // 计算图片在canvas中的实际显示区域（考虑旋转）
  const cx = cropState.imgX + (img.width * cropState.scale) / 2
  const cy = cropState.imgY + (img.height * cropState.scale) / 2

  // 将裁剪框坐标转换回原图坐标
  // 需要逆向变换：先平移到图片中心，再逆向旋转，再逆向缩放
  const srcX = (cropState.cropX - cx) / cropState.scale + img.width / 2
  const srcY = (cropState.cropY - cy) / cropState.scale + img.height / 2
  const srcW = cropState.cropW / cropState.scale
  const srcH = cropState.cropH / cropState.scale

  try {
    pCtx.drawImage(img, srcX, srcY, srcW, srcH, 0, 0, 120, 120)
  } catch (e) {
    // 忽略绘制错误
  }
}

// 关闭裁剪对话框
const onCropDialogClose = () => {
  if (previewUrl.value) {
    URL.revokeObjectURL(previewUrl.value)
    previewUrl.value = ''
  }
  originalFile.value = null
  originalImage.value = null
}

// 确认裁剪并上传
const handleCropConfirm = async () => {
  if (!originalFile.value || !originalImage.value) return

  uploading.value = true
  try {
    const img = originalImage.value
    const targetSize = 300

    // 计算裁剪框对应的原图区域
    const cx = cropState.imgX + (img.width * cropState.scale) / 2
    const cy = cropState.imgY + (img.height * cropState.scale) / 2
    const srcX = (cropState.cropX - cx) / cropState.scale + img.width / 2
    const srcY = (cropState.cropY - cy) / cropState.scale + img.height / 2
    const srcW = cropState.cropW / cropState.scale
    const srcH = cropState.cropH / cropState.scale

    // 确保裁剪区域在图片范围内
    const sx = Math.max(0, srcX)
    const sy = Math.max(0, srcY)
    const sw = Math.min(srcW, img.width - sx)
    const sh = Math.min(srcH, img.height - sy)

    const canvas = document.createElement('canvas')
    canvas.width = targetSize
    canvas.height = targetSize
    const ctx = canvas.getContext('2d')

    // 处理旋转
    if (cropState.rotate > 0) {
      ctx.translate(targetSize / 2, targetSize / 2)
      ctx.rotate((cropState.rotate * Math.PI) / 180)
      ctx.translate(-targetSize / 2, -targetSize / 2)
    }

    // 绘制裁剪后的图片
    ctx.drawImage(img, sx, sy, sw, sh, 0, 0, targetSize, targetSize)

    // 转换为Blob
    const blob = await new Promise((resolve) => {
      canvas.toBlob(resolve, 'image/jpeg', 0.9)
    })

    if (!blob) {
      ElMessage.error('图片处理失败')
      return
    }

    // 创建裁剪后的文件
    const croppedFile = new File([blob], 'avatar.jpg', { type: 'image/jpeg' })
    const formData = new FormData()
    formData.append('file', croppedFile)

    const res = await uploadAvatar(formData)
    if (res.code === 200) {
      ElMessage.success('头像上传成功')
      showCropDialog.value = false
      await userStore.fetchUserInfo()
    } else {
      ElMessage.error(res.message || '上传失败')
    }
  } catch (e) {
    // 静默处理
    ElMessage.error('头像上传失败')
  } finally {
    uploading.value = false
  }
}

// 获取角色类型
const getRoleType = (role) => {
  if (role === 'admin') return 'danger'
  if (role === 'counselor') return 'success'
  return 'primary'
}

// 获取角色名称
const getRoleName = (role) => {
  if (role === 'admin') return '管理员'
  if (role === 'counselor') return '辅导员'
  return '学生'
}

// 更新个人信息
const handleUpdateInfo = async () => {
  if (!infoFormRef.value) return
  
  await infoFormRef.value.validate(async (valid) => {
    if (valid) {
      submitting.value = true
      try {
        const res = await updateUser({
          id: userInfo.value.id,
          ...infoForm
        })
        
        if (res.code === 200) {
          ElMessage.success('更新成功')
          await userStore.fetchUserInfo()
        }
      } catch (error) {
        // 静默处理
      } finally {
        submitting.value = false
      }
    }
  })
}

// 修改密码
const handleChangePassword = async () => {
  if (!passwordFormRef.value) return
  
  await passwordFormRef.value.validate(async (valid) => {
    if (valid) {
      submitting.value = true
      try {
        const res = await changePassword({
          oldPassword: passwordForm.oldPassword,
          newPassword: passwordForm.newPassword
        })
        
        if (res.code === 200) {
          ElMessage.success('密码修改成功，请重新登录')
          passwordFormRef.value.resetFields()
          setTimeout(() => {
            userStore.logout()
          }, 1500)
        }
      } catch (error) {
        // 静默处理
      } finally {
        submitting.value = false
      }
    }
  })
}

// 初始化表单数据
const initFormData = () => {
  if (userInfo.value) {
    infoForm.realName = userInfo.value.realName
    infoForm.phone = userInfo.value.phone
    infoForm.email = userInfo.value.email
  }
}

onMounted(() => {
  initFormData()
})
</script>

<style scoped>
.profile-container {
  padding: 0;
}

/* 页面标题 */
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
  font-family: var(--font-heading);
}

.page-title .el-icon {
  color: #2E7D32;
  font-size: 28px;
}

/* 个人信息卡片 */
.profile-card {
  border-radius: 16px !important;
  border: none !important;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08) !important;
  margin-bottom: 24px;
}

.user-info {
  text-align: center;
  padding: 20px 0;
}

.avatar-container {
  position: relative;
  display: inline-block;
  margin-bottom: 20px;
}

.avatar {
  background: linear-gradient(135deg, #2E7D32 0%, #1565C0 100%);
  color: white;
  font-size: 36px;
  font-weight: 700;
  box-shadow: 0 8px 24px rgba(46, 125, 50, 0.3);
}

.avatar-badge {
  position: absolute;
  bottom: 0;
  right: 0;
  width: 32px;
  height: 32px;
  background: linear-gradient(135deg, #FF6F00 0%, #FFA726 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(255, 111, 0, 0.3);
}

.avatar-badge:hover {
  transform: scale(1.1);
}

/* 头像裁剪对话框 */
.crop-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
}

.crop-canvas-wrapper {
  position: relative;
  width: 100%;
  max-width: 500px;
}

.crop-canvas {
  width: 100%;
  max-width: 500px;
  height: 400px;
  border: 2px solid #dcdfe6;
  border-radius: 8px;
  cursor: crosshair;
  display: block;
  background: #1a1a1a;
}

.crop-hint {
  position: absolute;
  bottom: 8px;
  left: 50%;
  transform: translateX(-50%);
  background: rgba(0, 0, 0, 0.6);
  padding: 4px 12px;
  border-radius: 4px;
  pointer-events: none;
}

.crop-hint :deep(.el-text) {
  color: #fff !important;
}

.crop-preview-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.crop-preview-label {
  font-size: 14px;
  color: #606266;
  font-weight: 500;
}

.crop-preview-box {
  width: 120px;
  height: 120px;
  border: 2px solid #409EFF;
  border-radius: 50%;
  overflow: hidden;
  background: #f5f7fa;
}

.crop-preview-canvas {
  width: 120px;
  height: 120px;
  display: block;
}

.crop-actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  justify-content: center;
}

.username {
  font-size: 24px;
  font-weight: 700;
  color: #2C3E50;
  margin-bottom: 12px;
  font-family: var(--font-heading);
}

.role-tag {
  border-radius: 20px !important;
  padding: 0 20px !important;
  font-weight: 600;
  font-size: 14px;
}

.info-descriptions {
  margin-top: 20px;
}

.info-descriptions :deep(.el-descriptions__label) {
  font-weight: 500;
  color: #606266;
}

.info-descriptions :deep(.el-descriptions__content) {
  color: #2C3E50;
}

.info-descriptions :deep(.el-descriptions-item) {
  padding: 12px 0;
}

.info-descriptions :deep(.el-descriptions-item .el-icon) {
  color: #2E7D32;
  margin-right: 8px;
}

/* 编辑信息卡片 */
.edit-card {
  border-radius: 16px !important;
  border: none !important;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08) !important;
}

.edit-card :deep(.el-card__header) {
  border-bottom: 1px solid #f0f0f0;
  padding: 16px 24px;
}

.card-header {
  display: flex;
  align-items: center;
}

/* 自定义标签页 */
.custom-tabs :deep(.el-tabs__header) {
  margin-bottom: 0;
}

.custom-tabs :deep(.el-tabs__nav-wrap::after) {
  height: 1px;
  background: #f0f0f0;
}

.custom-tabs :deep(.el-tabs__active-bar) {
  background: linear-gradient(90deg, #2E7D32, #1565C0);
  height: 3px;
  border-radius: 2px;
}

.custom-tabs :deep(.el-tabs__item) {
  font-weight: 500;
  color: #606266;
}

.custom-tabs :deep(.el-tabs__item.is-active) {
  color: #2E7D32;
  font-weight: 600;
}

/* 个人表单 */
.profile-form {
  max-width: 500px;
  margin: 0 auto;
  padding: 20px 0;
}

.profile-form :deep(.el-form-item__label) {
  font-weight: 500;
  color: #2C3E50;
}

.custom-input :deep(.el-input__wrapper) {
  border-radius: 8px;
  transition: all 0.3s ease;
}

.custom-input :deep(.el-input__wrapper:hover) {
  box-shadow: 0 0 0 1px #2E7D32 inset;
}

.custom-input :deep(.el-input__wrapper.is-focus) {
  box-shadow: 0 0 0 1px #2E7D32 inset;
}

/* 保存按钮 */
.save-btn {
  height: 44px;
  padding: 0 24px;
  font-size: 14px;
  font-weight: 600;
  border-radius: 10px;
  background: linear-gradient(135deg, #2E7D32 0%, #4CAF50 100%) !important;
  border: none !important;
  box-shadow: 0 4px 12px rgba(46, 125, 50, 0.3);
  transition: all 0.3s ease;
}

.save-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(46, 125, 50, 0.4);
}

.save-btn:active {
  transform: translateY(0);
}

/* 响应式 */
@media (max-width: 1200px) {
  .profile-card {
    margin-bottom: 24px;
  }
}

@media (max-width: 768px) {
  .page-header {
    margin-bottom: 16px;
  }
  
  .profile-form {
    padding: 10px 0;
  }
  
  .avatar {
    width: 80px !important;
    height: 80px !important;
    font-size: 28px;
  }
}
</style>

