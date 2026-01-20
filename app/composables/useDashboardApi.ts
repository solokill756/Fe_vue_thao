import type { ApiResponseSuccess } from '@/types/common';


export interface DashboardData {
  student_info: {
    name: string;
    avatar: string;
    class: string;
  };
  today_classes: Array<{
    timeStart: string;
    subject: string;
    teacher: string;
    room: string;
    status: 'dropped' | 'live' | 'upcoming';
  }>;
  pending_assignments: Array<{
    title: string;
    class: string;
    dueDate: string;
    isUrgent: boolean;
    status: string;
  }>;
  stats: Array<{
    icon: string;
    color: string;
    title: string;
    value: string;
    subtitle: string;
  }>;
  tuition: {
    totalPendingDebt: number;
    nextDueDate: string;
    debt: string;
  };
}

export const useDashboardApi = () => {
  const config = useRuntimeConfig();
  const apiBase = config.public.apiBase;

  const getDashboard = () =>
    apiFetch<ApiResponseSuccess<DashboardData>>(`${apiBase}/student-dashboard`, {
      method: 'GET',
    });

  return {
    getDashboard,
  };
};
