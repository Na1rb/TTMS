<template>
  <section :class="ui.page">
    <h1 :class="ui.title">{{ title }}</h1>
    <p class="mt-3 rounded-2xl border border-dashed border-slate-200 bg-slate-50 p-8 text-center text-sm text-slate-500">该模块正在开发中，敬请期待。</p>
  </section>
</template>

<script setup>
import { ui } from '../config/ui'
defineProps({ title: { type: String, default: '功能模块' } })
</script>
