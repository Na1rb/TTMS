<template>
  <section :class="ui.page">
    <div :class="ui.sectionHead"><h1 :class="ui.title">排片管理</h1><button :class="ui.btn" @click="openAdd"><Icon icon="solar:calendar-add-bold-duotone" />新增排片</button></div>
    <div :class="ui.toolbar"><UiSelect v-model="filters.play_id" class="max-w-xs" :options="playFilterOptions" placeholder="按剧目筛选" /><UiSelect v-model="filters.studio_id" class="max-w-xs" :options="studioFilterOptions" placeholder="按影厅筛选" /><button :class="ui.btnSoft" @click="load"><Icon icon="solar:filter-bold-duotone" />查询</button></div>
    <p v-if="message" :class="ui.tip">{{ message }}</p>
    <div :class="ui.tableWrap"><table :class="ui.table"><thead><tr><th :class="ui.th">ID</th><th :class="ui.th">剧目</th><th :class="ui.th">影厅</th><th :class="ui.th">演出时间</th><th :class="ui.th">票价</th><th :class="ui.th">操作</th></tr></thead><tbody class="divide-y divide-cyan-400/10"><tr v-for="s in rows" :key="s.sched_id" class="hover:bg-white/5"><td :class="ui.td">{{ s.sched_id }}</td><td :class="ui.td" class="font-semibold text-white">{{ playName(s.play_id) }}</td><td :class="ui.td">{{ studioName(s.studio_id) }}</td><td :class="ui.td">{{ s.sched_time }}</td><td :class="ui.td">￥{{ s.sched_ticket_price }}</td><td :class="ui.td"><div class="flex flex-col sm:flex-row gap-1.5 sm:gap-2"><button :class="ui.iconBtn" @click="edit(s)"><Icon icon="solar:pen-bold-duotone" />编辑</button><button :class="ui.dangerIconBtn" @click="remove(s)"><Icon icon="solar:trash-bin-trash-bold-duotone" />删除</button></div></td></tr></tbody></table></div>
    <DialogRoot v-model:open="editing"><DialogPortal><DialogOverlay :class="ui.dialogOverlay" /><DialogContent :class="ui.dialogContent"><DialogTitle :class="ui.dialogTitle">{{ form.sched_id ? '编辑排片' : '新增排片' }}</DialogTitle><form :class="ui.formGrid" @submit.prevent="save"><label :class="ui.label">剧目<UiSelect v-model="form.play_id" :options="playOptions" placeholder="请选择剧目 play_id" /></label><label :class="ui.label">影厅<UiSelect v-model="form.studio_id" :options="studioOptions" placeholder="请选择影厅 studio_id" /></label><label :class="ui.label">演出时间<input v-model="form.sched_time" :class="ui.input" type="datetime-local" required /></label><label :class="ui.label">票价<input v-model.number="form.sched_ticket_price" :class="ui.input" type="number" step="0.01" min="0" required placeholder="票价 sched_ticket_price" /></label><div class="mt-2 flex justify-end gap-3"><DialogClose :class="ui.btnSoft" type="button">取消</DialogClose><button :class="ui.btn"><Icon icon="solar:diskette-bold-duotone" />保存</button></div></form></DialogContent></DialogPortal></DialogRoot>
    <ConfirmDialog v-model:open="confirmOpen" :message="confirmMessage" @confirm="confirmRemove" />
  </section>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { Icon } from '@iconify/vue'
import { DialogClose, DialogContent, DialogOverlay, DialogPortal, DialogRoot, DialogTitle } from 'radix-vue'
import ConfirmDialog from '../components/ConfirmDialog.vue'
import UiSelect from '../components/UiSelect.vue'
import { playApi, scheduleApi, studioApi } from '../api/ttms'
import { ui } from '../config/ui'
const rows = ref([]), plays = ref([]), studios = ref([]), message = ref(''), editing = ref(false), confirmOpen = ref(false), confirmMessage = ref(''), pendingRemove = ref(null)
const filters = reactive({ play_id: 0, studio_id: 0 })
const form = reactive({})
const playName = (id) => plays.value.find(p => Number(p.play_id) === Number(id))?.play_name || id
const studioName = (id) => studios.value.find(s => Number(s.studio_id) === Number(id))?.studio_name || id
function toInputTime(value) { return value ? String(value).replace(' ', 'T').slice(0, 16) : '' }
function toServerTime(value) { const text = String(value || '').replace('T', ' '); return text.length === 16 ? `${text}:00` : text }
function reset(data = {}) { Object.keys(form).forEach(k => delete form[k]); Object.assign(form, { play_id: plays.value[0]?.play_id, studio_id: studios.value[0]?.studio_id, sched_time: '', sched_ticket_price: '' }, data); form.sched_time = toInputTime(form.sched_time) }
function openAdd() { reset(); editing.value = true }
function edit(row) { reset(row); editing.value = true }
async function loadOptions() { const [playRes, studioRes] = await Promise.all([playApi.list(), studioApi.list()]); plays.value = playRes.flag ? playRes.content : []; studios.value = studioRes.flag ? studioRes.content : []; if (!playRes.flag) message.value = playRes.content; if (!studioRes.flag) message.value = studioRes.content }
async function load() { let res; if (filters.play_id) res = await scheduleApi.byPlayId(filters.play_id); else if (filters.studio_id) res = await scheduleApi.byStudioId(filters.studio_id); else { message.value = '请选择剧目或影厅后查询'; rows.value = []; return } rows.value = res.flag ? res.content : []; message.value = res.flag ? '' : res.content }
async function save() { const payload = { ...form, sched_time: toServerTime(form.sched_time) }; const res = form.sched_id ? await scheduleApi.update(payload) : await scheduleApi.add(payload); message.value = res.content; if (res.flag) { editing.value = false; await load() } }
function remove(row) { pendingRemove.value = row; confirmMessage.value = `确认删除排片 ${row.sched_id} 吗？`; confirmOpen.value = true }
async function confirmRemove() { if (!pendingRemove.value) return; const res = await scheduleApi.remove(pendingRemove.value.sched_id); message.value = res.content; pendingRemove.value = null; await load() }
onMounted(async () => { await loadOptions(); if (plays.value.length) filters.play_id = plays.value[0].play_id; await load() })
</script>
