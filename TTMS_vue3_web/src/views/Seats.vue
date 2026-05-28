<template>
  <section :class="ui.page">
    <div :class="ui.sectionHead"><h1 :class="ui.title">座位管理</h1><button :class="ui.btn" :disabled="!selectedStudioId || loading" @click="initSeats"><Icon icon="solar:widget-add-bold-duotone" />初始化座位</button></div>
    <div :class="ui.toolbar"><UiSelect v-model="selectedStudioId" class="max-w-sm" :options="studioOptions" placeholder="请选择演出厅" @update:model-value="loadSeats" /><button :class="ui.btnSoft" :disabled="!selectedStudioId || loading" @click="loadSeats"><Icon icon="solar:refresh-bold-duotone" />加载座位</button></div>
    <p v-if="message" :class="ui.tip">{{ message }}</p>
    <div v-if="selectedStudio" class="mb-5 flex flex-wrap gap-3 text-sm text-slate-300"><span v-for="item in summary" :key="item" class="rounded-full bg-slate-800 px-4 py-2 font-semibold">{{ item }}</span></div>
    <div v-if="seats.length">
      <div class="mb-4 flex flex-wrap gap-4 text-sm font-semibold text-slate-400"><span v-for="item in legends" :key="item.text" class="inline-flex items-center gap-2"><span :class="item.color" class="h-4 w-4 rounded" />{{ item.text }}</span></div>
      <div class="max-w-full overflow-x-auto rounded-3xl border border-cyan-400/15 bg-slate-900/60 p-5"><div class="grid justify-start gap-2" :style="seatMapStyle"><button v-for="seat in seats" :key="seat.seat_id" :class="seatClass(seat)" :title="statusText(seat.seat_status)" @click="toggleStatus(seat)">{{ seat.seat_row }}-{{ seat.seat_column }}</button></div></div>
      <div class="mt-5 flex flex-wrap items-center justify-between gap-3 rounded-2xl bg-cyan-400/10 p-4 font-semibold text-cyan-200"><span>已修改 {{ changedCount }} 个座位</span><div class="flex gap-2"><button :class="ui.btn" :disabled="!changedCount || loading" @click="saveSeats"><Icon icon="solar:diskette-bold-duotone" />保存修改</button><button :class="ui.btnSoft" type="button" :disabled="loading" @click="loadSeats">重置</button></div></div>
    </div>
    <div v-else-if="selectedStudioId && !loading" :class="ui.empty">当前演出厅暂无座位数据，可点击“初始化座位”。</div>
  </section>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { Icon } from '@iconify/vue'
import UiSelect from '../components/UiSelect.vue'
import { seatApi, studioApi } from '../api/ttms'
import { ui } from '../config/ui'
const studios = ref([]), seats = ref([]), selectedStudioId = ref(''), message = ref(''), loading = ref(false), changedSeats = ref({})
const selectedStudio = computed(() => studios.value.find(s => Number(s.studio_id) === Number(selectedStudioId.value)))
const studioOptions = computed(() => studios.value.map(s => ({ value: s.studio_id, label: `${s.studio_name}（${s.studio_row_count} 行 × ${s.studio_col_count} 列）` })))
const changedCount = computed(() => Object.keys(changedSeats.value).length)
const seatMapStyle = computed(() => ({ gridTemplateColumns: `repeat(${Number(selectedStudio.value?.studio_col_count || 1)}, minmax(42px, 56px))` }))
const summary = computed(() => [`演出厅：${selectedStudio.value.studio_name}`, `规模：${selectedStudio.value.studio_row_count} 行 × ${selectedStudio.value.studio_col_count} 列`, `座位数：${selectedStudio.value.studio_seat_count}`])
const legends = [{ text: '可用', color: 'bg-emerald-500' }, { text: '损坏', color: 'bg-slate-500' }, { text: '未设置', color: 'bg-emerald-500/30' }, { text: '已修改', color: 'bg-amber-500' }]
function sortSeats(list) { return [...list].sort((a, b) => Number(a.seat_row) - Number(b.seat_row) || Number(a.seat_column) - Number(b.seat_column)) }
function statusText(status) { return Number(status) === 1 ? '可用座位' : Number(status) === -1 ? '损坏座位' : '未设置座位' }
function nextStatus(status) { return Number(status) === 0 ? 1 : Number(status) === 1 ? -1 : 0 }
function seatClass(seat) { const status = Number(seat.seat_status); return ['min-h-[38px] sm:min-h-[44px] min-w-[38px] sm:min-w-[52px] rounded-xl px-1.5 sm:px-2 text-xs font-bold text-white shadow-sm transition hover:scale-105', status === -1 ? 'bg-slate-500' : status === 0 ? 'bg-emerald-500/40 text-emerald-100' : 'bg-emerald-500', Object.prototype.hasOwnProperty.call(changedSeats.value, seat.seat_id) ? 'ring-4 ring-amber-300' : ''] }
async function loadStudios() { const res = await studioApi.list(); studios.value = res.flag ? res.content : []; message.value = res.flag ? '' : res.content }
async function loadSeats() { if (!selectedStudioId.value) { seats.value = []; changedSeats.value = {}; return } loading.value = true; const res = await seatApi.byStudioId(selectedStudioId.value); seats.value = res.flag ? sortSeats(res.content) : []; changedSeats.value = {}; message.value = res.flag ? '' : res.content; loading.value = false }
async function initSeats() { if (!selectedStudioId.value) return; loading.value = true; const res = await seatApi.init(selectedStudioId.value); message.value = res.content; loading.value = false; if (res.flag) await loadSeats() }
function toggleStatus(seat) { seat.seat_status = nextStatus(seat.seat_status); changedSeats.value = { ...changedSeats.value, [seat.seat_id]: Number(seat.seat_status) } }
async function saveSeats() { if (!selectedStudioId.value || !changedCount.value) return; loading.value = true; const res = await seatApi.updateByStudioId(selectedStudioId.value, changedSeats.value); message.value = res.content; loading.value = false; if (res.flag) await loadSeats() }
onMounted(loadStudios)
</script>
