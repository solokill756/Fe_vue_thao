import { ref, onMounted } from 'vue';
import type { Ref } from 'vue';
import { useTuitionApi } from './useTuitionApi';

interface StudentClass {
  timeStart: string;
  subject: string;
  teacher: string;
  room: string;
  status: 'dropped' | 'live' | 'upcoming';
}

export interface Assignment {
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
  assignments: Assignment[];
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
  pendingAssignments: Ref<Assignment[]>;
  tuitionData: Ref<Tuition>;
  stats: Ref<DashboardData['stats']>;
} => {
  const { getTuitionDashboard } = useTuitionApi();
  const debugMode = ref(false);

  const studentInfo = ref<StudentInfo>({
    name: 'Trần Văn Minh',
    avatar:
      'https://ui-avatars.com/api/?name=Tran+Minh&background=2563EB&color=fff',
    class: 'Học sinh Lớp 12',
  });

  const todayClasses = ref<StudentClass[]>([
    {
      timeStart: '17:30',
      subject: 'Toán Cao Cấp (Đại số)',
      teacher: 'Thầy Nguyễn Văn A',
      room: 'P.302',
      status: 'live',
    },
    {
      timeStart: '19:15',
      subject: 'Luyện thi IELTS',
      teacher: 'Ms. Sarah',
      room: 'Zoom Online',
      status: 'upcoming',
    },
  ]);

  const pendingAssignments = ref<Assignment[]>([
    {
      title: 'Bài tập Đại số tuyến tính',
      class: 'Toán 12A',
      dueDate: '20:00 Tối nay',
      isUrgent: true,
      status: 'Chưa nộp',
    },
    {
      title: 'Viết lại bài luận Task 2',
      class: 'Tiếng Anh',
      dueDate: '09/01/2024',
      isUrgent: false,
      status: 'Đang làm',
    },
    {
      title: 'Trắc nghiệm Vật Lý',
      class: 'Lý 12',
      dueDate: '10/01/2024',
      isUrgent: false,
      status: 'Đang làm',
    },
  ]);

  const tuitionData = ref<Tuition>({
    totalPendingDebt: 2500000,
    nextDueDate: '15/01/2024',
    debt: '2.500.000đ',
  });

  const stats = ref<DashboardData['stats']>([
    {
      icon: 'fa-user-check',
      color: 'text-blue-600 bg-blue-100',
      title: 'Điểm danh',
      value: '95%',
      subtitle: 'Vắng 1 buổi (Có phép)',
    },
    {
      icon: 'fa-chart-line',
      color: 'text-emerald-600 bg-emerald-100',
      title: 'Điểm TB',
      value: '8.5',
      subtitle: 'Tăng 0.5 so với giữa kỳ',
    },
    {
      icon: 'fa-book',
      color: 'text-orange-600 bg-orange-100',
      title: 'Bài tập',
      value: '12',
      subtitle: 'Đã hoàn thành tốt',
    },
    {
      icon: 'fa-wallet',
      color: 'text-purple-600 bg-purple-100',
      title: 'Số dư ví',
      value: '200k',
      subtitle: 'Hạn gói: 15/02',
    },
  ]);

  // Load tuition data from API
  const loadTuitionData = async () => {
    try {
      const response = await getTuitionDashboard();
      if (response.data) {
        const data = response.data;
        tuitionData.value = {
          totalPendingDebt: data.total_debt,
          nextDueDate: data.next_due_date,
          debt: `${new Intl.NumberFormat('vi-VN', {
            style: 'currency',
            currency: 'VND',
          }).format(data.total_debt)}`,
        };
        // Update stats with wallet balance
        const walletStat = stats.value.find((s) => s.title === 'Số dư ví');
        if (walletStat) {
          walletStat.value = new Intl.NumberFormat('vi-VN', {
            style: 'currency',
            currency: 'VND',
          }).format(data.wallet_balance);
        }
      }
    } catch (error) {
      console.error('Error loading tuition data:', error);
    }
  };

  onMounted(() => {
    loadTuitionData();
  });

  return {
    debugMode,
    studentInfo,
    todayClasses,
    pendingAssignments,
    tuitionData,
    stats,
  };
};
