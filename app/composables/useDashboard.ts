import { ref, onMounted } from 'vue';
import type { Ref } from 'vue';
import { useDashboardApi } from './useDashboardApi';

interface StudentClass {
  timeStart: string;
  subject: string;
  teacher: string;
  room: string;
  status: 'dropped' | 'live' | 'upcoming';
}

interface AssignmentDashboard {
  title: string;
  class: string;
  dueDate: string;
  isUrgent: boolean;
  status: string;
}

export interface Tuition {
  totalPendingDebt: number;
  nextDueDate: string;
  debt: string;
}

export interface StudentInfo {
  name: string;
  avatar: string;
  class: string;
}

export interface DashboardData {
  student: StudentInfo;
  classes: StudentClass[];
  assignments: AssignmentDashboard[];
  tuition: Tuition;
  stats: Array<{
    icon: string;
    color: string;
    title: string;
    value: string;
    subtitle: string;
  }>;
}

export const useDashboard = (): {
  debugMode: Ref<boolean>;
  studentInfo: Ref<StudentInfo>;
  todayClasses: Ref<StudentClass[]>;
  pendingAssignments: Ref<AssignmentDashboard[]>;
  tuitionData: Ref<Tuition>;
  stats: Ref<DashboardData['stats']>;
  pending: Ref<boolean>;
  error: Ref<any>;
} => {
  const { getDashboard } = useDashboardApi();
  const debugMode = ref(false);

  const studentInfo = ref<StudentInfo>({
    name: '',
    avatar: '',
    class: '',
  });

  const todayClasses = ref<StudentClass[]>([]);
  const pendingAssignments = ref<AssignmentDashboard[]>([]);
  const tuitionData = ref<Tuition>({
    totalPendingDebt: 0,
    nextDueDate: 'N/A',
    debt: '0đ',
  });

  const stats = ref<DashboardData['stats']>([]);
  const pending = ref(true);
  const error = ref<any>(null);

  // Load dashboard data from API
  const loadDashboardData = async () => {
    try {
      pending.value = true;
      error.value = null;
      console.log('Loading dashboard data...');
      const response = await getDashboard();
      console.log('Dashboard API response:', response);

      if (response && response.data) {
        const data = response.data;
        console.log('Dashboard data:', data);

        // Update student info
        studentInfo.value = {
          name: data.student_info?.name || '',
          avatar: data.student_info?.avatar || '',
          class: data.student_info?.class || '',
        };

        // Update today classes
        todayClasses.value = data.today_classes || [];

        // Update pending assignments
        pendingAssignments.value = data.pending_assignments || [];

        // Update tuition data
        tuitionData.value = data.tuition || {
          totalPendingDebt: 0,
          nextDueDate: 'N/A',
          debt: '0đ',
        };

        // Update stats
        stats.value = data.stats || [];

        console.log('Dashboard data loaded successfully:', {
          studentInfo: studentInfo.value,
          todayClasses: todayClasses.value.length,
          pendingAssignments: pendingAssignments.value.length,
          stats: stats.value.length,
        });
      } else {
        console.warn('No data in response:', response);
      }
    } catch (err: any) {
      console.error('Error loading dashboard data:', err);
      error.value = err;

      // Get error message using i18n
      const { t } = useI18n();
      const errorMessage =
        getErrorMessage(err, 'student.dashboard.', t) ||
        t('student.dashboard.errors.ERROR');
      console.error('Dashboard error:', errorMessage);

      // Set default values on error
      studentInfo.value = {
        name: 'Học sinh',
        avatar:
          'https://ui-avatars.com/api/?name=Student&background=2563EB&color=fff',
        class: 'Học sinh',
      };
      stats.value = [
        {
          icon: 'fa-user-check',
          color: 'text-blue-600 bg-blue-100',
          title: 'Điểm danh',
          value: 'N/A',
          subtitle: 'Đang tải...',
        },
        {
          icon: 'fa-chart-line',
          color: 'text-emerald-600 bg-emerald-100',
          title: 'Điểm TB',
          value: 'N/A',
          subtitle: 'Đang tải...',
        },
        {
          icon: 'fa-book',
          color: 'text-orange-600 bg-orange-100',
          title: 'Bài tập',
          value: '0',
          subtitle: 'Đang tải...',
        },
      ];
    } finally {
      pending.value = false;
    }
  };

  onMounted(() => {
    loadDashboardData();
  });

  return {
    debugMode,
    studentInfo,
    todayClasses,
    pendingAssignments,
    tuitionData,
    stats,
    pending,
    error,
  };
};
