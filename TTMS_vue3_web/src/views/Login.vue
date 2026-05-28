<template>
  <main class="relative min-h-screen overflow-hidden bg-gradient-to-br from-sky-50 via-white to-blue-50">
    <!-- 背景装饰光晕 -->
    <div class="pointer-events-none absolute inset-0">
      <div class="absolute -left-32 top-0 h-[600px] w-[600px] rounded-full bg-sky-200/30 blur-[120px]"></div>
      <div class="absolute -bottom-40 right-0 h-[500px] w-[500px] rounded-full bg-blue-200/25 blur-[100px]"></div>
      <div class="absolute left-1/3 top-1/2 h-[400px] w-[400px] rounded-full bg-indigo-100/20 blur-[80px]"></div>
    </div>

    <!-- 细微网格背景 -->
    <div class="pointer-events-none absolute inset-0 opacity-[0.03]" style="background-image: linear-gradient(rgba(56,189,248,0.5) 1px, transparent 1px), linear-gradient(90deg, rgba(56,189,248,0.5) 1px, transparent 1px); background-size: 40px 40px;"></div>

    <section class="relative mx-auto grid min-h-screen w-full max-w-7xl lg:grid-cols-[9fr_11fr] lg:items-center">
      <!-- ==================== 左侧：品牌介绍栏 ==================== -->
      <div class="flex flex-col justify-center px-6 py-10 sm:px-10 lg:min-h-[680px] lg:px-14">
        
        <!-- ① 左上角品牌区 -->
        <div class="flex items-center gap-3">
          <!-- 占位图标：电影票 -->
          <div class="flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl bg-gradient-to-br from-sky-400 to-blue-500 shadow-lg shadow-sky-200/50">
            <Icon icon="solar:ticket-bold-duotone" class="text-3xl text-white" />
          </div>
          <div>
            <h1 class="text-2xl font-black tracking-tight text-slate-800">TTMS</h1>

          </div>
        </div>



        <!-- ② 副标题标签 -->
        <div class="mt-4 inline-flex items-center gap-2 self-start rounded-full border border-sky-200 bg-sky-50 px-4 py-1.5">
          <span class="inline-block h-1.5 w-1.5 rounded-full bg-sky-400"></span>
          <span class="text-sm font-medium text-sky-600">410 · TTMS售票 · 影院级体验</span>
        </div>

        <!-- ④ 中间功能卡片区（带网格背景）—— 手机端隐藏以缩短页面 -->
        <div class="relative mt-6 lg:mt-10 overflow-hidden rounded-2xl border border-slate-200/80 bg-white p-4 sm:p-6 shadow-sm hidden sm:block">
          <!-- 网格背景 -->
          <div class="pointer-events-none absolute inset-0 opacity-[0.04]" style="background-image: linear-gradient(rgba(56,189,248,1) 1px, transparent 1px), linear-gradient(90deg, rgba(56,189,248,1) 1px, transparent 1px); background-size: 24px 24px;"></div>
          
          <p class="relative mb-4 text-sm font-semibold uppercase tracking-widest text-slate-400">核心功能模块</p>
          
          <!-- 3 张功能卡片（波浪自动浮动） -->
          <div class="relative grid gap-3 sm:grid-cols-3">
            <div class="wave-card wave-card-1 group cursor-pointer rounded-xl border border-slate-100 bg-sky-50/60 p-4 transition-all duration-300 hover:border-sky-200 hover:bg-sky-50 hover:shadow-lg hover:shadow-sky-100/60">
              <div class="mb-2 inline-flex h-9 w-9 items-center justify-center rounded-lg bg-sky-100 text-sky-500 transition-colors group-hover:bg-sky-200">
                <Icon icon="solar:ticket-sale-bold-duotone" class="text-xl" />
              </div>
              <h4 class="text-sm font-bold text-slate-700">售票管理</h4>
              <p class="mt-1 text-xs text-slate-400">在线选座 · 订单处理 · 一键出票</p>
            </div>
            <div class="wave-card wave-card-2 group cursor-pointer rounded-xl border border-slate-100 bg-blue-50/60 p-4 transition-all duration-300 hover:border-blue-200 hover:bg-blue-50 hover:shadow-lg hover:shadow-blue-100/60">
              <div class="mb-2 inline-flex h-9 w-9 items-center justify-center rounded-lg bg-blue-100 text-blue-500 transition-colors group-hover:bg-blue-200">
                <Icon icon="solar:calendar-mark-bold-duotone" class="text-xl" />
              </div>
              <h4 class="text-sm font-bold text-slate-700">场次排期</h4>
              <p class="mt-1 text-xs text-slate-400">影片管理 · 影厅编排 · 时间规划</p>
            </div>
            <div class="wave-card wave-card-3 group cursor-pointer rounded-xl border border-slate-100 bg-indigo-50/60 p-4 transition-all duration-300 hover:border-indigo-200 hover:bg-indigo-50 hover:shadow-lg hover:shadow-indigo-100/60">
              <div class="mb-2 inline-flex h-9 w-9 items-center justify-center rounded-lg bg-indigo-100 text-indigo-500 transition-colors group-hover:bg-indigo-200">
                <Icon icon="solar:user-heart-bold-duotone" class="text-xl" />
              </div>
              <h4 class="text-sm font-bold text-slate-700">用户中心</h4>
              <p class="mt-1 text-xs text-slate-400">权限管控 · 数据看板 · 个人设置</p>
            </div>
          </div>

          <!-- 动态柱状图占位（持续呼吸动画） -->
          <div class="relative mt-5 overflow-hidden rounded-xl border border-slate-100 bg-slate-50/80 p-4">
            <!-- 扫描线 -->
            <div class="pointer-events-none absolute inset-x-0 top-0 h-0.5 bg-gradient-to-r from-transparent via-sky-400/60 to-transparent animate-scan"></div>
            <p class="mb-3 text-xs font-semibold uppercase tracking-widest text-slate-400">售票数据趋势</p>
            <div class="flex items-end justify-around gap-2" style="height: 100px;">
              <div class="flex w-8 flex-col items-center gap-1">
                <div class="bar-live bar-live-1 w-full rounded-t-md bg-gradient-to-t from-sky-400 to-sky-300 shadow-sm shadow-sky-200/60" style="height:52px;"></div>
                <span class="text-[10px] text-slate-400">周一</span>
              </div>
              <div class="flex w-8 flex-col items-center gap-1">
                <div class="bar-live bar-live-2 w-full rounded-t-md bg-gradient-to-t from-sky-400 to-sky-300 shadow-sm shadow-sky-200/60" style="height:38px;"></div>
                <span class="text-[10px] text-slate-400">周二</span>
              </div>
              <div class="flex w-8 flex-col items-center gap-1">
                <div class="bar-live bar-live-3 w-full rounded-t-md bg-gradient-to-t from-blue-400 to-blue-300 shadow-sm shadow-blue-200/60" style="height:78px;"></div>
                <span class="text-[10px] text-slate-400">周三</span>
              </div>
              <div class="flex w-8 flex-col items-center gap-1">
                <div class="bar-live bar-live-4 w-full rounded-t-md bg-gradient-to-t from-sky-400 to-sky-300 shadow-sm shadow-sky-200/60" style="height:48px;"></div>
                <span class="text-[10px] text-slate-400">周四</span>
              </div>
              <div class="flex w-8 flex-col items-center gap-1">
                <div class="bar-live bar-live-5 w-full rounded-t-md bg-gradient-to-t from-blue-400 to-blue-300 shadow-sm shadow-blue-200/60" style="height:62px;"></div>
                <span class="text-[10px] text-slate-400">周五</span>
              </div>
              <div class="flex w-8 flex-col items-center gap-1">
                <div class="bar-live bar-live-6 w-full rounded-t-md bg-gradient-to-t from-sky-400 to-sky-300 shadow-sm shadow-sky-200/60" style="height:55px;"></div>
                <span class="text-[10px] text-slate-400">周六</span>
              </div>
              <div class="flex w-8 flex-col items-center gap-1">
                <div class="bar-live bar-live-7 w-full rounded-t-md bg-gradient-to-t from-indigo-400 to-indigo-300 shadow-sm shadow-indigo-200/60" style="height:88px;"></div>
                <span class="text-[10px] text-slate-400">周日</span>
              </div>
            </div>
            <div class="mt-2 flex items-center justify-between text-[10px] text-slate-400">
              <span>0</span>
              <span>50</span>
              <span>100</span>
              <span>150</span>
              <span>200</span>
            </div>
          </div>
        </div>

        <!-- ⑤ 底部三个静态功能卡片（无 hover 效果）—— 手机端隐藏 -->
        <div class="mt-6 grid gap-3 sm:grid-cols-3 hidden sm:grid">
          <div class="rounded-xl border border-slate-100 bg-white p-4 shadow-sm">
            <div class="mb-2 inline-flex h-9 w-9 items-center justify-center rounded-lg bg-sky-100 text-sky-500">
              <Icon icon="solar:shield-check-bold-duotone" class="text-xl" />
            </div>
            <h4 class="text-sm font-bold text-slate-700">权限管理</h4>
            <p class="mt-1 text-xs leading-relaxed text-slate-400">基于角色的访问控制，保障影院运营数据安全</p>
          </div>
          <div class="rounded-xl border border-slate-100 bg-white p-4 shadow-sm">
            <div class="mb-2 inline-flex h-9 w-9 items-center justify-center rounded-lg bg-blue-100 text-blue-500">
              <Icon icon="solar:bolt-bold-duotone" class="text-xl" />
            </div>
            <h4 class="text-sm font-bold text-slate-700">快速接入</h4>
            <p class="mt-1 text-xs leading-relaxed text-slate-400">前后端分离架构，适合课设答辩与功能演示</p>
          </div>
          <div class="rounded-xl border border-slate-100 bg-white p-4 shadow-sm">
            <div class="mb-2 inline-flex h-9 w-9 items-center justify-center rounded-lg bg-indigo-100 text-indigo-500">
              <Icon icon="solar:chart-2-bold-duotone" class="text-xl" />
            </div>
            <h4 class="text-sm font-bold text-slate-700">数据追踪</h4>
            <p class="mt-1 text-xs leading-relaxed text-slate-400">售票统计与销售分析，直观掌握经营动态</p>
          </div>
        </div>
      </div>

      <!-- ==================== 右侧：登录表单（完全不变） ==================== -->
      <div class="flex items-center justify-center px-4 py-8 sm:px-10 lg:min-h-[680px] lg:px-8 lg:py-10">
        <section class="relative w-full max-w-xl rounded-[36px] border border-white/15 bg-white/95 p-8 shadow-[0_30px_120px_rgba(8,15,30,.35)] backdrop-blur-xl sm:p-10">
          <div class="mb-8">
            <p class="text-sm font-black uppercase tracking-[0.2em] text-cyan-600">ACCOUNT ACCESS</p>
            <h3 class="mt-3 text-4xl font-black tracking-tight text-slate-900">欢迎回来</h3>
            <p class="mt-3 text-base text-slate-500">请登录您的账户以继续管理票务业务</p>
          </div>

          <form class="grid gap-4" @submit.prevent="submit">
            <label class="grid gap-1.5 text-sm font-semibold text-slate-600">用户名
              <div class="relative">
                <input v-model.trim="form.username" class="h-12 w-full rounded-xl border border-slate-200 bg-white pr-10 pl-4 text-sm text-slate-800 outline-none transition placeholder:text-slate-400 focus:border-sky-400 focus:ring-4 focus:ring-sky-400/10" autocomplete="off" placeholder="请输入或选择用户名" @focus="showUserDropdown = true" @blur="handleUserBlur" @input="showUserDropdown = false" />
                <button type="button" class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-sky-500 transition" @mousedown.prevent="showUserDropdown = !showUserDropdown" tabindex="-1">
                  <Icon icon="solar:alt-arrow-down-bold-duotone" class="text-base" :class="{ 'rotate-180 text-sky-500': showUserDropdown }" />
                </button>
                <!-- 用户下拉列表 -->
                <Transition name="dropdown">
                  <ul v-if="showUserDropdown" class="absolute left-0 right-0 top-full z-50 mt-1 overflow-hidden rounded-xl border border-slate-200 bg-white shadow-xl shadow-slate-200/50 py-1">
                    <li v-for="u in predefinedUsers" :key="u.username" class="flex items-center gap-3 px-4 py-2.5 cursor-pointer text-sm text-slate-700 hover:bg-sky-50 hover:text-sky-600 transition" @mousedown.prevent="selectUser(u)">
                      <span class="inline-flex h-7 w-7 items-center justify-center rounded-full text-[10px] font-bold text-white" :class="u.avatarClass">{{ u.initial }}</span>
                      <span class="font-semibold">{{ u.username }}</span>
                      <span class="ml-auto text-[11px] text-slate-400">{{ u.role }}</span>
                    </li>
                  </ul>
                </Transition>
              </div>
            </label>
            <label class="grid gap-1.5 text-sm font-semibold text-slate-600">密码
              <div class="relative">
                <input v-model="form.password" class="h-12 w-full rounded-xl border border-slate-200 bg-white pr-10 pl-4 text-sm text-slate-800 outline-none transition placeholder:text-slate-400 focus:border-sky-400 focus:ring-4 focus:ring-sky-400/10" :type="showPassword ? 'text' : 'password'" autocomplete="current-password" placeholder="请输入密码" />
                <button type="button" class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-sky-500 transition" @mousedown.prevent="showPassword = !showPassword" tabindex="-1">
                  <Icon :icon="showPassword ? 'solar:eye-closed-bold-duotone' : 'solar:eye-bold-duotone'" class="text-base" />
                </button>
              </div>
            </label>
            <button :class="ui.btn" class="mt-2 h-12 w-full rounded-2xl text-base shadow-[0_18px_40px_rgba(59,130,246,.22)]" :disabled="loading">
              <Icon :icon="loading ? 'svg-spinners:180-ring' : 'solar:login-3-bold-duotone'" class="text-lg" />
              {{ loading ? '正在登录...' : '登 录' }}
            </button>
            <p v-if="message" class="rounded-2xl bg-rose-50 px-4 py-3 text-sm text-rose-600">{{ message }}</p>
          </form>

          <!-- ⑥ 制作小组卡片 -->
          <div class="mt-7 border-t border-slate-200 pt-6">
            <p class="mb-3 text-xs font-semibold uppercase tracking-widest text-slate-400">制作小组</p>
            <div class="grid grid-cols-2 sm:grid-cols-3 gap-2.5">
              <!-- XYM · 组长（后端） -->
              <div class="group relative cursor-default rounded-xl border border-sky-200/70 bg-sky-50/80 p-3 text-center transition-all duration-300 hover:-translate-y-0.5 hover:border-sky-300 hover:bg-sky-50 hover:shadow-md hover:shadow-sky-100/60">
                <div class="mx-auto mb-1.5 flex h-8 w-8 items-center justify-center rounded-full bg-gradient-to-br from-sky-400 to-blue-500 text-[10px] font-bold text-white shadow-sm shadow-sky-200/50">组长</div>
                <p class="text-sm font-bold text-slate-700">XYM</p>

              </div>
              <!-- NZX · 数据库 -->
              <div class="group relative cursor-default rounded-xl border border-emerald-200/70 bg-emerald-50/80 p-3 text-center transition-all duration-300 hover:-translate-y-0.5 hover:border-emerald-300 hover:bg-emerald-50 hover:shadow-md hover:shadow-emerald-100/60">
                <div class="mx-auto mb-1.5 flex h-8 w-8 items-center justify-center rounded-full bg-gradient-to-br from-emerald-400 to-teal-500 text-[10px] font-bold text-white shadow-sm shadow-emerald-200/50">组员</div>
                <p class="text-sm font-bold text-slate-700">NZX</p>

              </div>
              <!-- LX · 前端核心 -->
              <div class="group relative cursor-default rounded-xl border border-violet-200/70 bg-violet-50/80 p-3 text-center transition-all duration-300 hover:-translate-y-0.5 hover:border-violet-300 hover:bg-violet-50 hover:shadow-md hover:shadow-violet-100/60">
                <div class="mx-auto mb-1.5 flex h-8 w-8 items-center justify-center rounded-full bg-gradient-to-br from-violet-400 to-purple-500 text-[10px] font-bold text-white shadow-sm shadow-violet-200/50">组员</div>
                <p class="text-sm font-bold text-slate-700">LX</p>

              </div>
              <!-- FW · 前端管理 -->
              <div class="group relative cursor-default rounded-xl border border-amber-200/70 bg-amber-50/80 p-3 text-center transition-all duration-300 hover:-translate-y-0.5 hover:border-amber-300 hover:bg-amber-50 hover:shadow-md hover:shadow-amber-100/60">
                <div class="mx-auto mb-1.5 flex h-8 w-8 items-center justify-center rounded-full bg-gradient-to-br from-amber-400 to-orange-500 text-[10px] font-bold text-white shadow-sm shadow-amber-200/50">组员</div>
                <p class="text-sm font-bold text-slate-700">FW</p>

              </div>
              <!-- WSY · 前端数据 -->
              <div class="group relative cursor-default rounded-xl border border-rose-200/70 bg-rose-50/80 p-3 text-center transition-all duration-300 hover:-translate-y-0.5 hover:border-rose-300 hover:bg-rose-50 hover:shadow-md hover:shadow-rose-100/60">
                <div class="mx-auto mb-1.5 flex h-8 w-8 items-center justify-center rounded-full bg-gradient-to-br from-rose-400 to-pink-500 text-[10px] font-bold text-white shadow-sm shadow-rose-200/50">组员</div>
                <p class="text-sm font-bold text-slate-700">WSY</p>

              </div>
              <!-- LK · 文档配置 -->
              <div class="group relative cursor-default rounded-xl border border-indigo-200/70 bg-indigo-50/80 p-3 text-center transition-all duration-300 hover:-translate-y-0.5 hover:border-indigo-300 hover:bg-indigo-50 hover:shadow-md hover:shadow-indigo-100/60">
                <div class="mx-auto mb-1.5 flex h-8 w-8 items-center justify-center rounded-full bg-gradient-to-br from-indigo-400 to-blue-500 text-[10px] font-bold text-white shadow-sm shadow-indigo-200/50">组员</div>
                <p class="text-sm font-bold text-slate-700">LK</p>

              </div>
            </div>
          </div>
        </section>
      </div>
    </section>
  </main>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { Icon } from '@iconify/vue'
import { authApi } from '../api/ttms'
import { useUserStore } from '../stores/user'
import { ui } from '../config/ui'

const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)
const message = ref('')
const showUserDropdown = ref(false)
const showPassword = ref(false)
const form = reactive({ username: '', password: '' })

const predefinedUsers = [
  { username: 'admin',   password: 'admin123', role: '管理员', initial: 'A', avatarClass: 'bg-gradient-to-br from-rose-400 to-pink-500' },
  { username: 'manager', password: '123456',   role: '经理',   initial: 'M', avatarClass: 'bg-gradient-to-br from-sky-400 to-blue-500' },
  { username: 'seller01',password: '123456',   role: '售票员', initial: 'S', avatarClass: 'bg-gradient-to-br from-emerald-400 to-teal-500' },
  { username: 'vip01',   password: '123456',   role: 'VIP会员',initial: 'V', avatarClass: 'bg-gradient-to-br from-amber-400 to-orange-500' },
  { username: 'user01',  password: '123456',   role: '普通用户',initial: 'U', avatarClass: 'bg-gradient-to-br from-violet-400 to-purple-500' },
]

function selectUser(u) {
  form.username = u.username
  form.password = u.password
  showUserDropdown.value = false
}

function handleUserBlur() {
  setTimeout(() => { showUserDropdown.value = false }, 150)
}

async function submit() {
  message.value = ''
  if (!form.username || !form.password) {
    message.value = '请输入用户名和密码'
    return
  }
  loading.value = true
  try {
    const res = await authApi.login(form.username, form.password)
    if (res.flag) {
      userStore.setUser(res.content)
      router.push('/')
    } else {
      message.value = res.content || '身份验证失败'
    }
  } catch (e) {
    message.value = '网络连接失败，请确认后端服务已启动'
  } finally {
    loading.value = false
  }
}
</script>
