<template>
  <div class="animate-fade-in">
    <student-tuition-manager
      :tuition-invoices="tuitionInvoices?.invoices || []"
      :pending="pending"
      :error="error"
      :pagination="tuitionInvoices?.pagination"
      @refresh="refresh"
      @update:page="currentPage = $event"
      @update:per-page="perPage = $event"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue';

definePageMeta({
  layout: 'student',
});

const { getTuitionInvoices } = useTuitionApi();
const perPage = ref(10);
const currentPage = ref(1);
const {
  data: tuitionInvoices,
  pending,
  error,
  refresh,
} = useAsyncData(
  'tuitionInvoices',
  async () => {
    try {
      const response = await getTuitionInvoices({
        page: currentPage.value,
        per_page: perPage.value,
      });
      return response.data;
    } catch (err) {
      console.error('Error fetching tuition invoices:', err);
      return {
        invoices: [],
        pagination: {
          current_page: 1,
          per_page: 10,
          total_count: 0,
          total_pages: 0,
        },
      };
    }
  },
  {
    watch: [perPage, currentPage],
  }
);

// Reset to page 1 if current page is empty after refresh
watch(
  () => tuitionInvoices.value?.invoices,
  (invoices) => {
    const pagination = tuitionInvoices.value?.pagination;
    if (
      invoices &&
      invoices.length === 0 &&
      pagination &&
      pagination.current_page > 1 &&
      pagination.total_count > 0
    ) {
      currentPage.value = 1;
    }
  }
);
</script>
