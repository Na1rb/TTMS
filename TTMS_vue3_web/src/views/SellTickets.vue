<template>
  <section :class="ui.page">
    <div :class="ui.sectionHead">
      <h1 :class="ui.title" class="flex items-center gap-3">
        {{ mode === -1 ? '退票' : '售票' }}
        <span v-if="isVip" class="inline-flex items-center gap-1 rounded-full bg-amber-500/15 px-3 py-1 text-sm font-bold text-amber-300"><Icon icon="solar:crown-star-bold-duotone" />VIP · 提前50分钟购票</span>
      </h1>
    </div>
    <p v-if="message" :class="ui.tip">{{ message }}</p>

    <!-- ==================== 剧目选择 —— 图片卡片网格 ==================== -->
    <section class="mb-5">
      <h2 class="mb-3 font-bold text-white">选择剧目</h2>
      <div v-if="!plays.length" :class="ui.empty">暂无剧目数据。</div>
      <div v-else class="grid gap-4 sm:grid-cols-2 md:grid-cols-3 xl:grid-cols-4">
        <article
          v-for="p in plays"
          :key="p.play_id"
          class="group cursor-pointer overflow-hidden rounded-2xl border transition-all duration-300 hover:-translate-y-1 hover:shadow-xl hover:shadow-cyan-400/10"
          :class="selectedPlayId === p.play_id ? 'border-cyan-400 shadow-lg shadow-cyan-400/20 ring-1 ring-cyan-400/30' : 'border-cyan-400/15'"
          @click="selectPlay(p)"
        >
          <!-- 海报图 3:4 -->
          <div class="relative overflow-hidden" style="aspect-ratio:3/4;">
            <img
              :src="getPlayImage(p.play_id)"
              :alt="p.play_name"
              class="h-full w-full object-cover transition-all duration-500 group-hover:scale-105"
              @error="onPlayImageError($event)"
            />
            <div class="absolute inset-0 bg-gradient-to-t from-slate-950/90 via-transparent to-transparent"></div>
            <div class="absolute bottom-0 left-0 right-0 p-3">
              <h3 class="text-sm font-bold text-white leading-tight">{{ p.play_name }}</h3>
            </div>
            <!-- 选中标记 -->
            <div v-if="selectedPlayId === p.play_id" class="absolute right-2 top-2 grid h-8 w-8 place-items-center rounded-full bg-cyan-400 text-slate-900 shadow-lg">
              <Icon icon="solar:check-circle-bold-duotone" class="text-lg" />
            </div>
          </div>
          <!-- 票价条 -->
          <div class="flex items-center justify-between bg-slate-900/90 px-3 py-2.5 backdrop-blur">
            <span class="text-xs font-medium text-slate-400">票价</span>
            <span class="text-base font-black text-cyan-300">￥{{ p.play_ticket_price }}</span>
          </div>
        </article>
      </div>
    </section>

    <!-- ==================== 演出计划 / 座位选择 —— 右侧两步面板 ==================== -->
    <Teleport to="body">
      <transition name="panel-slide">
        <div v-if="schedulePanel.show" class="fixed inset-0 z-50 flex justify-end" @click.self="closeSchedulePanel">
          <div class="pointer-events-none absolute inset-0 bg-slate-950/60 backdrop-blur-sm"></div>
          <div
            class="pointer-events-auto relative flex h-full w-full flex-col border-l border-cyan-400/15 bg-slate-950/95 shadow-2xl transition-all duration-300"
            :class="schedulePanel.step === 'seats' ? 'max-w-2xl' : 'max-w-md'"
          >
            <!-- 面板头部 -->
            <div class="flex items-center justify-between border-b border-cyan-400/10 p-5">
              <div class="flex items-center gap-3">
                <!-- 返回按钮（仅在选座步骤显示） -->
                <button v-if="schedulePanel.step === 'seats'" class="grid h-10 w-10 place-items-center rounded-xl border border-cyan-400/15 bg-white/5 text-slate-300 transition hover:bg-white/10" @click="backToSchedules">
                  <Icon icon="solar:arrow-left-bold-duotone" class="text-xl" />
                </button>
                <div>
                  <p class="text-xs uppercase tracking-[0.2em] text-cyan-200/70">{{ schedulePanel.step === 'seats' ? '选择座位' : '演出计划' }}</p>
                  <h2 class="mt-1 text-lg font-black text-white">{{ schedulePanel.playName }}</h2>
                  <p v-if="schedulePanel.step === 'seats' && schedulePanel.scheduleInfo" class="mt-0.5 text-sm text-cyan-200/60">
                    {{ schedulePanel.scheduleInfo.sched_time }} · {{ schedulePanel.scheduleInfo.studio_id }} 号厅 · ￥{{ schedulePanel.scheduleInfo.sched_ticket_price }}
                  </p>
                </div>
              </div>
              <button class="grid h-10 w-10 place-items-center rounded-xl border border-cyan-400/15 bg-white/5 text-slate-300 transition hover:bg-white/10" @click="closeSchedulePanel">
                <Icon icon="solar:close-circle-bold-duotone" class="text-xl" />
              </button>
            </div>

            <!-- 面板内容 -->
            <div class="flex-1 overflow-y-auto p-5">
              <!-- Step 1：场次选择 -->
              <template v-if="schedulePanel.step === 'schedules'">
                <div v-if="!schedules.length" :class="ui.empty">该剧目暂无演出计划。</div>
                <div v-else class="grid gap-3">
                  <button
                    v-for="s in schedules"
                    :key="s.sched_id"
                    class="rounded-2xl border p-4 text-left transition hover:border-cyan-400/30 hover:bg-cyan-400/5"
                    :class="currentScheduleId === s.sched_id ? 'border-cyan-400 bg-cyan-400/10 shadow-lg shadow-cyan-400/10' : 'border-cyan-400/15 bg-slate-900/80'"
                    @click="pickSchedule(s)"
                  >
                    <div class="flex items-center justify-between">
                      <span class="font-bold text-white">{{ s.sched_time }}</span>
                      <span class="text-lg font-black text-cyan-300">￥{{ s.sched_ticket_price }}</span>
                    </div>
                    <div class="mt-2 flex items-center gap-3 text-xs text-slate-400">
                      <span class="inline-flex items-center gap-1"><Icon icon="solar:home-2-bold-duotone" /> {{ s.studio_id }} 号厅</span>
                    </div>
                  </button>
                </div>
              </template>

              <!-- Step 2：座位选择 -->
              <template v-else>
                <div v-if="!tickets.length" :class="ui.empty">该场次暂无座位数据。</div>
                <div v-else class="rounded-2xl border border-cyan-400/15 bg-white/5 p-4">
                  <div class="max-w-full overflow-x-auto">
                    <div class="grid justify-start gap-2" :style="seatGridStyle">
                      <button
                        v-for="t in tickets"
                        :key="t.ticket_id"
                        :class="seatClass(t)"
                        :style="{ gridRow: t.seat_row, gridColumn: t.seat_column }"
                        @click="toggle(t)"
                      >{{ t.seat_row }}-{{ t.seat_column }}</button>
                    </div>
                  </div>
                </div>
              </template>
            </div>

            <!-- 面板底部操作 -->
            <div class="border-t border-cyan-400/10 p-5">
              <!-- 面板内错误/提示消息 -->
              <p v-if="panelMessage" class="mb-3 rounded-2xl border border-rose-400/20 bg-rose-500/10 px-4 py-2.5 text-sm text-rose-100">{{ panelMessage }}</p>
              <!-- Step 1：下一步 -->
              <template v-if="schedulePanel.step === 'schedules'">
                <button :class="ui.btn" class="w-full" :disabled="!currentScheduleId" @click="goToSeats">
                  下一步：选座位 <Icon icon="solar:arrow-right-bold-duotone" class="ml-1" />
                </button>
              </template>
              <!-- Step 2：选座统计 & 下单 -->
              <template v-else>
                <div class="flex flex-wrap items-center justify-between gap-3">
                  <span class="font-semibold text-cyan-100">已选 {{ selected.length }} 张，总价 ￥{{ total }}</span>
                  <button :class="ui.btn" :disabled="!selected.length" @click="createOrder">
                    <Icon icon="solar:bill-list-bold-duotone" />生成订单
                  </button>
                </div>
              </template>
            </div>
          </div>
        </div>
      </transition>
    </Teleport>

    <!-- 数学验证弹窗（售票流程） -->
    <DialogRoot v-model:open="mathPopup.show">
      <DialogPortal><DialogOverlay :class="ui.dialogOverlay" /><DialogContent :class="ui.dialogSmall">
        <DialogTitle class="flex items-center gap-2 text-xl font-bold text-white"><Icon icon="solar:shield-check-bold-duotone" class="text-2xl text-cyan-400" />验证购票</DialogTitle>
        <p :class="ui.tip" class="mt-4">{{ mathPopup.question }}</p>
        <input v-model.number="mathPopup.answer" :class="ui.input" type="number" placeholder="请输入答案" @keyup.enter="submitAnswer" />
        <div class="mt-5 flex gap-3">
          <button :class="ui.btn" :disabled="mathPopup.answer === null || mathPopup.submitting" @click="submitAnswer"><Icon :icon="mathPopup.submitting ? 'svg-spinners:180-ring' : 'solar:check-circle-bold-duotone'" />{{ mathPopup.submitting ? '验证中...' : '提交答案' }}</button>
          <button :class="ui.btnDanger" :disabled="mathPopup.submitting" @click="cancelMathPopup">放弃购买</button>
        </div>
        <p v-if="mathPopup.error" class="mt-4 rounded-2xl bg-rose-500/10 px-4 py-3 text-sm text-rose-200">{{ mathPopup.error }}</p>
      </DialogContent></DialogPortal>
    </DialogRoot>
  </section>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, reactive, ref } from 'vue'
import { Icon } from '@iconify/vue'
import { DialogContent, DialogOverlay, DialogPortal, DialogRoot, DialogTitle } from 'radix-vue'
import { playApi, saleApi, scheduleApi, ticketApi } from '../api/ttms'
import { useUserStore } from '../stores/user'
import { ui } from '../config/ui'
const props = defineProps({ mode: { type: Number, default: 1 } })
const mode = computed(() => props.mode), userStore = useUserStore(), isVip = computed(() => userStore.user?.emp_type === 4)
const plays = ref([]), schedules = ref([]), tickets = ref([]), selected = ref([]), message = ref(''), panelMessage = ref(''), currentScheduleId = ref(null)
const selectedPlayId = ref(null)
const schedulePanel = reactive({ show: false, playName: '', step: 'schedules', scheduleInfo: null })
let pollTimer = null
const total = computed(() => selected.value.reduce((sum, t) => sum + Number(t.ticket_price || 0), 0).toFixed(2))
const maxCol = computed(() => { if (!tickets.value.length) return 1; return Math.max(...tickets.value.map(t => Number(t.seat_column))) })
const seatGridStyle = computed(() => ({ gridTemplateColumns: `repeat(${maxCol.value}, minmax(42px, 56px))` }))
const mathPopup = reactive({ show: false, question: '', answer: null, error: '', submitting: false, saleId: null })

const fallbackImage = '/images/play/default.png'
function getPlayImage(playId) { return playId ? `/images/play/${playId}.png` : fallbackImage }
function onPlayImageError(event) { if (event?.target) event.target.src = fallbackImage }

function stopPolling() { if (pollTimer) { clearInterval(pollTimer); pollTimer = null } }
function startPolling() { stopPolling(); pollTimer = setInterval(refreshTickets, 30000) }
async function refreshTickets() { if (!currentScheduleId.value) return; const selectedIds = selected.value.map(t => t.ticket_id); const res = await ticketApi.byScheduleId(currentScheduleId.value); if (!res.flag) return; tickets.value = res.content; selected.value = res.content.filter(t => selectedIds.includes(t.ticket_id) && canSelect(t)); if (selectedIds.length - selected.value.length > 0) { const msg = `有 ${selectedIds.length - selected.value.length} 个座位已被他人抢占，已自动清除`; message.value = msg; panelMessage.value = msg } }
async function loadPlays() { const res = await playApi.list(); plays.value = res.flag ? res.content : []; message.value = res.flag ? '' : res.content }

async function selectPlay(play) {
  stopPolling()
  currentScheduleId.value = null
  tickets.value = []
  selected.value = []
  selectedPlayId.value = play.play_id
  panelMessage.value = ''
  const res = await scheduleApi.todayLeast(play.play_id)
  schedules.value = res.flag ? res.content : []
  message.value = res.flag ? '' : res.content
  // 打开右侧滑出面板，重置为场次步骤
  schedulePanel.playName = play.play_name
  schedulePanel.step = 'schedules'
  schedulePanel.scheduleInfo = null
  schedulePanel.show = true
}

function closeSchedulePanel() {
  stopPolling()
  schedulePanel.show = false
  schedulePanel.step = 'schedules'
  schedulePanel.scheduleInfo = null
  panelMessage.value = ''
}

async function pickSchedule(schedule) {
  currentScheduleId.value = schedule.sched_id
  schedulePanel.scheduleInfo = schedule
  panelMessage.value = ''
  // 预加载座位数据，但仍停留在场次步骤，等待用户点击"下一步"
  const res = await ticketApi.byScheduleId(schedule.sched_id)
  tickets.value = res.flag ? res.content : []
  selected.value = []
  message.value = res.flag ? '' : res.content
}

function goToSeats() {
  if (!currentScheduleId.value) return
  schedulePanel.step = 'seats'
  panelMessage.value = ''
  startPolling()
}

function backToSchedules() {
  stopPolling()
  schedulePanel.step = 'schedules'
  panelMessage.value = ''
  // 保留 currentScheduleId 用于场次高亮
}
function canSelect(t) { return mode.value === 1 ? Number(t.ticket_status) === 0 : Number(t.ticket_status) === 1 }
function toggle(t) { if (!canSelect(t)) return; const i = selected.value.findIndex(x => x.ticket_id === t.ticket_id); i >= 0 ? selected.value.splice(i, 1) : selected.value.push(t) }
function seatClass(t) { const status = Number(t.ticket_status); return ['min-h-[38px] sm:min-h-[44px] min-w-[38px] sm:min-w-[52px] rounded-xl px-1.5 sm:px-2 text-xs font-bold shadow-sm transition', status === 1 ? 'bg-slate-400 text-white' : status === 2 ? 'bg-amber-400 text-white' : 'bg-emerald-500 text-white', selected.value.some(x => x.ticket_id === t.ticket_id) ? 'ring-4 ring-indigo-300' : '', !canSelect(t) ? 'cursor-not-allowed opacity-50' : 'hover:scale-105'] }
async function createOrder() { panelMessage.value = ''; const res = await saleApi.create(selected.value, mode.value); if (!res.flag) { panelMessage.value = res.content; return }     if (mode.value === -1) { const content = res.content; const pay = await saleApi.pay(content.sale ? content.sale.sale_ID : content.sale_ID, mode.value); message.value = pay.content; selected.value = []; closeSchedulePanel(); await refreshTickets(); return } const data = res.content; Object.assign(mathPopup, { show: true, question: data.question || '请计算', answer: null, error: '', submitting: false, saleId: data.sale ? data.sale.sale_ID : null }); message.value = '' }
async function submitAnswer() { if (mathPopup.answer === null || mathPopup.submitting) return; mathPopup.submitting = true; mathPopup.error = ''; panelMessage.value = ''; const pay = await saleApi.pay(mathPopup.saleId, mode.value, mathPopup.answer);     if (pay.flag) { message.value = pay.content; mathPopup.show = false; selected.value = []; closeSchedulePanel(); await refreshTickets() } else { mathPopup.error = pay.content || '答案错误，请重新计算'; panelMessage.value = pay.content || '答案错误，请重新计算' } mathPopup.submitting = false }
async function cancelMathPopup() { mathPopup.show = false; if (mathPopup.saleId) { await saleApi.cancel(mathPopup.saleId, mode.value); await refreshTickets() } panelMessage.value = '已取消本次购票，座位已释放' }
onMounted(loadPlays)
onBeforeUnmount(stopPolling)
</script>
