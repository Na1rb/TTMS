<template>
  <section :class="ui.page">
    <div :class="ui.sectionHead"><h1 :class="ui.title">演出厅管理</h1><button :class="ui.btn" @click="openAdd"><Icon icon="solar:add-square-bold-duotone" />新增演出厅</button></div>
    <div :class="ui.toolbar"><input v-model="keyword" :class="ui.input" class="max-w-xs" placeholder="按名称搜索" @keyup.enter="load" /><button :class="ui.btnSoft" @click="load"><Icon icon="solar:magnifer-bold-duotone" />查询</button></div>
    <p v-if="message" :class="ui.tip">{{ message }}</p>
    <div :class="ui.tableWrap"><table :class="ui.table"><thead><tr><th :class="ui.th">ID</th><th :class="ui.th">名称</th><th :class="ui.th">行</th><th :class="ui.th">列</th><th :class="ui.th">座位数</th><th :class="ui.th">状态</th><th :class="ui.th">简介</th><th :class="ui.th">操作</th></tr></thead><tbody class="divide-y divide-cyan-400/10"><tr v-for="s in rows" :key="s.studio_id" class="hover:bg-white/5"><td :class="ui.td">{{ s.studio_id }}</td><td :class="ui.td" class="font-semibold text-white">{{ s.studio_name }}</td><td :class="ui.td">{{ s.studio_row_count }}</td><td :class="ui.td">{{ s.studio_col_count }}</td><td :class="ui.td">{{ s.studio_seat_count }}</td><td :class="ui.td">{{ s.studio_flag }}</td><td :class="ui.td">{{ s.studio_introduction }}</td><td :class="ui.td"><div class="flex gap-2"><button :class="ui.iconBtn" @click="edit(s)"><Icon icon="solar:pen-bold-duotone" />编辑</button><button :class="ui.dangerIconBtn" @click="remove(s)"><Icon icon="solar:trash-bin-trash-bold-duotone" />删除</button></div></td></tr></tbody></table></div>
    <DialogRoot v-model:open="editing"><DialogPortal><DialogOverlay :class="ui.dialogOverlay" /><DialogContent :class="ui.dialogContent"><DialogTitle :class="ui.dialogTitle">{{ form.studio_id ? '编辑演出厅' : '新增演出厅' }}</DialogTitle><form :class="ui.formGrid" @submit.prevent="save"><label :class="ui.label">名称<input v-model="form.studio_name" :class="ui.input" placeholder="名称 studio_name" /></label><label :class="ui.label">行数<input v-model.number="form.studio_row_count" :class="ui.input" type="number" placeholder="行数 studio_row_count" /></label><label :class="ui.label">列数<input v-model.number="form.studio_col_count" :class="ui.input" type="number" placeholder="列数 studio_col_count" /></label><label :class="ui.label">状态<input v-model.number="form.studio_flag" :class="ui.input" type="number" placeholder="状态 studio_flag" /></label><label :class="ui.label">简介<textarea v-model="form.studio_introduction" :class="ui.textarea" placeholder="简介 studio_introduction" /></label><div class="mt-2 flex justify-end gap-3"><DialogClose :class="ui.btnSoft" type="button">取消</DialogClose><button :class="ui.btn"><Icon icon="solar:diskette-bold-duotone" />保存</button></div></form></DialogContent></DialogPortal></DialogRoot>
    <ConfirmDialog v-model:open="confirmOpen" :message="confirmMessage" @confirm="confirmRemove" />
  </section>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { Icon } from '@iconify/vue'
import { DialogClose, DialogContent, DialogOverlay, DialogPortal, DialogRoot, DialogTitle } from 'radix-vue'
import ConfirmDialog from '../components/ConfirmDialog.vue'
import { studioApi } from '../api/ttms'
import { ui } from '../config/ui'
const rows = ref([]), keyword = ref(''), message = ref(''), editing = ref(false), confirmOpen = ref(false), confirmMessage = ref(''), pendingRemove = ref(null)
const form = reactive({})
function reset(data = {}) { Object.keys(form).forEach(k => delete form[k]); Object.assign(form, { studio_flag: 1 }, data) }
function openAdd() { reset(); editing.value = true }
function edit(row) { reset(row); editing.value = true }
async function load() { const res = keyword.value ? await studioApi.search(keyword.value) : await studioApi.list(); rows.value = res.flag ? res.content : []; message.value = res.flag ? '' : res.content }
async function save() { const res = form.studio_id ? await studioApi.update(form) : await studioApi.add(form); message.value = res.content; if (res.flag) { editing.value = false; await load() } }
function remove(row) { pendingRemove.value = row; confirmMessage.value = `确认删除演出厅 ${row.studio_name} 吗？`; confirmOpen.value = true }
async function confirmRemove() { if (!pendingRemove.value) return; const res = await studioApi.remove(pendingRemove.value.studio_id); message.value = res.content; pendingRemove.value = null; await load() }
onMounted(load)
</script>
