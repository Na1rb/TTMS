<template>
  <DialogRoot v-model:open="open">
    <DialogPortal>
      <DialogOverlay :class="ui.dialogOverlay" />
      <DialogContent :class="ui.dialogSmall">
        <DialogTitle class="flex items-center gap-2 text-xl font-bold text-white">
          <Icon icon="solar:danger-triangle-bold-duotone" class="text-2xl text-amber-400" />{{ title }}
        </DialogTitle>
        <DialogDescription class="mt-3 text-sm leading-6 text-slate-300">{{ message }}</DialogDescription>
        <div class="mt-6 flex justify-end gap-3">
          <DialogClose :class="ui.btnSoft">取消</DialogClose>
          <button :class="ui.btnDanger" @click="confirm"><Icon icon="solar:check-circle-bold-duotone" />确认</button>
        </div>
      </DialogContent>
    </DialogPortal>
  </DialogRoot>
</template>

<script setup>
import { Icon } from '@iconify/vue'
import { DialogClose, DialogContent, DialogDescription, DialogOverlay, DialogPortal, DialogRoot, DialogTitle } from 'radix-vue'
import { ui } from '../config/ui'

const open = defineModel('open', { type: Boolean, default: false })
defineProps({ title: { type: String, default: '确认操作' }, message: { type: String, default: '' } })
const emit = defineEmits(['confirm'])
function confirm() { open.value = false; emit('confirm') }
</script>
