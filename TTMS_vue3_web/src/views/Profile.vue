<template>
  <section :class="ui.page">
    <div :class="ui.sectionHead">
      <h1 :class="ui.title">个人中心</h1>
      <span class="inline-flex items-center gap-2 rounded-full border border-cyan-400/15 bg-white/5 px-4 py-2 text-sm font-bold text-cyan-100"><Icon icon="solar:user-id-bold-duotone" />{{ userStore.roleName }}</span>
    </div>
    <p v-if="message" :class="ui.tip">{{ message }}</p>
    <div class="grid items-start gap-5 xl:grid-cols-2">
      <section class="rounded-3xl border border-cyan-400/15 bg-white/5 p-5 backdrop-blur">
        <h2 class="mb-4 text-lg font-bold text-white">当前用户信息</h2>
        <dl class="grid grid-cols-[96px_1fr] gap-x-4 gap-y-3 text-sm"><template v-for="item in infoItems" :key="item.label"><dt class="font-bold text-slate-400">{{ item.label }}</dt><dd class="break-all text-slate-200">{{ item.value || '-' }}</dd></template></dl>
      </section>
      <form class="grid gap-4 rounded-3xl border border-cyan-400/15 bg-white/5 p-5 backdrop-blur" @submit.prevent="saveProfile">
        <h2 class="text-lg font-bold text-white">修改基础资料</h2>
        <label :class="ui.label">工号<input v-model.trim="profileForm.emp_no" :class="ui.input" placeholder="请输入工号" /></label>
        <label :class="ui.label">姓名<input v-model.trim="profileForm.emp_name" :class="ui.input" placeholder="请输入姓名" /></label>
        <label :class="ui.label">电话<input v-model.trim="profileForm.emp_tel_num" :class="ui.input" placeholder="请输入电话" /></label>
        <label :class="ui.label">邮箱<input v-model.trim="profileForm.emp_email" :class="ui.input" placeholder="请输入邮箱" /></label>
        <label :class="ui.label">地址<input v-model.trim="profileForm.emp_addr" :class="ui.input" placeholder="请输入地址" /></label>
        <button :class="ui.btn" :disabled="profileSaving"><Icon :icon="profileSaving ? 'svg-spinners:180-ring' : 'solar:diskette-bold-duotone'" />{{ profileSaving ? '保存中...' : '保存资料' }}</button>
      </form>
    </div>
    <form class="mt-5 grid gap-4 rounded-3xl border border-cyan-400/15 bg-white/5 p-5 backdrop-blur" @submit.prevent="changePassword">
      <h2 class="text-lg font-bold text-white">修改密码</h2>
      <div class="grid gap-4 lg:grid-cols-3">
        <label :class="ui.label">原密码<input v-model="passwordForm.oldPassword" :class="ui.input" type="password" autocomplete="current-password" placeholder="请输入原密码" /></label>
        <label :class="ui.label">新密码<input v-model="passwordForm.newPassword" :class="ui.input" type="password" autocomplete="new-password" placeholder="请输入新密码" /></label>
        <label :class="ui.label">确认新密码<input v-model="passwordForm.confirmPassword" :class="ui.input" type="password" autocomplete="new-password" placeholder="请再次输入新密码" /></label>
      </div>
      <button :class="ui.btn" class="w-fit" :disabled="passwordSaving"><Icon :icon="passwordSaving ? 'svg-spinners:180-ring' : 'solar:lock-password-bold-duotone'" />{{ passwordSaving ? '修改中...' : '修改密码' }}</button>
    </form>
  </section>
</template>

<script setup>
import { computed, reactive, ref, watchEffect } from 'vue'
import { Icon } from '@iconify/vue'
import { employeeApi, profileApi } from '../api/ttms'
import { useUserStore } from '../stores/user'
import { ui } from '../config/ui'

const userStore = useUserStore()
const currentUser = computed(() => userStore.user || {})
const message = ref('')
const profileSaving = ref(false)
const passwordSaving = ref(false)
const profileForm = reactive({ emp_id: '', emp_no: '', emp_type: '', emp_name: '', emp_tel_num: '', emp_email: '', emp_addr: '' })
const passwordForm = reactive({ oldPassword: '', newPassword: '', confirmPassword: '' })
const infoItems = computed(() => [
  { label: '用户ID', value: currentUser.value.emp_id }, { label: '工号', value: currentUser.value.emp_no },
  { label: '姓名', value: currentUser.value.emp_name }, { label: '角色', value: userStore.roleName },
  { label: '电话', value: currentUser.value.emp_tel_num }, { label: '邮箱', value: currentUser.value.emp_email },
  { label: '地址', value: currentUser.value.emp_addr }
])
watchEffect(() => Object.assign(profileForm, { emp_id: currentUser.value.emp_id || '', emp_no: currentUser.value.emp_no || '', emp_type: currentUser.value.emp_type || '', emp_name: currentUser.value.emp_name || '', emp_tel_num: currentUser.value.emp_tel_num || '', emp_email: currentUser.value.emp_email || '', emp_addr: currentUser.value.emp_addr || '' }))
function resetPasswordForm() { Object.assign(passwordForm, { oldPassword: '', newPassword: '', confirmPassword: '' }) }
function buildUpdatedUser() { return { ...currentUser.value, ...profileForm } }
async function saveProfile() { message.value = ''; if (!profileForm.emp_id) return message.value = '未获取到当前用户信息，请重新登录'; if (!profileForm.emp_no || !profileForm.emp_name) return message.value = '工号和姓名不能为空'; profileSaving.value = true; try { const payload = buildUpdatedUser(); const res = await employeeApi.update(payload); message.value = res.content || (res.flag ? '修改成功' : '修改失败'); if (res.flag) userStore.setUser(payload) } catch { message.value = '资料保存失败，请检查网络连接' } finally { profileSaving.value = false } }
async function changePassword() { message.value = ''; if (!currentUser.value.emp_id) return message.value = '未获取到当前用户信息，请重新登录'; if (!passwordForm.oldPassword || !passwordForm.newPassword || !passwordForm.confirmPassword) return message.value = '请完整填写密码信息'; if (passwordForm.newPassword !== passwordForm.confirmPassword) return message.value = '两次输入的新密码不一致'; passwordSaving.value = true; try { const res = await profileApi.updatePassword({ emp_id: currentUser.value.emp_id, oldPassword: passwordForm.oldPassword, newPassword: passwordForm.newPassword }); message.value = res.content || (res.flag ? '修改成功' : '修改失败'); if (res.flag) resetPasswordForm() } catch { message.value = '密码修改失败，请检查网络连接' } finally { passwordSaving.value = false } }
</script>
