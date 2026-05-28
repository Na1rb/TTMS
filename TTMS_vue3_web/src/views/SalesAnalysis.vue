<template>
  <section :class="ui.page">
    <div :class="ui.sectionHead"><div><h1 :class="ui.title">销售分析</h1><p :class="ui.subtitle">汇总销售额、票房排行、影片排片占比与近 7 日趋势。</p></div><button :class="ui.btn" :disabled="loading" @click="loadAnalysis"><Icon :icon="loading ? 'svg-spinners:180-ring' : 'solar:refresh-bold-duotone'" />{{ loading ? '加载中...' : '刷新数据' }}</button></div>
    <p v-if="message" :class="ui.tip">{{ message }}</p>
    <div class="mb-5 grid gap-4 sm:grid-cols-2 xl:grid-cols-4"><div v-for="item in summaries" :key="item.label" class="rounded-3xl border border-cyan-400/15 bg-white/5 p-5 shadow-sm backdrop-blur"><span class="text-sm font-semibold text-cyan-100/70">{{ item.label }}</span><strong class="mt-2 block text-2xl font-black text-white">{{ item.value }}</strong></div></div>
    <div class="grid gap-5 xl:grid-cols-2"><div v-for="chart in chartCards" :key="chart.title" class="rounded-3xl border border-cyan-400/15 bg-white/5 p-5 backdrop-blur"><div class="mb-3 flex items-center justify-between gap-3"><h2 class="font-bold text-white">{{ chart.title }}</h2><span class="text-xs font-semibold text-slate-400">{{ chart.desc }}</span></div><div :ref="chart.ref" class="h-[300px] w-full"></div></div></div>
    <div class="mt-5 rounded-3xl border border-cyan-400/15 bg-white/5 p-5 backdrop-blur"><h2 class="mb-4 font-bold text-white">影片排行明细</h2><div v-if="loading" :class="ui.empty">正在加载销售分析数据...</div><div v-else-if="!playRanking.length" :class="ui.empty">暂无销售分析数据。</div><div v-else :class="ui.tableWrap"><table :class="ui.table"><thead><tr><th :class="ui.th">排名</th><th :class="ui.th">影片名称</th><th :class="ui.th">销售额</th></tr></thead><tbody class="divide-y divide-cyan-400/10"><tr v-for="(item, index) in playRanking" :key="item.play_name || index"><td :class="ui.td">{{ index + 1 }}</td><td :class="ui.td" class="font-semibold text-white">{{ item.play_name || '-' }}</td><td :class="ui.td">￥{{ formatMoney(item.playTicketAmount) }}</td></tr></tbody></table></div></div>
  </section>
</template>

<script setup>
import { computed, nextTick, onBeforeUnmount, onMounted, ref } from 'vue'
import { Icon } from '@iconify/vue'
import { salesApi } from '../api/ttms'
import { ui } from '../config/ui'
const loading = ref(false), message = ref(''), employeeSales = ref([]), playSales = ref([]), playPercents = ref([]), trendData = ref([])
const employeeChartRef = ref(null), playChartRef = ref(null), percentChartRef = ref(null), trendChartRef = ref(null)
let echartsModule = null, charts = []
const playRanking = computed(() => [...playSales.value].sort((a, b) => toNumber(b.playTicketAmount) - toNumber(a.playTicketAmount)))
const totalSaleAmount = computed(() => employeeSales.value.reduce((sum, item) => sum + toNumber(item.saleAmount), 0))
const todayScheduleAmount = computed(() => playPercents.value.reduce((sum, item) => sum + toNumber(item.play_amount), 0))
const summaries = computed(() => [{ label: '总销售额', value: `￥${formatMoney(totalSaleAmount.value)}` }, { label: '影片数量', value: playRanking.value.length }, { label: '售票员人数', value: employeeSales.value.length }, { label: '今日排片场次', value: formatNumber(todayScheduleAmount.value) }])
const chartCards = [{ title: '售票员销售额', desc: '按售票员统计', ref: el => employeeChartRef.value = el }, { title: '影片票房排行', desc: '按销售金额排序', ref: el => playChartRef.value = el }, { title: '影片排片占比', desc: '全部排片', ref: el => percentChartRef.value = el }, { title: '近 7 日排片趋势', desc: '按日期统计场次', ref: el => trendChartRef.value = el }]
function toNumber(value) { const num = Number(value); return Number.isFinite(num) ? num : 0 }
function formatMoney(value) { return toNumber(value).toFixed(2) }
function formatNumber(value) { return toNumber(value).toFixed(0) }
function getPastDates(days) { return Array.from({ length: days }).map((_, index) => { const date = new Date(); date.setDate(date.getDate() - (days - 1 - index)); return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}` }) }
function normalizeResponse(res) { return res && res.flag ? (res.content || []) : [] }
async function loadAnalysis() { loading.value = true; message.value = ''; try { const dates = getPastDates(7); const [employeesRes, playsRes, percentsRes, ...trendResults] = await Promise.all([salesApi.saleAmountsByEmployeeName(), salesApi.playTicketAmount(), salesApi.playPercentByName(), ...dates.map(date => salesApi.playPercentByDate(date).catch(() => ({ flag: false, content: [] })))]); employeeSales.value = normalizeResponse(employeesRes); playSales.value = normalizeResponse(playsRes); playPercents.value = normalizeResponse(percentsRes); trendData.value = trendResults.map((res, index) => ({ date: dates[index].slice(5), amount: normalizeResponse(res).reduce((sum, item) => sum + toNumber(item.play_amount), 0) })); if (!employeeSales.value.length && !playSales.value.length && !playPercents.value.length) message.value = '暂无销售分析数据。'; await nextTick(); renderCharts() } catch { message.value = '销售分析数据加载失败，请确认后端服务已启动。'; employeeSales.value = []; playSales.value = []; playPercents.value = []; trendData.value = []; await nextTick(); renderCharts() } finally { loading.value = false } }
async function ensureEcharts() { if (echartsModule !== null) return echartsModule; try { echartsModule = await import('echarts') } catch { echartsModule = undefined } return echartsModule }
async function renderCharts() { const echarts = await ensureEcharts(); disposeCharts(); if (!echarts) return; charts = [renderEchart(echarts, employeeChartRef.value, employeeOption()), renderEchart(echarts, playChartRef.value, playOption()), renderEchart(echarts, percentChartRef.value, percentOption()), renderEchart(echarts, trendChartRef.value, trendOption())].filter(Boolean) }
function renderEchart(echarts, el, option) { if (!el) return null; const chart = echarts.init(el); const darkTooltip = { backgroundColor: 'rgba(15,23,42,0.94)', borderColor: 'rgba(34,211,238,0.2)', textStyle: { color: '#e2e8f0' } }; chart.setOption({ backgroundColor: 'transparent', tooltip: darkTooltip, ...option }); return chart }
function employeeOption() { return { tooltip: { trigger: 'axis' }, grid: { top: 32, left: 48, right: 16, bottom: 42 }, xAxis: { type: 'category', data: employeeSales.value.map(item => item.emp_name || `员工${item.emp_id || ''}`), axisLabel: { color: '#94a3b8' } }, yAxis: { type: 'value', axisLabel: { color: '#94a3b8' } }, series: [{ name: '销售额', type: 'bar', data: employeeSales.value.map(item => toNumber(item.saleAmount)), itemStyle: { color: '#4f46e5' } }] } }
function playOption() { return { tooltip: { trigger: 'axis' }, grid: { top: 32, left: 56, right: 16, bottom: 42 }, xAxis: { type: 'category', data: playRanking.value.map(item => item.play_name), axisLabel: { rotate: 25, color: '#94a3b8' } }, yAxis: { type: 'value', axisLabel: { color: '#94a3b8' } }, series: [{ name: '票房', type: 'bar', data: playRanking.value.map(item => toNumber(item.playTicketAmount)), itemStyle: { color: '#10b981' } }] } }
function percentOption() { return { tooltip: { trigger: 'item' }, legend: { bottom: 0, type: 'scroll', textStyle: { color: '#94a3b8' } }, series: [{ name: '排片占比', type: 'pie', radius: ['38%', '66%'], center: ['50%', '44%'], data: playPercents.value.map(item => ({ name: item.play_name, value: toNumber(item.play_amount) })) }] } }
function trendOption() { return { tooltip: { trigger: 'axis' }, grid: { top: 32, left: 48, right: 16, bottom: 42 }, xAxis: { type: 'category', data: trendData.value.map(item => item.date), axisLabel: { color: '#94a3b8' } }, yAxis: { type: 'value', axisLabel: { color: '#94a3b8' } }, series: [{ name: '排片场次', type: 'line', smooth: true, data: trendData.value.map(item => item.amount), areaStyle: {}, itemStyle: { color: '#8b5cf6' } }] } }
function disposeCharts() { charts.forEach(chart => chart.dispose()); charts = [] }
function resizeCharts() { charts.forEach(chart => chart.resize()) }
onMounted(() => { loadAnalysis(); window.addEventListener('resize', resizeCharts) })
onBeforeUnmount(() => { window.removeEventListener('resize', resizeCharts); disposeCharts() })
</script>
