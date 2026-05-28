<template>
  <section :class="ui.page">
    <div :class="ui.sectionHead"><h1 :class="ui.title">剧目管理</h1><button :class="ui.btn" @click="openAdd"><Icon icon="solar:clapperboard-open-play-bold-duotone" />新增剧目</button></div>
    <div :class="ui.toolbar"><input v-model="keyword" :class="ui.input" class="max-w-xs" placeholder="按剧名搜索" @keyup.enter="load" /><button :class="ui.btnSoft" @click="load"><Icon icon="solar:magnifer-bold-duotone" />查询</button></div>
    <p v-if="message" :class="ui.tip">{{ message }}</p>
    <div :class="ui.tableWrap"><table :class="ui.table"><thead><tr><th :class="ui.th">ID</th><th :class="ui.th">封面</th><th :class="ui.th">剧名</th><th :class="ui.th">类型ID</th><th :class="ui.th">语言ID</th><th :class="ui.th">时长</th><th :class="ui.th">票价</th><th :class="ui.th">状态</th><th :class="ui.th">操作</th></tr></thead><tbody class="divide-y divide-cyan-400/10"><tr v-for="p in rows" :key="p.play_id" class="hover:bg-white/5"><td :class="ui.td">{{ p.play_id }}</td><td :class="ui.td"><img v-if="p.Base64play_image" class="h-16 w-12 rounded-lg object-cover ring-1 ring-cyan-400/15" :src="imageSrc(p.Base64play_image)" alt="剧目封面" /><span v-else class="text-xs text-slate-500">暂无</span></td><td :class="ui.td" class="font-semibold text-white">{{ p.play_name }}</td><td :class="ui.td">{{ p.play_type_id }}</td><td :class="ui.td">{{ p.play_lang_id }}</td><td :class="ui.td">{{ p.play_length }}</td><td :class="ui.td">￥{{ p.play_ticket_price }}</td><td :class="ui.td">{{ p.play_status }}</td><td :class="ui.td"><div class="flex flex-col sm:flex-row gap-1.5 sm:gap-2"><button :class="ui.iconBtn" @click="edit(p)"><Icon icon="solar:pen-bold-duotone" />编辑</button><button :class="ui.dangerIconBtn" @click="remove(p)"><Icon icon="solar:trash-bin-trash-bold-duotone" />删除</button></div></td></tr></tbody></table></div>
    <DialogRoot v-model:open="editing"><DialogPortal><DialogOverlay :class="ui.dialogOverlay" /><DialogContent :class="ui.dialogContent"><DialogTitle :class="ui.dialogTitle">{{ form.play_id ? '编辑剧目' : '新增剧目' }}</DialogTitle><form :class="ui.formGrid" @submit.prevent="save"><label :class="ui.label">类型ID<input v-model.number="form.play_type_id" :class="ui.input" type="number" placeholder="类型ID play_type_id" /></label><label :class="ui.label">语言ID<input v-model.number="form.play_lang_id" :class="ui.input" type="number" placeholder="语言ID play_lang_id" /></label><label :class="ui.label">剧名<input v-model="form.play_name" :class="ui.input" placeholder="剧名 play_name" /></label><label :class="ui.label">时长<input v-model.number="form.play_length" :class="ui.input" type="number" placeholder="时长 play_length" /></label><label :class="ui.label">票价<input v-model.number="form.play_ticket_price" :class="ui.input" type="number" step="0.01" placeholder="票价 play_ticket_price" /></label><label :class="ui.label">状态<input v-model.number="form.play_status" :class="ui.input" type="number" placeholder="状态 play_status" /></label><label :class="ui.label">简介<textarea v-model="form.play_introduction" :class="ui.textarea" placeholder="简介 play_introduction" /></label><label :class="ui.label">剧目封面<input :class="ui.input" type="file" accept="image/*" @change="onImageChange" /></label><div v-if="form.Base64play_image" class="flex items-end gap-4 rounded-2xl bg-white/5 p-4"><img class="h-40 w-28 rounded-xl object-cover ring-1 ring-cyan-400/15" :src="imageSrc(form.Base64play_image)" alt="封面预览" /><button type="button" :class="ui.dangerIconBtn" @click="clearImage"><Icon icon="solar:trash-bin-trash-bold-duotone" />清除图片</button></div><div class="mt-2 flex justify-end gap-3"><DialogClose :class="ui.btnSoft" type="button">取消</DialogClose><button :class="ui.btn"><Icon icon="solar:diskette-bold-duotone" />保存</button></div></form></DialogContent></DialogPortal></DialogRoot>
    <ConfirmDialog v-model:open="confirmOpen" :message="confirmMessage" @confirm="confirmRemove" />
  </section>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { Icon } from '@iconify/vue'
import { DialogClose, DialogContent, DialogOverlay, DialogPortal, DialogRoot, DialogTitle } from 'radix-vue'
import ConfirmDialog from '../components/ConfirmDialog.vue'
import { playApi } from '../api/ttms'
import { ui } from '../config/ui'
const rows = ref([]), keyword = ref(''), message = ref(''), editing = ref(false), confirmOpen = ref(false), confirmMessage = ref(''), pendingRemove = ref(null)
const form = reactive({})
function reset(data = {}) { Object.keys(form).forEach(k => delete form[k]); Object.assign(form, { play_status: 1, Base64play_image: '' }, data) }
function openAdd() { reset(); editing.value = true }
function edit(row) { reset(row); editing.value = true }
function imageSrc(base64) { return base64?.startsWith('data:') ? base64 : `data:image/*;base64,${base64}` }
function onImageChange(event) { const file = event.target.files?.[0]; if (!file) return; if (!file.type.startsWith('image/')) { message.value = '请选择图片文件'; event.target.value = ''; return } const reader = new FileReader(); reader.onload = () => { form.Base64play_image = String(reader.result).split(',')[1] || '' }; reader.readAsDataURL(file) }
function clearImage() { form.Base64play_image = '' }
async function load() { const res = keyword.value ? await playApi.search(keyword.value) : await playApi.list(); rows.value = res.flag ? res.content : []; message.value = res.flag ? '' : res.content }
async function save() { const payload = { ...form, Base64play_image: form.Base64play_image || '' }; const res = form.play_id ? await playApi.update(payload) : await playApi.add(payload); message.value = res.content; if (res.flag) { editing.value = false; await load() } }
function remove(row) { pendingRemove.value = row; confirmMessage.value = `确认删除剧目 ${row.play_name} 吗？`; confirmOpen.value = true }
async function confirmRemove() { if (!pendingRemove.value) return; const res = await playApi.remove(pendingRemove.value.play_id); message.value = res.content; pendingRemove.value = null; await load() }
onMounted(load)
</script>
