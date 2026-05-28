<template>
  <section :class="ui.page">
    <div :class="ui.sectionHead"><div><h1 :class="ui.title">未处理订单</h1><p :class="ui.subtitle">查询当前员工未支付或未完成处理的订单，并继续支付、退款或取消。</p></div><button :class="ui.btn" :disabled="loading || !employeeId" @click="loadOrders"><Icon icon="solar:refresh-bold-duotone" />刷新</button></div>
    <div :class="ui.toolbar"><input v-model.number="queryEmployeeId" :class="ui.input" class="max-w-xs" type="number" min="1" placeholder="员工 emp_id" /><button :class="ui.btnSoft" :disabled="loading || !queryEmployeeId" @click="loadOrders"><Icon icon="solar:magnifer-bold-duotone" />查询</button></div>
    <p v-if="message" :class="ui.tip">{{ message }}</p>
    <div v-if="loading" :class="ui.empty">正在加载未处理订单...</div><div v-else-if="!orders.length" :class="ui.empty">暂无未处理订单。</div>
    <div v-else :class="ui.tableWrap"><table :class="ui.table"><thead><tr><th :class="ui.th">订单ID</th><th :class="ui.th">员工ID</th><th :class="ui.th">订单时间</th><th :class="ui.th">金额</th><th :class="ui.th">类型</th><th :class="ui.th">状态</th><th :class="ui.th">操作</th></tr></thead><tbody class="divide-y divide-cyan-400/10"><tr v-for="order in orders" :key="order.sale_ID" class="hover:bg-white/5"><td :class="ui.td">{{ order.sale_ID }}</td><td :class="ui.td">{{ order.emp_id }}</td><td :class="ui.td">{{ formatTime(order.sale_time) }}</td><td :class="ui.td" class="font-semibold">￥{{ formatMoney(order.sale_payment) }}</td><td :class="ui.td"><span class="rounded-full px-3 py-1 text-xs font-semibold text-white" :class="Number(order.sale_type) === -1 ? 'bg-amber-500' : 'bg-indigo-600'">{{ typeText(order.sale_type) }}</span></td><td :class="ui.td">{{ statusText(order.sale_status) }}</td><td :class="ui.td"><div class="flex flex-col sm:flex-row gap-1.5 sm:gap-2"><button :class="ui.iconBtn" :disabled="operatingId === order.sale_ID" @click="handlePay(order)"><Icon icon="solar:card-recive-bold-duotone" />{{ Number(order.sale_type) === -1 ? '确认退款' : '确认支付' }}</button><button :class="ui.dangerIconBtn" :disabled="operatingId === order.sale_ID" @click="handleCancel(order)"><Icon icon="solar:close-circle-bold-duotone" />取消订单</button></div></td></tr></tbody></table></div>
    <ConfirmDialog v-model:open="confirmOpen" :message="confirmMessage" @confirm="confirmCancel" />
  </section>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { Icon } from '@iconify/vue'
import { orderApi } from '../api/ttms'
import ConfirmDialog from '../components/ConfirmDialog.vue'
import { useUserStore } from '../stores/user'
import { ui } from '../config/ui'
const userStore = useUserStore()
const orders = ref([]), message = ref(''), loading = ref(false), operatingId = ref(null), queryEmployeeId = ref(userStore.user?.emp_id || ''), confirmOpen = ref(false), confirmMessage = ref(''), pendingCancel = ref(null)
const employeeId = computed(() => queryEmployeeId.value || userStore.user?.emp_id)
function typeText(type) { return Number(type) === -1 ? '退票/退款' : '售票/支付' }
function statusText(status) { const value = Number(status); if (value === 1) return '已完成'; if (value === -1) return '未处理'; return '待支付' }
function formatMoney(value) { return Number(value || 0).toFixed(2) }
function formatTime(value) { if (!value) return '-'; const date = new Date(value); return Number.isNaN(date.getTime()) ? String(value) : date.toLocaleString() }
async function loadOrders() { if (!employeeId.value) { message.value = '请先登录或输入员工 emp_id'; orders.value = []; return } loading.value = true; message.value = ''; try { const res = await orderApi.unfinishedByEmployeeId(employeeId.value); orders.value = res.flag ? res.content || [] : []; message.value = res.flag ? '' : res.content } catch (e) { orders.value = []; message.value = '未处理订单查询失败，请确认后端服务已启动' } finally { loading.value = false } }
async function handlePay(order) { operatingId.value = order.sale_ID; message.value = ''; try { const flag = Number(order.sale_type) === -1 ? -1 : 1; const res = await orderApi.pay(order.sale_ID, flag); message.value = res.content; if (res.flag) await loadOrders() } catch (e) { message.value = '订单处理失败，请稍后重试' } finally { operatingId.value = null } }
function handleCancel(order) { pendingCancel.value = order; confirmMessage.value = `确认取消订单 ${order.sale_ID} 吗？`; confirmOpen.value = true }
async function confirmCancel() { if (!pendingCancel.value) return; const order = pendingCancel.value; operatingId.value = order.sale_ID; message.value = ''; try { const flag = Number(order.sale_type) === -1 ? -1 : 1; const res = await orderApi.cancel(order.sale_ID, flag); message.value = res.content; pendingCancel.value = null; if (res.flag) await loadOrders() } catch (e) { message.value = '取消订单失败，请稍后重试' } finally { operatingId.value = null } }
onMounted(loadOrders)
</script>
