<template>
  <div class="h-full flex flex-col space-y-4">
    <TeacherClassList
      :classes="allClasses"
      :pending="pending"
      :error="error"
      v-model:search-query="searchQuery"
      v-model:status-filter="statusFilter"
      @create-class="showCreateModal = true"
      @refresh="refresh"
    />
    <CreateClassModal
      :is-open="showCreateModal"
      @close="showCreateModal = false"
      @created="handleClassCreated"
    />
  </div>
</template>

<script setup lang="ts">
import TeacherClassList from '../../../components/teacher/classes/TeacherClassList.vue';
import CreateClassModal from '../../../components/teacher/CreateClassModal.vue';

definePageMeta({
  layout: 'teacher',
  middleware: 'auth',
});

const { fetchTeacherClasses } = useTeacherClassApi();

const showCreateModal = ref(false);
const searchQuery = ref('');
const statusFilter = ref('');

const debouncedSearchQuery = ref('');
let searchTimeout: NodeJS.Timeout;
watch(searchQuery, () => {
  clearTimeout(searchTimeout);
  searchTimeout = setTimeout(() => {
    debouncedSearchQuery.value = searchQuery.value;
  }, 500);
});

const {
  data: classesData,
  pending,
  error,
  refresh,
} = await useAsyncData(
  'teacher-classes',
  async () => {
    try {
      const params: any = {};
      if (statusFilter.value) params.status = statusFilter.value;
      if (debouncedSearchQuery.value)
        params.search = debouncedSearchQuery.value;

      const response = await fetchTeacherClasses(params);
      return response.data || { classes: [], pagination: null };
    } catch (err) {
      console.error('Error loading teacher classes:', err);
      return { classes: [], pagination: null };
    }
  },
  {
    watch: [statusFilter, debouncedSearchQuery],
  }
);

const allClasses = computed(() => classesData.value?.classes || []);

const handleClassCreated = () => {
  showCreateModal.value = false;
  refresh();
};
</script>
