<template>
  <div class="cinema-shell cinema-grid min-h-dvh text-slate-100">

    <!-- ==================== PC 侧边栏：fixed 固定定位（lg+ 可见） ==================== -->
    <aside class="fixed left-0 top-0 z-40 hidden h-screen w-64 flex-col border-r border-cyan-400/10 bg-slate-950/75 backdrop-blur-xl lg:flex">
      <!-- 顶部 Logo 区：固定高度 h-16 -->
      <div class="flex h-16 shrink-0 items-center gap-3 border-b border-cyan-400/10 px-4">
        <div class="grid h-9 w-9 shrink-0 place-items-center rounded-xl bg-[linear-gradient(135deg,#7c3aed,#06b6d4)] text-white shadow-[0_8px_20px_rgba(34,211,238,.15)]">
          <Icon icon="solar:clapperboard-play-bold-duotone" class="text-lg" />
        </div>
        <div class="min-w-0">
          <h2 class="truncate text-sm font-black leading-tight text-white">{{ APP_NAME }}</h2>
          <p class="mt-0.5 text-[11px] text-slate-400">影院业务中枢</p>
        </div>
      </div>

      <!-- 中间导航菜单：flex-1 占满剩余空间，内容溢出可滚动 -->
      <nav class="flex-1 overflow-y-auto px-3 py-3">
        <div class="mb-2 inline-flex items-center gap-1.5 rounded-full border border-cyan-400/15 bg-white/5 px-3 py-1 text-[11px] text-cyan-200/80">
          <span class="h-1.5 w-1.5 rounded-full bg-emerald-400 shadow-[0_0_6px_#4ade80]" />
          {{ userStore.roleName }}
        </div>

        <div class="mt-2 flex flex-col gap-1">
          <router-link
            v-for="item in navItems"
            :key="item.to"
            :to="item.to"
            :class="[
              'flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-semibold transition-all duration-200',
              isActive(item.to)
                ? 'bg-[linear-gradient(135deg,rgba(124,58,237,.85),rgba(6,182,212,.8))] text-white shadow-[0_10px_28px_rgba(34,211,238,.16)]'
                : 'text-slate-300 hover:bg-white/5 hover:text-white'
            ]"
          >
            <Icon :icon="item.icon" class="text-lg shrink-0" />
            <span class="truncate">{{ item.label }}</span>
          </router-link>
        </div>
      </nav>

      <!-- 底部用户操作区：固定在侧边栏底部 -->
      <div class="shrink-0 border-t border-cyan-400/10 px-3 py-3 space-y-1.5">
        <router-link
          to="/profile"
          class="flex items-center gap-2.5 rounded-xl px-3 py-2 text-sm font-semibold text-slate-300 transition hover:bg-white/5 hover:text-white"
        >
          <Icon icon="solar:user-rounded-bold-duotone" class="text-lg shrink-0" />
          个人中心
        </router-link>
        <button
          class="flex w-full items-center gap-2.5 rounded-xl px-3 py-2 text-sm font-semibold text-rose-300/80 transition hover:bg-rose-500/10 hover:text-rose-200"
          @click="logout"
        >
          <Icon icon="solar:logout-3-bold-duotone" class="text-lg shrink-0" />
          注销
        </button>
      </div>
    </aside>

    <!-- ==================== 主内容区：lg:ml-64 留出侧边栏宽度 ==================== -->
    <div class="flex min-w-0 flex-1 flex-col lg:ml-64">
      <!-- 顶部导航条（lg 以下显示品牌和操作，lg+ 仅显示欢迎信息） -->
      <header class="sticky top-0 z-30 border-b border-cyan-400/10 bg-slate-950/75 backdrop-blur-xl">
        <div class="flex min-h-[56px] items-center justify-between gap-3 px-4 lg:min-h-[64px] lg:px-6">
          <!-- 移动端/平板品牌标识（lg 以下可见，侧边栏已隐藏） -->
          <div class="flex items-center gap-2 lg:hidden">
            <div class="grid h-8 w-8 place-items-center rounded-xl bg-[linear-gradient(135deg,#7c3aed,#06b6d4)] text-white shadow-[0_8px_20px_rgba(34,211,238,.15)]">
              <Icon icon="solar:clapperboard-play-bold-duotone" class="text-base" />
            </div>
            <span class="text-sm font-black text-white">{{ APP_NAME }}</span>
          </div>

          <!-- PC 端（lg+）：欢迎信息 + 面包屑 -->
          <div class="hidden lg:flex lg:items-center lg:gap-3">
            <Icon icon="solar:stars-bold-duotone" class="text-xl text-cyan-300" />
            <span class="font-semibold text-slate-200">欢迎，{{ userStore.user?.emp_name || '用户' }}</span>
            <span class="text-slate-600">·</span>
            <span class="text-sm text-slate-400">{{ currentNavLabel }}</span>
          </div>

          <!-- 移动端操作按钮组（lg 以下可见，侧边栏已隐藏因此需要顶部入口） -->
          <div class="flex items-center gap-1.5 lg:hidden">
            <router-link
              to="/profile"
              class="inline-flex h-9 items-center gap-1.5 rounded-xl border border-cyan-400/10 bg-white/5 px-2.5 text-xs font-semibold text-slate-200 transition hover:bg-white/10"
            >
              <Icon icon="solar:user-rounded-bold-duotone" class="text-base" />
            </router-link>
            <button
              class="inline-flex h-9 items-center gap-1.5 rounded-xl border border-rose-400/15 bg-rose-500/10 px-2.5 text-xs font-semibold text-rose-200 transition hover:bg-rose-500/20"
              @click="logout"
            >
              <Icon icon="solar:logout-3-bold-duotone" class="text-base" />
            </button>
          </div>
        </div>
      </header>

      <!-- 内容滚动区 -->
      <main class="flex-1 p-3 pb-24 sm:p-4 lg:p-6 lg:pb-6">
        <router-view />
      </main>
    </div>

    <!-- ==================== 移动端/平板底部导航栏（lg 以下可见） ==================== -->
    <nav
      class="fixed bottom-0 left-0 right-0 z-40 border-t border-cyan-400/10 bg-slate-950/92 backdrop-blur-xl lg:hidden"
      style="padding-bottom: env(safe-area-inset-bottom, 0px)"
    >
      <div class="flex items-stretch justify-around">
        <router-link
          v-for="item in mobileNavItems"
          :key="item.to"
          :to="item.to"
          class="flex flex-col items-center justify-center gap-0.5 py-2 text-[11px] font-semibold transition flex-1 min-w-0"
          :class="isActive(item.to) ? 'text-cyan-300' : 'text-slate-400 active:text-cyan-200'"
        >
          <Icon :icon="item.icon" class="text-[22px]" />
          <span class="truncate max-w-full">{{ item.shortLabel || item.label }}</span>
        </router-link>

        <!-- 更多按钮（溢出菜单项） -->
        <button
          v-if="overflowItems.length"
          class="flex flex-col items-center justify-center gap-0.5 py-2 text-[11px] font-semibold transition flex-1 min-w-0"
          :class="showMobileMore ? 'text-cyan-300' : 'text-slate-400'"
          @click="showMobileMore = !showMobileMore"
        >
          <Icon icon="solar:menu-dots-bold" class="text-[22px]" />
          <span>更多</span>
        </button>
      </div>

      <!-- 溢出菜单弹出层 -->
      <Transition name="mobile-menu">
        <div
          v-if="showMobileMore && overflowItems.length"
          class="absolute bottom-full left-0 right-0 border-t border-cyan-400/10 bg-slate-950/95 pb-2 pt-1 backdrop-blur-xl"
        >
          <router-link
            v-for="item in overflowItems"
            :key="item.to"
            :to="item.to"
            class="mx-2 flex items-center gap-3 rounded-xl px-4 py-2.5 text-sm font-semibold transition"
            :class="isActive(item.to) ? 'bg-cyan-400/10 text-cyan-300' : 'text-slate-300 active:bg-white/5'"
            @click="showMobileMore = false"
          >
            <Icon :icon="item.icon" class="text-xl" />
            {{ item.label }}
          </router-link>
        </div>
      </Transition>
    </nav>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Icon } from '@iconify/vue'
import { authApi } from '../api/ttms'
import { useUserStore } from '../stores/user'
import { APP_NAME } from '../config/constants'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

// 导航项短标签映射（移动端底部栏）
const shortLabelMap = {
  '首页': '首页',
  '售票': '售票',
  '退票': '退票',
  '剧目管理': '剧目',
  '排片管理': '排片',
  '座位管理': '座位',
  '字典管理': '字典',
  '销售分析': '分析',
  '未处理订单': '待处理',
  '用户管理': '用户',
  '演出厅管理': '影厅'
}

const navItems = computed(() => {
  const type = userStore.user?.emp_type
  const items = [{ to: '/', label: '首页', icon: 'solar:home-2-bold-duotone' }]
  if ([2, 4, 5].includes(type)) items.push({ to: '/sell', label: '售票', icon: 'solar:ticket-sale-bold-duotone' })
  if (type === 1) items.push(
    { to: '/plays', label: '剧目管理', icon: 'solar:clapperboard-text-bold-duotone' },
    { to: '/schedules', label: '排片管理', icon: 'solar:calendar-bold-duotone' },
    { to: '/seats', label: '座位管理', icon: 'solar:armchair-2-bold-duotone' },
    { to: '/dictionary', label: '字典管理', icon: 'solar:book-bookmark-bold-duotone' },
    { to: '/analysis', label: '销售分析', icon: 'solar:chart-2-bold-duotone' }
  )
  if ([2, 4, 5].includes(type)) items.push({ to: '/return-ticket', label: '退票', icon: 'solar:refresh-circle-bold-duotone' })
  if (type === 2) items.push({ to: '/unhandled', label: '未处理订单', icon: 'solar:clipboard-list-bold-duotone' })
  if (type === 3) items.push(
    { to: '/employees', label: '用户管理', icon: 'solar:users-group-rounded-bold-duotone' },
    { to: '/studios', label: '演出厅管理', icon: 'solar:buildings-3-bold-duotone' }
  )
  return items.map(item => ({
    ...item,
    shortLabel: shortLabelMap[item.label] || item.label
  }))
})

const currentNavLabel = computed(() => {
  const found = navItems.value.find(item => isActive(item.to))
  return found?.label || '影院控制台'
})

// ==================== 移动端底部导航 ====================
const showMobileMore = ref(false)
const MAX_MOBILE_TABS = 4

const mobileNavItems = computed(() => navItems.value.slice(0, MAX_MOBILE_TABS))

const overflowItems = computed(() =>
  navItems.value.length > MAX_MOBILE_TABS ? navItems.value.slice(MAX_MOBILE_TABS) : []
)

// 路由变化时关闭溢出菜单
watch(() => route.path, () => { showMobileMore.value = false })

function isActive(to) {
  if (to === '/') return route.path === '/'
  return route.path === to || route.path.startsWith(to + '/')
}

async function logout() {
  try { await authApi.logout() } finally {
    userStore.clear()
    router.push('/login')
  }
}
</script>

<style scoped>
/* 移动端溢出菜单过渡动画 */
.mobile-menu-enter-active,
.mobile-menu-leave-active {
  transition: all 0.25s ease;
}
.mobile-menu-enter-from,
.mobile-menu-leave-to {
  opacity: 0;
  transform: translateY(8px);
}
</style>
