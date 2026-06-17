import { createRouter, createWebHistory } from 'vue-router'

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
          meta: { title: '首页', icon: 'House' }
        },
        {
          path: 'leave',
          name: 'Leave',
          component: () => import('@/views/Leave/Index.vue'),
          meta: { title: '请假管理', icon: 'Calendar' }
        },
        {
          path: 'repair',
          name: 'Repair',
          component: () => import('@/views/Repair/Index.vue'),
          meta: { title: '报修管理', icon: 'Tools' }
        },
        {
          path: 'notice',
          name: 'Notice',
          component: () => import('@/views/Notice/Index.vue'),
          meta: { title: '公告中心', icon: 'Bell' }
        },
        {
          path: 'notice/:id',
          name: 'NoticeDetail',
          component: () => import('@/views/Notice/Detail.vue'),
          meta: { title: '公告详情', hidden: true }
        },
        {
          path: 'activity',
          name: 'Activity',
          component: () => import('@/views/Activity/Index.vue'),
          meta: { title: '活动中心', icon: 'Basketball' }
        },
        {
          path: 'activity/:id',
          name: 'ActivityDetail',
          component: () => import('@/views/Activity/Detail.vue'),
          meta: { title: '活动详情', hidden: true }
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
          meta: { title: '课程表', icon: 'Notebook' }
        },
        {
          path: 'score',
          name: 'Score',
          component: () => import('@/views/Score/Index.vue'),
          meta: { title: '成绩查询', icon: 'Trophy', roles: ['admin', 'teacher', 'student'] }
        },
        {
          path: 'course-selection',
          name: 'CourseSelection',
          component: () => import('@/views/CourseSelection/Index.vue'),
          meta: { title: '选课中心', icon: 'ShoppingCart', roles: ['student', 'admin'] }
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
          path: 'profile',
          name: 'Profile',
          component: () => import('@/views/Profile.vue'),
          meta: { title: '个人中心', icon: 'UserFilled', hidden: true }
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
      next('/dashboard')
      return
    }
  }
  
  next()
})

export default router
