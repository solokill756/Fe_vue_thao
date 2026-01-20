import type { ApiResponseSuccess } from '@/types/common';


export interface StudentFinanceInfo {
  id: number;
  name: string;
  parentName: string;
  package: string;
  totalSessions: number;
  sessionsLeft: number;
  status: 'paid' | 'debt' | 'expiring_soon' | 'new';
  amount: number;
  avatar?: string;
  student_code?: string;
  enrollment_id?: number;
}

export interface FinanceStats {
  collectedThisMonth: number;
  collectedCount: number;
  outstandingDebt: number;
  debtCount: number;
  expiringSoon: number;
  totalStudents?: number;
}

export interface ClassFinanceResponse {
  students: StudentFinanceInfo[];
  stats: FinanceStats;
}

export const useTeacherFinanceApi = () => {
  const config = useRuntimeConfig();
  const apiBase = config.public.apiBase;

  // Get finance stats for all classes
  const getAllFinanceStats = () =>
    apiFetch<ApiResponseSuccess<FinanceStats>>(
      `${apiBase}/teacher/classes/finance/stats`,
      {
        method: 'GET',
      }
    );

  // Get finance data for a specific class
  const getClassFinance = (classId: number, params?: { search?: string }) =>
    apiFetch<ApiResponseSuccess<ClassFinanceResponse>>(
      `${apiBase}/teacher/classes/${classId}/finance`,
      {
        method: 'GET',
        params,
      }
    );

  // Record payment for a student
  const recordPayment = (
    classId: number,
    enrollmentId: number,
    payload: {
      amount: number;
      method: 'cash' | 'transfer';
      note?: string;
    }
  ) =>
    apiFetch<ApiResponseSuccess<{ message: string }>>(
      `${apiBase}/teacher/classes/${classId}/enrollments/${enrollmentId}/record_payment`,
      {
        method: 'POST',
        body: payload,
      }
    );

  // Send reminder to student
  const sendReminder = (
    classId: number,
    enrollmentId: number,
    message?: string
  ) =>
    apiFetch<ApiResponseSuccess<{ message: string }>>(
      `${apiBase}/teacher/classes/${classId}/enrollments/${enrollmentId}/send_reminder`,
      {
        method: 'POST',
        body: { message },
      }
    );

  // Send reminders to all students with debt
  const sendAllReminders = (classId: number) =>
    apiFetch<ApiResponseSuccess<{ message: string; count: number }>>(
      `${apiBase}/teacher/classes/${classId}/send_all_reminders`,
      {
        method: 'POST',
      }
    );

  // Get payment history for a student
  const getStudentPaymentHistory = (
    classId: number,
    enrollmentId: number,
    params?: { page?: number; per_page?: number }
  ) =>
    apiFetch<ApiResponseSuccess<{
      transactions: Array<{
        id: string;
        date: string;
        amount: number;
        method: string;
        status: string;
      }>;
      pagination: any;
    }>>(
      `${apiBase}/teacher/classes/${classId}/enrollments/${enrollmentId}/payment_history`,
      {
        method: 'GET',
        params,
      }
    );

  // Get pending transactions for a class (for teacher to approve)
  const getPendingTransactions = (classId: number, params?: { page?: number; per_page?: number }) =>
    apiFetch<ApiResponseSuccess<{
      transactions: Array<{
        id: number;
        student_id: number;
        student_name: string;
        invoice_code: string;
        amount: number;
        method: string;
        status: string;
        payment_date: string;
        description: string;
        created_at: string;
      }>;
      pagination: any;
    }>>(
      `${apiBase}/teacher/classes/${classId}/pending_transactions`,
      {
        method: 'GET',
        params,
      }
    );

  // Approve transaction
  const approveTransaction = (transactionId: number) =>
    apiFetch<ApiResponseSuccess<{ message: string }>>(
      `${apiBase}/transactions/${transactionId}/approve`,
      {
        method: 'PATCH',
      }
    );

  // Reject transaction
  const rejectTransaction = (transactionId: number) =>
    apiFetch<ApiResponseSuccess<{ message: string }>>(
      `${apiBase}/transactions/${transactionId}/reject`,
      {
        method: 'PATCH',
      }
    );

  // Create invoice for a student (teacher only)
  const createInvoice = (
    classId: number,
    enrollmentId: number,
    payload: {
      title: string;
      description?: string;
      amount: number;
      due_date: string;
      status?: 'pending' | 'paid' | 'overdue';
    }
  ) =>
    apiFetch<ApiResponseSuccess<any>>(
      `${apiBase}/teacher/classes/${classId}/enrollments/${enrollmentId}/create_invoice`,
      {
        method: 'POST',
        body: { invoice: payload },
      }
    );

  return {
    getAllFinanceStats,
    getClassFinance,
    recordPayment,
    sendReminder,
    sendAllReminders,
    getStudentPaymentHistory,
    getPendingTransactions,
    approveTransaction,
    rejectTransaction,
    createInvoice,
  };
};
