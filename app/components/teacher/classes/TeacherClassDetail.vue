<template>
  <div
    class="h-full flex flex-col bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden"
  >
    <!-- Detail Header -->
    <div
      class="p-6 border-b border-slate-200 bg-slate-50 flex flex-col md:flex-row justify-between items-start md:items-center gap-4"
    >
      <div class="flex items-center gap-4">
        <button
          @click="navigateTo('/teacher/classes')"
          class="w-10 h-10 rounded-full bg-white border border-slate-200 flex items-center justify-center text-slate-500 hover:text-blue-600 hover:border-blue-300 transition-all shadow-sm"
        >
          <i class="fa-solid fa-arrow-left"></i>
        </button>
        <div>
          <h2 class="text-2xl font-bold text-slate-800 flex items-center gap-2">
            {{ classDetail.name }}
            <span
              class="text-xs bg-green-100 text-green-700 px-2 py-1 rounded-full font-bold uppercase"
              >{{ classDetail.status }}</span
            >
          </h2>
          <p class="text-sm text-slate-500 mt-1">
            {{ $t('teacher.classes.detail.classCode') }}:
            {{ classDetail.code }} • {{ $t('teacher.classes.detail.grade') }}:
            {{ classDetail.grade }}
          </p>
        </div>
      </div>
      <div
        class="flex gap-2 bg-white p-1 rounded-lg border border-slate-200 shadow-sm"
      >
        <button
          @click="activeTab = 'students'"
          :class="[
            'px-4 py-2 rounded-md text-sm font-bold transition-all',
            activeTab === 'students'
              ? 'bg-blue-600 text-white shadow'
              : 'text-slate-600 hover:bg-slate-50',
          ]"
        >
          {{ $t('teacher.classes.detail.tabs.students') }}
        </button>
        <button
          @click="activeTab = 'schedule'"
          :class="[
            'px-4 py-2 rounded-md text-sm font-bold transition-all',
            activeTab === 'schedule'
              ? 'bg-blue-600 text-white shadow'
              : 'text-slate-600 hover:bg-slate-50',
          ]"
        >
          {{ $t('teacher.classes.detail.tabs.schedule') }}
        </button>
        <button
          @click="activeTab = 'settings'"
          :class="[
            'px-4 py-2 rounded-md text-sm font-bold transition-all',
            activeTab === 'settings'
              ? 'bg-blue-600 text-white shadow'
              : 'text-slate-600 hover:bg-slate-50',
          ]"
        >
          {{ $t('teacher.classes.detail.tabs.settings') }}
        </button>
      </div>
    </div>

    <!-- Detail Content -->
    <div class="flex-1 overflow-y-auto p-6 bg-white custom-scroll">
      <!-- TAB: STUDENTS -->
      <TeacherClassStudentsTab
        v-if="activeTab === 'students'"
        :class-detail="classDetail"
        :pending-enrollments="pendingEnrollments"
        :pending-leave-requests="pendingLeaveRequests"
        @refresh="emit('refresh')"
        @refresh-pending-requests="refreshPendingRequests"
      />

      <!-- TAB: SCHEDULE -->
      <TeacherClassScheduleTab
        v-else-if="activeTab === 'schedule'"
        :class-detail="classDetail"
        :schedule-data="scheduleData"
        :loading-schedule="loadingSchedule"
        @refresh-schedule="refreshSchedule"
      />

      <!-- TAB: SETTINGS -->
      <TeacherClassSettingsTab
        v-else-if="activeTab === 'settings'"
        :class-detail="classDetail"
        @refresh="emit('refresh')"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import type { TeacherClassDetail } from '../../../composables/useTeacherClassApi';
import { useTeacherClassApi } from '../../../composables/useTeacherClassApi';
import { getErrorMessage } from '../../../utils/errorHandler';
import { useToast } from 'vue-toastification';
import { useI18n } from 'vue-i18n';
import TeacherClassStudentsTab from './class-detail/TeacherClassStudentsTab.vue';
import TeacherClassScheduleTab from './class-detail/TeacherClassScheduleTab.vue';
import TeacherClassSettingsTab from './class-detail/TeacherClassSettingsTab.vue';

const emit = defineEmits<{
  refresh: [];
}>();

const props = defineProps<{
  classDetail: TeacherClassDetail;
  initialTab?: 'students' | 'schedule' | 'settings';
}>();

const route = useRoute();
const { fetchPendingRequests, fetchClassSchedule } = useTeacherClassApi();
const { t } = useI18n();
const toast = useToast()
const text = ref('');

const activeTab = ref<'students' | 'schedule' | 'settings'>(
  props.initialTab || 'students'
);

const { data: pendingRequestsData, refresh: refreshPendingRequests } =
  useAsyncData(
    `pending-requests-${props.classDetail.id}`,
    async () => {
      const response = await fetchPendingRequests(props.classDetail.id);
      return response.data || { enrollments: [], leave_requests: [] };
    },
    {
      default: () => ({ enrollments: [], leave_requests: [] }),
      watch: [() => props.classDetail.id],
    }
  );


const pendingEnrollments = computed(() => {
  return pendingRequestsData.value?.enrollments || [];
});

const pendingLeaveRequests = computed(() => {
  return pendingRequestsData.value?.leave_requests || [];
});

// Schedule state
const {
  data: scheduleData,
  pending: loadingSchedule,
  refresh: refreshSchedule,
} = useAsyncData(
  `class-schedule-${props.classDetail.id}`,
  async () => {
    const response = await fetchClassSchedule(props.classDetail.id);
    return response.data || { fixed_schedule: {}, upcoming_sessions: [] };
  },
  {
    default: () => ({ fixed_schedule: {}, upcoming_sessions: [] }),
    watch: [() => props.classDetail.id],
  }
);


// Refresh data when tab changes
watch(
  () => [activeTab.value, props.classDetail.id],
  () => {
    if (activeTab.value === 'students' && props.classDetail.id) {
      refreshPendingRequests();
    } else if (activeTab.value === 'schedule' && props.classDetail.id) {
      refreshSchedule();
    }
  },
  { immediate: true }
);


</script>

<style scoped>
.custom-scroll {
  scrollbar-width: thin;
  scrollbar-color: #cbd5e1 #f1f1f1;
}

.custom-scroll::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}

.custom-scroll::-webkit-scrollbar-track {
  background: #f1f1f1;
}

.custom-scroll::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 3px;
}

.custom-scroll::-webkit-scrollbar-thumb:hover {
  background: #94a3b8;
}
</style>
