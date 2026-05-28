<template>
  <section :class="ui.page">
    <div :class="ui.sectionHead"><h1 :class="ui.title">字典管理</h1><button :class="ui.btn" @click="openAddType"><Icon icon="solar:add-square-bold-duotone" />新增字典类型</button></div>
    <div :class="ui.toolbar"><input v-model="keyword" :class="ui.input" class="max-w-xs" placeholder="按字典名称搜索" @keyup.enter="load" /><button :class="ui.btnSoft" @click="load"><Icon icon="solar:magnifer-bold-duotone" />查询</button><button :class="ui.btnSoft" type="button" @click="resetSearch"><Icon icon="solar:restart-bold-duotone" />重置</button></div>
    <p v-if="message" :class="ui.tip">{{ message }}</p>

    <div class="grid gap-5 xl:grid-cols-[320px_1fr]">
      <aside class="rounded-3xl border border-cyan-400/15 bg-white/5 p-4">
        <div class="mb-4 flex items-center justify-between"><h2 class="font-bold text-white">字典类型</h2><span class="rounded-full bg-slate-800 px-3 py-1 text-xs font-semibold text-slate-300">{{ typeRows.length }} 项</span></div>
        <div class="grid gap-3">
          <button v-for="type in typeRows" :key="type.dict_id" class="flex items-center justify-between gap-3 rounded-2xl border p-3 text-left transition" :class="selectedTypeId === type.dict_id ? 'border-cyan-400/30 bg-cyan-400/10 text-white' : 'border-cyan-400/15 bg-slate-950/60 hover:border-cyan-400/20'" @click="selectType(type)">
            <span><strong class="block text-sm">{{ type.dict_name }}</strong><small class="mt-1 block text-xs text-slate-400">值：{{ type.dict_value || '-' }}</small></span>
            <span class="flex shrink-0 gap-1" @click.stop><button :class="ui.iconBtn" type="button" @click="editType(type)"><Icon icon="solar:pen-bold-duotone" /></button><button :class="ui.dangerIconBtn" type="button" @click="removeDict(type, '类型')"><Icon icon="solar:trash-bin-trash-bold-duotone" /></button></span>
          </button>
        </div>
        <p v-if="!typeRows.length" :class="ui.empty">暂无字典类型</p>
      </aside>

      <main class="rounded-3xl border border-cyan-400/15 bg-slate-950/60 p-4">
        <div class="mb-4 flex items-center justify-between gap-3"><h2 class="font-bold text-white">{{ selectedType ? selectedType.dict_name : '字典项' }}</h2><button :class="ui.btn" :disabled="!selectedType" @click="openAddItem"><Icon icon="solar:add-circle-bold-duotone" />新增字典项</button></div>
        <div :class="ui.tableWrap"><table :class="ui.table"><thead><tr><th :class="ui.th">ID</th><th :class="ui.th">序号</th><th :class="ui.th">名称</th><th :class="ui.th">值</th><th :class="ui.th">父类型ID</th><th :class="ui.th">操作</th></tr></thead><tbody class="divide-y divide-cyan-400/10"><tr v-for="item in itemRows" :key="item.dict_id" class="hover:bg-white/5"><td :class="ui.td">{{ item.dict_id }}</td><td :class="ui.td">{{ item.dict_index }}</td><td :class="ui.td" class="font-semibold text-white">{{ item.dict_name }}</td><td :class="ui.td">{{ item.dict_value }}</td><td :class="ui.td">{{ item.dict_parent_id }}</td><td :class="ui.td"><div class="flex gap-2"><button :class="ui.iconBtn" @click="editItem(item)"><Icon icon="solar:pen-bold-duotone" />编辑</button><button :class="ui.dangerIconBtn" @click="removeDict(item, '字典项')"><Icon icon="solar:trash-bin-trash-bold-duotone" />删除</button></div></td></tr></tbody></table></div>
        <p v-if="selectedType && !itemRows.length" :class="ui.empty" class="mt-4">当前类型下暂无字典项</p><p v-if="!selectedType" :class="ui.empty" class="mt-4">请先选择左侧字典类型</p>
      </main>
    </div>

    <DialogRoot v-model:open="editing"><DialogPortal><DialogOverlay :class="ui.dialogOverlay" /><DialogContent :class="ui.dialogContent"><DialogTitle :class="ui.dialogTitle">{{ form.dict_id ? '编辑' : '新增' }}{{ editingKind === 'type' ? '字典类型' : '字典项' }}</DialogTitle><form :class="ui.formGrid" @submit.prevent="save"><label :class="ui.label">所属类型<UiSelect v-model="form.dict_parent_id" :options="parentOptions" :disabled="editingKind === 'type'" /></label><label :class="ui.label">名称<input v-model="form.dict_name" :class="ui.input" placeholder="名称 dict_name" required /></label><label :class="ui.label">值<input v-model="form.dict_value" :class="ui.input" placeholder="值 dict_value" /></label><label v-if="form.dict_id" :class="ui.label">序号<input v-model.number="form.dict_index" :class="ui.input" type="number" placeholder="序号 dict_index" /></label><div class="mt-2 flex justify-end gap-3"><DialogClose :class="ui.btnSoft" type="button">取消</DialogClose><button :class="ui.btn"><Icon icon="solar:diskette-bold-duotone" />保存</button></div></form></DialogContent></DialogPortal></DialogRoot>
    <ConfirmDialog v-model:open="confirmOpen" :message="confirmMessage" @confirm="confirmRemove" />
  </section>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { Icon } from '@iconify/vue'
import { DialogClose, DialogContent, DialogOverlay, DialogPortal, DialogRoot, DialogTitle } from 'radix-vue'
import ConfirmDialog from '../components/ConfirmDialog.vue'
import UiSelect from '../components/UiSelect.vue'
import { dictionaryApi } from '../api/ttms'
import { ui } from '../config/ui'
const rows = ref([]), keyword = ref(''), message = ref(''), editing = ref(false), editingKind = ref('item'), selectedTypeId = ref(null), confirmOpen = ref(false), confirmMessage = ref(''), pendingRemove = ref(null)
const form = reactive({})
const root = computed(() => rows.value.find(item => item.dict_name === '根') || rows.value.find(item => item.dict_id === item.dict_parent_id))
const rootId = computed(() => root.value?.dict_id || null)
const typeRows = computed(() => { const list = rootId.value ? rows.value.filter(item => item.dict_parent_id === rootId.value && item.dict_id !== rootId.value) : rows.value.filter(item => item.dict_parent_id === null || item.dict_parent_id === undefined || item.dict_parent_id === 0); return list.sort((a, b) => (a.dict_index || 0) - (b.dict_index || 0)) })
const selectedType = computed(() => typeRows.value.find(item => item.dict_id === selectedTypeId.value))
const itemRows = computed(() => selectedTypeId.value ? rows.value.filter(item => item.dict_parent_id === selectedTypeId.value).sort((a, b) => (a.dict_index || 0) - (b.dict_index || 0)) : [])
const parentOptions = computed(() => editingKind.value === 'type' ? [{ value: rootId.value, label: '根' }] : typeRows.value.map(type => ({ value: type.dict_id, label: type.dict_name })))
function reset(data = {}) { Object.keys(form).forEach(key => delete form[key]); Object.assign(form, data) }
function selectType(type) { selectedTypeId.value = type.dict_id; editing.value = false }
function openAddType() { editingKind.value = 'type'; reset({ dict_parent_id: rootId.value, dict_name: '', dict_value: '' }); editing.value = true }
function openAddItem() { if (!selectedType.value) { message.value = '请先选择字典类型'; return } editingKind.value = 'item'; reset({ dict_parent_id: selectedType.value.dict_id, dict_name: '', dict_value: '' }); editing.value = true }
function editType(type) { editingKind.value = 'type'; reset(type); editing.value = true }
function editItem(item) { editingKind.value = 'item'; reset(item); editing.value = true }
async function load() { const res = keyword.value ? await dictionaryApi.search(keyword.value) : await dictionaryApi.list(); rows.value = res.flag ? res.content : []; message.value = res.flag ? '' : res.content; if (!selectedTypeId.value || !typeRows.value.some(item => item.dict_id === selectedTypeId.value)) selectedTypeId.value = typeRows.value[0]?.dict_id || null }
async function resetSearch() { keyword.value = ''; await load() }
async function save() { const payload = { ...form }; const res = payload.dict_id ? await dictionaryApi.update(payload) : await dictionaryApi.add(payload); message.value = res.content; if (res.flag) { editing.value = false; await load(); if (editingKind.value === 'type' && payload.dict_id) selectedTypeId.value = payload.dict_id } }
function removeDict(row, label) { pendingRemove.value = row; confirmMessage.value = `确认删除${label} ${row.dict_name} 吗？非叶子节点无法删除。`; confirmOpen.value = true }
async function confirmRemove() { if (!pendingRemove.value) return; const id = pendingRemove.value.dict_id; const res = await dictionaryApi.remove(id); message.value = res.content; if (selectedTypeId.value === id) selectedTypeId.value = null; pendingRemove.value = null; await load() }
onMounted(load)
</script>
