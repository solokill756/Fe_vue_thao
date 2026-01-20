<template>
  <div class="h-full flex flex-col space-y-6">
    <!-- Toolbar -->
    <StudentClassesToolbar
      :view-mode="viewMode"
      @switch-view="viewMode = $event"
      @back="viewMode = 'list'"
    />

    <!-- View 1: List View -->
    <div v-if="viewMode === 'list'" class="flex flex-col gap-6">
      <StudentClassesListView
        :classes="classes"
        @request-leave="handleRequestLeave"
        @makeup-class="handleMakeupClass"
        @add-new="viewMode = 'register'"
        @view-detail="handleViewDetail"
      />
      <!-- Pagination for My Classes -->
      <CommonPagination
        v-if="myClassesTotalItemsComputed > myClassesPerPage"
        :current-page="myClassesPage"
        :total-pages="myClassesTotalPagesComputed"
        :items-per-page="myClassesPerPage"
        :total-items="myClassesTotalItemsComputed"
        @update:current-page="$emit('update:my-classes-page', $event)"
        @update:items-per-page="$emit('update:my-classes-per-page', $event)"
      />
    </div>

    <!-- View 2: Calendar View -->
    <StudentClassesCalendarView
      v-else-if="viewMode === 'calendar'"
      :schedule-data="scheduleData"
    />

    <!-- View 3: Register New Class (COURSE CATALOG) -->
    <StudentClassesRegisterView
      v-else-if="viewMode === 'register'"
      :available-classes="availableClasses"
      :error="error"
      :pending="pending"
      :refresh="refresh"
      :subjects="subjects"
      :search-query="searchQuery"
      :subject="subject"
      :page="availablePage"
      :per-page="availablePerPage"
      :total-pages="props.availableTotalPages"
      :total-items="props.availableTotalItems"
      @update:search-query="searchQuery = $event"
      @update:subject="subject = $event"
      @update:page="availablePage = $event"
      @update:per-page="availablePerPage = $event"
      @register="handleRegister"
    />

    <!-- Leave Request Modal -->
    <StudentLeaveRequestModal
      v-model="showLeaveModal"
      :selected-class="selectedClass"
      @submit="submitLeaveRequest"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { useToast } from 'vue-toastification';
import { useI18n } from 'vue-i18n';
import type { Class, StudentClass } from 'app/types/class';
import StudentClassDetailView from './StudentClassDetailView.vue';
import StudentLeaveRequestModal from './StudentLeaveRequestModal.vue';

interface ScheduleEvent {
  time: string;
  subject: string;
  room: string;
  type: string;
}

const props = defineProps<{
  classes: StudentClass[];
  availableClasses: Class[];
  error: any;
  pending: boolean;
  refresh: () => void;
  subjects: string[];
  subjectsPending: boolean;
  availableTotalPages: number;
  availableTotalItems: number;
  myClassesPage: number;
  myClassesPerPage: number;
  myClassesTotalPages: number;
  myClassesTotalItems: number;
  refreshStudentClasses: () => void;
}>();

const searchQuery = defineModel<string>('searchQuery', { default: '' });
const subject = defineModel<string | undefined>('subject', {
  default: undefined,
});
const availablePage = defineModel<number>('availablePage', { default: 1 });
const availablePerPage = defineModel<number>('availablePerPage', {
  default: 20,
});

const emit = defineEmits<{
  'update:my-classes-page': [page: number];
  'update:my-classes-per-page': [perPage: number];
}>();

const { t } = useI18n();
const toast = useToast();

const viewMode = ref<'list' | 'calendar' | 'register' | 'detail'>('list');
const showLeaveModal = ref(false);
const selectedClass = ref<StudentClass | null>(null);
const { startLoading, stopLoading } = useLoading();

// Computed properties for my classes pagination
const myClassesTotalPagesComputed = computed(() => {
  return props.myClassesTotalPages || 1;
});

const myClassesTotalItemsComputed = computed(() => {
  return props.myClassesTotalItems || 0;
});

const scheduleData = computed<ScheduleEvent[][]>(() => {
  if (!props.classes || props.classes.length === 0) {
    return Array(7).fill([]);
  }

  const weekSchedule: ScheduleEvent[][] = Array(7)
    .fill(null)
    .map(() => []);

  // Chỉ lấy các class đã join (status = 'active')
  const activeClasses = props.classes.filter((cls) => cls.status === 'active');

  activeClasses.forEach((cls) => {
    // Sử dụng rawSchedule nếu có (object format mới), nếu không thì fallback sang schedule string
    let scheduleObj: Record<string, string> = {};
    
    if (cls.rawSchedule && typeof cls.rawSchedule === 'object') {
      // Format mới: object với keys là số (0-6)
      scheduleObj = cls.rawSchedule;
    } else if (typeof cls.schedule === 'object' && cls.schedule !== null) {
      // Fallback: nếu schedule là object (không phải string)
      scheduleObj = cls.schedule;
    } else if (typeof cls.schedule === 'string') {
      // Nếu là string đã format, cố gắng parse (fallback cho format cũ)
      const scheduleStr = cls.schedule || '';
      const times = scheduleStr.match(/\d{1,2}:\d{2}/g);
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      
      for (let i = 0; i < days.length; i++) {
        if (scheduleStr.includes(days[i]!)) {
          scheduleObj[i.toString()] = times ? times.join('-') : scheduleStr;
          break;
        }
      }
    }

    // Xử lý từng ngày trong schedule
    Object.entries(scheduleObj).forEach(([dayKey, timeRange]) => {
      const dayIndex = parseInt(dayKey, 10);
      
      // Validate dayIndex (0-6: Monday-Sunday)
      if (isNaN(dayIndex) || dayIndex < 0 || dayIndex > 6) return;

      // Parse time range (có thể là "18:00-19:30" hoặc chỉ "18:00")
      const timeParts = String(timeRange).split('-');
      const startTime = timeParts[0]?.trim() || '';
      const endTime = timeParts[1]?.trim() || '';
      const time = endTime ? `${startTime} - ${endTime}` : startTime;

      if (!time) return;

      const event: ScheduleEvent = {
        time,
        subject: cls.name,
        room: cls.room || 'TBD',
        type: 'blue',
      };

      weekSchedule[dayIndex]!.push(event);
    });
  });

  return weekSchedule;
});

// Schedule data for calendar view (fallback empty state)

const handleRequestLeave = async (cls: StudentClass) => {
  if (cls.status === 'pending') {
    if (
      confirm(t('student.classes.confirmCancelEnroll', { className: cls.name }))
    ) {
      try {
        startLoading(t('student.classes.leaving'));
        await useEnrollClassApi().quitClass(cls.class_id);
        toast.success(t('student.classes.leave.cancelSuccess'));
        props.refresh();
        props.refreshStudentClasses();
      } catch (error) {
        toast.error(
          getErrorMessage(error, 'student.classes.', t) ||
            t('student.classes.leave.cancelError')
        );
      } finally {
        stopLoading();
      }
    }
  } else {
    selectedClass.value = cls;
    showLeaveModal.value = true;
  }
};

const handleMakeupClass = (cls: StudentClass) => {
  toast.info(t('student.classes.actions.makeupInfo'));
};

const handleRegister = async (course: Class) => {
  if (
    confirm(t('student.classes.confirmRegister', { className: course.name }))
  ) {
    try {
      await useEnrollClassApi().registerClass(course.id);
      toast.success(t('student.classes.registerSuccess'));
      viewMode.value = 'list';
      props.refresh();
      props.refreshStudentClasses();
    } catch (error) {
      toast.error(
        getErrorMessage(error, 'student.classes.', t) ||
          t('student.classes.registerError')
      );
    }
  }
};

const submitLeaveRequest = async (payload: {
  date: string;
  reason: string;
  leaveType: string;
}) => {
  if (!selectedClass.value) return;

  try {
    startLoading(t('student.classes.submittingLeave'));
    await useEnrollClassApi().leaveRequestClass(
      selectedClass.value.class_id,
      payload.reason,
      payload.leaveType,
      payload.date
    );
    toast.success(t('student.classes.leave.successMessage'));
    showLeaveModal.value = false;
    selectedClass.value = null;
  } catch (error) {
    toast.error(
      getErrorMessage(error, 'student.classes.', t) ||
        t('student.classes.leave.errorSubmitting')
    );
  } finally {
    stopLoading();
  }
};

const handleViewDetail = (cls: StudentClass) => {
  selectedClass.value = cls;
  viewMode.value = 'detail';
};
</script>
