<template>
  <section :class="ui.page" class="cinema-grid">
    <div class="grid gap-4 xl:grid-cols-[minmax(0,1.6fr)_360px]">
      <div class="relative overflow-hidden rounded-[30px] border border-cyan-400/15 bg-[linear-gradient(135deg,rgba(15,23,42,.92),rgba(30,41,59,.78))] shadow-[0_20px_80px_rgba(2,6,23,.45)]">
        <div class="absolute inset-0 bg-[radial-gradient(circle_at_20%_20%,rgba(34,211,238,.18),transparent_25%),radial-gradient(circle_at_80%_0%,rgba(168,85,247,.18),transparent_30%),linear-gradient(180deg,rgba(2,6,23,.05),rgba(2,6,23,.75))] pointer-events-none z-20"></div>
        <div v-if="slides.length" class="relative h-[400px] overflow-hidden">
          <swiper
            :modules="modules"
            :slides-per-view="1"
            :loop="slides.length > 1"
            :autoplay="{ delay: 4500, disableOnInteraction: false }"
            :speed="700"
            class="h-full w-full"
            @swiper="onSwiper"
            @slide-change="onSlideChange"
          >
            <swiper-slide v-for="slide in slides" :key="slide.id" class="h-full">
              <div class="h-full w-full relative">
                <img
                  class="h-full w-full object-cover poster-pulse"
                  :src="slide.image"
                  :alt="slide.title"
                  @error="onSlideImageError(slide, $event)"
                />
                <div class="absolute inset-0 bg-[linear-gradient(90deg,rgba(2,6,23,.88),rgba(2,6,23,.35),rgba(2,6,23,.82))]"></div>
                <div class="absolute inset-x-0 bottom-0 p-4 sm:p-6">
                  <div class="max-w-2xl">
                    <div class="mb-2 inline-flex items-center gap-2 rounded-full border border-cyan-400/20 bg-slate-950/50 px-4 py-2 text-sm font-semibold text-cyan-100 backdrop-blur">
                      <Icon icon="solar:clapperboard-open-play-bold-duotone" class="text-lg" />
                      正在热映 · 智能影院推荐
                    </div>
                    <h1 class="glow-title text-3xl font-black tracking-tight text-white sm:text-5xl">{{ slide.title }}</h1>
                    <p class="mt-2 max-w-xl text-sm leading-6 text-slate-200 sm:text-base">{{ slide.description }}</p>
                  </div>
                </div>
              </div>
            </swiper-slide>
          </swiper>
        </div>

        <!-- 空状态占位 -->
        <div v-else class="relative flex h-[400px] items-center justify-center">
          <div class="text-center">
            <Icon icon="solar:clapperboard-play-bold-duotone" class="mx-auto text-5xl text-slate-500" />
            <p class="mt-3 text-slate-400">暂无轮播影片，请先在剧目管理中创建影片。</p>
          </div>
        </div>

        <div
          v-if="slides.length"
          class="pointer-events-none absolute inset-y-0 left-0 right-0 z-30 flex items-center justify-between px-4 sm:px-6"
        >
          <button
            class="pointer-events-auto grid h-11 w-11 place-items-center rounded-full border border-white/15 bg-slate-950/45 text-white backdrop-blur transition hover:scale-105 hover:border-cyan-300/40 hover:bg-slate-900/70"
            @click="prevSlide"
            aria-label="上一张"
          >
            <Icon icon="solar:alt-arrow-left-linear" class="text-xl" />
          </button>
          <button
            class="pointer-events-auto grid h-11 w-11 place-items-center rounded-full border border-white/15 bg-slate-950/45 text-white backdrop-blur transition hover:scale-105 hover:border-cyan-300/40 hover:bg-slate-900/70"
            @click="nextSlide"
            aria-label="下一张"
          >
            <Icon icon="solar:alt-arrow-right-linear" class="text-xl" />
          </button>
        </div>

        <div class="absolute bottom-5 right-5 z-30 flex items-center gap-2">
          <button
            v-for="(slide, index) in slides"
            :key="`${slide.id}-dot`"
            class="h-2.5 rounded-full transition-all"
            :class="index === currentSlide ? 'w-8 bg-cyan-300' : 'w-2.5 bg-white/35 hover:bg-white/55'"
            @click="goTo(index)"
          ></button>
        </div>
      </div>

      <aside class="ticket-cut max-w-full rounded-[30px] border border-cyan-400/15 bg-[linear-gradient(180deg,rgba(8,15,32,.98),rgba(15,23,42,.86))] p-5 shadow-[0_20px_80px_rgba(2,6,23,.45)]">
        <div class="flex items-center gap-3">
          <div class="grid h-12 w-12 place-items-center rounded-2xl bg-[linear-gradient(135deg,#f59e0b,#ef4444)] text-white shadow-lg shadow-amber-500/20">
            <Icon icon="solar:ticket-bold-duotone" class="text-2xl" />
          </div>
          <div>
            <p class="text-xs uppercase tracking-[0.25em] text-cyan-200/70">Cinema Spotlight</p>
            <h2 class="mt-1 text-xl font-black text-white">首页推荐</h2>
          </div>
        </div>

        <div class="mt-4 grid gap-3">
          <!-- 正在热映 – 当前轮播影片简介（取自数据库真实数据） -->
          <div class="rounded-2xl border border-cyan-400/10 bg-white/5 p-3">
            <p class="text-xs uppercase tracking-[0.2em] text-cyan-200/70">🎬 正在热映</p>
            <strong class="mt-2 block text-lg text-white">{{ activeSlide?.title || '暂无影片' }}</strong>
            <p class="mt-1 text-sm leading-6 text-slate-300">{{ activeSlide?.description || '暂无简介，请在剧目管理中为影片填写简介。' }}</p>
          </div>

          <!-- 上映数量 + 推荐模式 -->
          <div class="grid grid-cols-2 gap-3">
            <div class="rounded-2xl border border-cyan-400/10 bg-white/5 p-3">
              <p class="text-xs uppercase tracking-[0.2em] text-slate-400">上映数量</p>
              <strong class="mt-2 block text-3xl font-black text-cyan-300">{{ slides.length }}</strong>
            </div>
            <div class="rounded-2xl border border-cyan-400/10 bg-white/5 p-3">
              <p class="text-xs uppercase tracking-[0.2em] text-slate-400">推荐模式</p>
              <strong class="mt-2 block text-3xl font-black text-fuchsia-300">AUTO</strong>
            </div>
          </div>

          <!-- 热映影片列表 – 替代原来的海报命名规范 -->
          <div class="rounded-2xl border border-cyan-400/10 bg-white/5 p-3">
            <div class="mb-2 flex items-center justify-between">
              <h3 class="font-bold text-white">热映影片</h3>
              <Icon icon="solar:clapperboard-play-bold-duotone" class="text-xl text-cyan-300" />
            </div>
            <ul class="space-y-2.5">
              <li v-for="movie in featuredMovies" :key="movie.title" class="rounded-xl border border-cyan-400/8 bg-white/[0.03] p-3 transition hover:border-cyan-400/20 hover:bg-white/[0.06]">
                <div class="mb-1 flex items-center gap-2">
                  <span class="inline-block h-1.5 w-1.5 shrink-0 rounded-full bg-cyan-400"></span>
                  <strong class="text-sm text-white">{{ movie.title }}</strong>
                </div>
                <p class="text-xs leading-5 text-slate-400">{{ movie.desc }}</p>
              </li>
            </ul>
          </div>
        </div>
      </aside>
    </div>

    <div class="mt-4">
      <div class="mb-3 flex items-end justify-between gap-4">
        <div>
          <p class="text-xs uppercase tracking-[0.25em] text-cyan-200/70">Feature Matrix</p>
          <h2 class="mt-1 text-2xl font-black text-white">影院业务能力矩阵</h2>
          <p class="mt-1 text-sm text-slate-400">让管理后台不仅能用，还要像数字影院控制台一样具有沉浸感。</p>
        </div>
      </div>
      <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
        <div v-for="item in features" :key="item.title" class="group rounded-3xl border border-cyan-400/15 bg-white/5 p-4 transition duration-300 hover:-translate-y-1 hover:border-cyan-300/25 hover:bg-white/10 hover:shadow-[0_20px_50px_rgba(34,211,238,.08)]">
          <div class="mb-3 grid h-10 w-10 place-items-center rounded-2xl bg-[linear-gradient(135deg,rgba(124,58,237,.95),rgba(6,182,212,.95))] text-white shadow-[0_12px_30px_rgba(34,211,238,.18)]">
            <Icon :icon="item.icon" class="text-xl" />
          </div>
          <strong class="text-base text-white">{{ item.title }}</strong>
          <p class="mt-2 text-sm leading-6 text-slate-300">{{ item.desc }}</p>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { Icon } from '@iconify/vue'
import { Swiper, SwiperSlide } from 'swiper/vue'
import { Autoplay } from 'swiper/modules'
import 'swiper/css'
import { playApi } from '../api/ttms'
import { ui } from '../config/ui'

const modules = [Autoplay]

// 电影简介映射表 —— 按影片名称匹配，用于首页推荐位展示
const movieDescriptionMap = {
  '迷城追踪': '都市悬疑题材影片，一名调查记者在旧城区追查失踪案，逐步揭开隐藏多年的秘密。',
  '月海计划': '科幻冒险影片，深空探测队登陆月海基地后遭遇失联危机，在倒计时中完成自救。',
  '周末训练营': '轻松喜剧片，一群性格迥异的年轻人在封闭训练营里发生一连串误会与笑料。',
  '风筝小队': '合家欢动画电影，几位少年伙伴和机械风筝一起展开城市上空的冒险旅程。'
}

// 从当前轮播数据生成推荐影片列表（优先使用映射表中的简介，其次用数据库简介）
const featuredMovies = computed(() => {
  return slides.value.slice(0, 4).map(slide => ({
    title: slide.title,
    desc: movieDescriptionMap[slide.title] || slide.description || '暂无简介'
  }))
})

const features = [
  { title: '剧目管理', desc: '统一维护电影资料、简介、海报与票价，让片库信息更清晰。', icon: 'solar:clapperboard-text-bold-duotone' },
  { title: '排片管理', desc: '快速安排场次、影厅与时间段，打造更高效的放映排期。', icon: 'solar:calendar-bold-duotone' },
  { title: '售票退票', desc: '兼顾前台售票与退票处理，保证窗口操作流畅稳定。', icon: 'solar:ticket-sale-bold-duotone' },
  { title: '销售分析', desc: '从票房、影片排行到员工维度分析，辅助影院精细化运营。', icon: 'solar:chart-2-bold-duotone' },
  { title: '用户管理', desc: '对员工信息、角色权限进行统一管理，增强后台协同效率。', icon: 'solar:users-group-rounded-bold-duotone' },
  { title: '演出厅管理', desc: '支持影厅配置与座位布局维护，营造更完整的影院基础设施能力。', icon: 'solar:buildings-3-bold-duotone' }
]

const fallbackDefaultPath = '/images/play/default.png'
const slides = ref([])
const currentSlide = ref(0)
let swiperInstance = null

const activeSlide = computed(() => slides.value[currentSlide.value] || null)

onMounted(async () => {
  await loadSlides()
})

onBeforeUnmount(() => {
  swiperInstance = null
})

function onSwiper(swiper) {
  swiperInstance = swiper
}

function onSlideChange(swiper) {
  currentSlide.value = swiper.realIndex
}

async function loadSlides() {
  try {
    const res = await playApi.list()
    const plays = Array.isArray(res?.content) ? res.content : []
    const picked = plays.slice(0, 5)
    slides.value = (picked.length ? picked : [{}]).map((play, index) => createSlide(play, index))
  } catch (e) {
    slides.value = [createSlide({}, 0)]
  }
}

function createSlide(play = {}, index = 0) {
  const playId = Number(play.play_id)
  const validId = Number.isFinite(playId) && playId > 0 ? playId : null
  const title = play.play_name || `影院推荐 ${index + 1}`
  return {
    id: validId ?? `default-${index}`,
    playId: validId,
    playIdText: validId ?? '未配置',
    posterPathText: validId ? `/images/play/${String.fromCharCode(96 + validId)}.png` : fallbackDefaultPath,
    title,
    description: play.play_introduction || '这里为首页预留了大幅电影轮播图区域。你只需要把电影海报放到 public/images/play 目录下，并按 play_id 命名，系统就会自动展示。',
    image: validId ? `/images/play/${String.fromCharCode(96 + validId)}.png` : fallbackDefaultPath,
    state: validId ? 'play' : 'default'
  }
}

function prevSlide() {
  swiperInstance?.slidePrev()
}

function nextSlide() {
  swiperInstance?.slideNext()
}

function goTo(index) {
  swiperInstance?.slideToLoop?.(index) ?? swiperInstance?.slideTo(index)
}

function onSlideImageError(slide, event) {
  if (!slide || !event?.target) return
  if (slide.state === 'play') {
    slide.state = 'default'
    slide.image = fallbackDefaultPath
    event.target.src = fallbackDefaultPath
    return
  }
  if (slide.state === 'default') {
    slide.state = 'inline'
    slide.image = createInlinePoster(slide.title)
    event.target.src = slide.image
  }
}

function createInlinePoster(title) {
  const safeTitle = escapeXml(String(title || 'TTMS CINEMA'))
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1600 900" width="1600" height="900">
    <defs>
      <linearGradient id="bg" x1="0" x2="1" y1="0" y2="1">
        <stop offset="0%" stop-color="#020617"/>
        <stop offset="55%" stop-color="#0f172a"/>
        <stop offset="100%" stop-color="#172554"/>
      </linearGradient>
      <radialGradient id="orb1" cx="0.2" cy="0.15" r="0.55">
        <stop offset="0%" stop-color="#22d3ee" stop-opacity="0.9"/>
        <stop offset="100%" stop-color="#22d3ee" stop-opacity="0"/>
      </radialGradient>
      <radialGradient id="orb2" cx="0.82" cy="0.18" r="0.45">
        <stop offset="0%" stop-color="#a855f7" stop-opacity="0.85"/>
        <stop offset="100%" stop-color="#a855f7" stop-opacity="0"/>
      </radialGradient>
    </defs>
    <rect width="1600" height="900" fill="url(#bg)"/>
    <rect width="1600" height="900" fill="url(#orb1)"/>
    <rect width="1600" height="900" fill="url(#orb2)"/>
    <rect x="72" y="72" width="1456" height="756" rx="32" fill="none" stroke="rgba(34,211,238,.35)"/>
    <text x="120" y="210" fill="#67e8f9" font-family="Arial, sans-serif" font-size="34" letter-spacing="8">TTMS CINEMA</text>
    <text x="120" y="380" fill="#ffffff" font-family="Arial, sans-serif" font-size="86" font-weight="700">${safeTitle}</text>
    <text x="120" y="465" fill="#cbd5e1" font-family="Arial, sans-serif" font-size="30">默认轮播海报 · 请放置 /public/images/play/default.png</text>
    <text x="120" y="540" fill="#94a3b8" font-family="Arial, sans-serif" font-size="28">或按 play_id 命名你的电影海报，例如：8.png</text>
  </svg>`
  return `data:image/svg+xml;charset=UTF-8,${encodeURIComponent(svg)}`
}

function escapeXml(value) {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;')
}
</script>
