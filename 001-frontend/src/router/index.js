import { createRouter, createWebHistory } from 'vue-router'

// 角色常量
export const ROLES = {
  ADMIN: 'admin',
  COUNSELOR: 'counselor',
  STUDENT: 'student'
}

// 角色中文名
export const ROLE_NAMES = {
  admin: '管理员',
  counselor: '辅导员',
  student: '学生'
}

// 角色对应的可访问路由
export const ROLE_ROUTES = {
  admin: ['dashboard', 'leave', 'repair', 'notice', 'activity', 'user', 'course-schedule', 'score', 'course-selection', 'dormitory', 'counselor', 'profile', 'settings'],
  counselor: ['dashboard', 'leave', 'repair', 'notice', 'activity', 'course-schedule', 'score', 'course-selection', 'counselor-panel', 'profile'],
  student: ['dashboard', 'leave', 'repair', 'notice', 'activity', 'course-schedule', 'score', 'course-selection', 'dormitory', 'profile']
}

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/login',
      name: 'Login',
      component: () => import('@/views/Login.vue')
    },
    {
      path: '/register',
      name: 'Register',
      component: () => import('@/views/Register.vue')
    },
    {
      path: '/',
      component: () => import('@/layout/MainLayout.vue'),
      redirect: '/dashboard',
      children: [
        {
          path: 'dashboard',
          name: 'Dashboard',
          component: () => import('@/views/Dashboard.vue'),
          meta: { title: '首页', icon: 'House', roles: ['admin', 'counselor', 'student'] }
        },
        {
          path: 'leave',
          name: 'Leave',
          component: () => import('@/views/Leave/Index.vue'),
          meta: { title: '请假管理', icon: 'Calendar', roles: ['admin', 'counselor', 'student'] }
        },
        {
          path: 'repair',
          name: 'Repair',
          component: () => import('@/views/Repair/Index.vue'),
          meta: { title: '报修管理', icon: 'Tools', roles: ['admin', 'counselor', 'student'] }
        },
        {
          path: 'notice',
          name: 'Notice',
          component: () => import('@/views/Notice/Index.vue'),
          meta: { title: '公告中心', icon: 'Bell', roles: ['admin', 'counselor', 'student'] }
        },
        {
          path: 'notice/:id',
          name: 'NoticeDetail',
          component: () => import('@/views/Notice/Detail.vue'),
          meta: { title: '公告详情', hidden: true, roles: ['admin', 'counselor', 'student'] }
        },
        {
          path: 'activity',
          name: 'Activity',
          component: () => import('@/views/Activity/Index.vue'),
          meta: { title: '活动中心', icon: 'Basketball', roles: ['admin', 'counselor', 'student'] }
        },
        {
          path: 'activity/:id',
          name: 'ActivityDetail',
          component: () => import('@/views/Activity/Detail.vue'),
          meta: { title: '活动详情', hidden: true, roles: ['admin', 'counselor', 'student'] }
        },
        {
          path: 'user',
          name: 'User',
          component: () => import('@/views/User/Index.vue'),
          meta: { title: '用户管理', icon: 'User', roles: ['admin'] }
        },
        {
          path: 'course-schedule',
          name: 'CourseSchedule',
          component: () => import('@/views/CourseSchedule/Index.vue'),
          meta: { title: '课程表', icon: 'Notebook', roles: ['admin', 'counselor', 'student'] }
        },
        {
          path: 'score',
          name: 'Score',
          component: () => import('@/views/Score/Index.vue'),
          meta: { title: '成绩查询', icon: 'Trophy', roles: ['admin', 'counselor', 'student'] }
        },
        {
          path: 'course-selection',
          name: 'CourseSelection',
          component: () => import('@/views/CourseSelection/Index.vue'),
          meta: { title: '选课中心', icon: 'ShoppingCart', roles: ['student', 'admin', 'counselor'] }
        },
        {
          path: 'dormitory',
          name: 'Dormitory',
          component: () => import('@/views/Dormitory/Index.vue'),
          meta: { title: '宿舍选择', icon: 'HomeFilled', roles: ['student', 'admin'] }
        },
        {
          path: 'counselor',
          name: 'Counselor',
          component: () => import('@/views/Counselor/Index.vue'),
          meta: { title: '辅导员管理', icon: 'Avatar', roles: ['admin'] }
        },
        {
          path: 'counselor-panel',
          name: 'CounselorPanel',
          component: () => import('@/views/Counselor/Panel.vue'),
          meta: { title: '辅导员工作台', icon: 'Avatar', roles: ['counselor'] }
        },
        {
          path: 'profile',
          name: 'Profile',
          component: () => import('@/views/Profile.vue'),
          meta: { title: '个人中心', icon: 'UserFilled', hidden: true, roles: ['admin', 'counselor', 'student'] }
        },
        {
          path: 'settings',
          name: 'Settings',
          component: () => import('@/views/Settings.vue'),
          meta: { title: '系统设置', icon: 'Setting', hidden: true, roles: ['admin'] }
        }
      ]
    }
  ]
})

// 操作审计日志
const auditLog = (action, details = {}) => {
  const userInfo = JSON.parse(localStorage.getItem('userInfo') || '{}')
  const logEntry = {
    timestamp: new Date().toISOString(),
    userId: userInfo.id,
    username: userInfo.username,
    role: userInfo.role,
    action,
    details,
    url: window.location.href
  }
  // 存储到localStorage（保留最近50条）
  const logs = JSON.parse(localStorage.getItem('auditLogs') || '[]')
  logs.unshift(logEntry)
  if (logs.length > 50) logs.pop()
  localStorage.setItem('auditLogs', JSON.stringify(logs))
}

// 路由守卫
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  
  if (to.path === '/login' || to.path === '/register') {
    next()
    return
  }
  
  if (!token) {
    next('/login')
    return
  }
  
  if (to.meta.roles) {
    const userInfo = JSON.parse(localStorage.getItem('userInfo') || '{}')
    if (!to.meta.roles.includes(userInfo.role)) {
      // 记录越权访问尝试
      auditLog('ACCESS_DENIED', { route: to.path, requiredRoles: to.meta.roles })
      next('/dashboard')
      return
    }
    // 记录页面访问
    auditLog('PAGE_ACCESS', { route: to.path })
  }
  
  next()
})

export { auditLog }
export default router
