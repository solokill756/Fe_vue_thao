<template>
  <div class="animate-fade-in">
    <TuitionManager :tuition-data="tuitionData" @reload="loadTuitionData" />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import type { TuitionData } from '@/types/tuition'
import { useTuitionApi } from '@/composables/useTuitionApi'

definePageMeta({
  layout: 'student',
})

const { getTuitionDashboard } = useTuitionApi()

const tuitionData = ref<TuitionData>({
  total_debt: 0,
  next_due_date: 'N/A',
  wallet_balance: 0,
  pending_invoices: [],
  history: []
})

const loadTuitionData = async () => {
  try {
    const response = await getTuitionDashboard()
    if (response.data) {
      tuitionData.value = response.data
    }
  } catch (error) {
    console.error('Error loading tuition data:', error)
  }
}

onMounted(() => {
  loadTuitionData()
})
</script>
