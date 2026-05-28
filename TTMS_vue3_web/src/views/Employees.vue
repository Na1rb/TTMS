<template>
  <section :class="ui.page">
    <div :class="ui.sectionHead">
      <h1 :class="ui.title">用户管理</h1>
      <button :class="ui.btn" @click="openAdd"><Icon icon="solar:user-plus-bold-duotone" />新增用户</button>
    </div>
    <div :class="ui.toolbar"><input v-model="keyword" :class="ui.input" class="max-w-xs" placeholder="按用户名搜索" @keyup.enter="load" /><button :class="ui.btnSoft" @click="load"><Icon icon="solar:magnifer-bold-duotone" />查询</button></div>
    <p v-if="message" :class="ui.tip">{{ message }}</p>
    <div :class="ui.tableWrap"><table :class="ui.table"><thead><tr><th :class="ui.th">Staff ID</th><th :class="ui.th">姓名</th><th :class="ui.th">角色</th><th :class="ui.th">电话</th><th :class="ui.th">邮箱</th><th :class="ui.th">操作</th></tr></thead><tbody class="divide-y divide-cyan-400/10"><tr v-for="emp in rows" :key="emp.emp_id" class="hover:bg-white/5"><td :class="ui.td">{{ emp.emp_no }}</td><td :class="ui.td">{{ emp.emp_name }}</td><td :class="ui.td"><span class="rounded-full bg-cyan-400/10 px-3 py-1 text-xs font-semibold text-cyan-200">{{ role(emp.emp_type) }}</span></td><td :class="ui.td">{{ emp.emp_tel_num }}</td><td :class="ui.td">{{ emp.emp_email }}</td><td :class="ui.td"><div class="flex gap-2"><button :class="ui.iconBtn" @click="edit(emp)"><Icon icon="solar:pen-bold-duotone" />编辑</button><button :class="ui.dangerIconBtn" @click="remove(emp)"><Icon icon="solar:trash-bin-trash-bold-duotone" />删除</button></div></td></tr></tbody></table></div>

    <DialogRoot v-model:open="editing">
      <DialogPortal><DialogOverlay :class="ui.dialogOverlay" /><DialogContent :class="ui.dialogContent"><DialogTitle :class="ui.dialogTitle">{{ form.emp_id ? '编辑用户' : '新增用户' }}</DialogTitle>
        <form :class="ui.formGrid" @submit.prevent="save">
          <label :class="ui.label">工号<input v-model="form.emp_no" :class="ui.input" placeholder="工号 emp_no" /></label>
          <label :class="ui.label">角色<UiSelect v-model="form.emp_type" :options="roleOptions" /></label>
          <label :class="ui.label">姓名<input v-model="form.emp_name" :class="ui.input" placeholder="姓名 emp_name" /></label>
          <label v-if="!form.emp_id" :class="ui.label">密码<input v-model="form.emp_passwd" :class="ui.input" type="password" placeholder="密码 emp_passwd" /></label>
          <label :class="ui.label">电话<input v-model="form.emp_tel_num" :class="ui.input" placeholder="电话 emp_tel_num" /></label>
          <label :class="ui.label">地址<input v-model="form.emp_addr" :class="ui.input" placeholder="地址 emp_addr" /></label>
          <label :class="ui.label">邮箱<input v-model="form.emp_email" :class="ui.input" placeholder="邮箱 emp_email" /></label>
          <div class="mt-2 flex justify-end gap-3"><DialogClose :class="ui.btnSoft" type="button">取消</DialogClose><button :class="ui.btn"><Icon icon="solar:diskette-bold-duotone" />保存</button></div>
        </form>
      </DialogContent></DialogPortal>
    </DialogRoot>
    <ConfirmDialog v-model:open="confirmOpen" :message="confirmMessage" @confirm="confirmRemove" />
  </section>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { Icon } from '@iconify/vue'
import { DialogClose, DialogContent, DialogOverlay, DialogPortal, DialogRoot, DialogTitle } from 'radix-vue'
import ConfirmDialog from '../components/ConfirmDialog.vue'
import UiSelect from '../components/UiSelect.vue'
import { employeeApi } from '../api/ttms'
import { ui } from '../config/ui'

const rows = ref([])
const keyword = ref('')
const message = ref('')
const editing = ref(false)
const confirmOpen = ref(false)
const pendingRemove = ref(null)
const confirmMessage = ref('')
const form = reactive({})
const roleOptions = [
  { value: 1, label: '经理' },
  { value: 2, label: '售票员' },
  { value: 3, label: '管理员' },
  { value: 4, label: 'VIP会员' },
  { value: 5, label: '普通用户' }
]
const role = (v) => roleOptions.find(item => Number(item.value) === Number(v))?.label || v
function reset(data = {}) { Object.keys(form).forEach(k => delete form[k]); Object.assign(form, { emp_type: 2 }, data) }
function openAdd() { reset(); editing.value = true }
function edit(emp) { reset(emp); editing.value = true }
async function load() { const res = keyword.value ? await employeeApi.search(keyword.value) : await employeeApi.list(); rows.value = res.flag ? res.content : []; message.value = res.flag ? '' : res.content }
async function save() { const res = form.emp_id ? await employeeApi.update(form) : await employeeApi.add(form); message.value = res.content; if (res.flag) { editing.value = false; await load() } }
function remove(emp) { pendingRemove.value = emp; confirmMessage.value = `确认删除用户 ${emp.emp_name} 吗？`; confirmOpen.value = true }
async function confirmRemove() { if (!pendingRemove.value) return; const res = await employeeApi.remove(pendingRemove.value.emp_id); message.value = res.content; pendingRemove.value = null; await load() }
onMounted(load)
</script>
