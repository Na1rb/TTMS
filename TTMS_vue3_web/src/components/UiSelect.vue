<template>
  <SelectRoot v-model="model" :disabled="disabled">
    <SelectTrigger :class="[ui.select, 'inline-flex items-center justify-between gap-2', attrs.class]">
      <SelectValue :placeholder="placeholder" />
      <Icon icon="solar:alt-arrow-down-bold-duotone" class="text-lg text-slate-400" />
    </SelectTrigger>
    <SelectPortal>
      <SelectContent class="z-[60] max-h-72 min-w-[var(--radix-select-trigger-width)] overflow-hidden rounded-2xl border border-cyan-400/15 bg-slate-900 p-1 shadow-2xl shadow-slate-950/80">
        <SelectViewport>
          <SelectItem
            v-for="option in options"
            :key="String(option.value)"
            :value="option.value"
            class="relative flex cursor-pointer select-none items-center rounded-xl py-2 pl-9 pr-3 text-sm text-slate-200 outline-none data-[highlighted]:bg-cyan-400/10 data-[highlighted]:text-cyan-200"
          >
            <SelectItemIndicator class="absolute left-3 inline-flex items-center text-cyan-400">
              <Icon icon="solar:check-circle-bold-duotone" />
            </SelectItemIndicator>
            <SelectItemText>{{ option.label }}</SelectItemText>
          </SelectItem>
        </SelectViewport>
      </SelectContent>
    </SelectPortal>
  </SelectRoot>
</template>

<script setup>
import { Icon } from '@iconify/vue'
import { useAttrs } from 'vue'
import { SelectContent, SelectItem, SelectItemIndicator, SelectItemText, SelectPortal, SelectRoot, SelectTrigger, SelectValue, SelectViewport } from 'radix-vue'
import { ui } from '../config/ui'

const attrs = useAttrs()

const model = defineModel({ type: [String, Number] })
defineProps({
  options: { type: Array, default: () => [] },
  placeholder: { type: String, default: '请选择' },
  disabled: { type: Boolean, default: false }
})
</script>
