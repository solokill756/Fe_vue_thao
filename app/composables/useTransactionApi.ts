import type { ApiResponseSuccess } from '@/types/common';
import type {
  ProcessPaymentRequest,
  ProcessPaymentResponse,
  TransactionHistoryResponse,
} from '@/types/transaction';


export const useTransactionApi = () => {
  const config = useRuntimeConfig();
  const apiBase = config.public.apiBase;

  const getPaymentHistory = (page: number = 1, perPage: number = 20) =>
    apiFetch<ApiResponseSuccess<TransactionHistoryResponse>>(
      `${apiBase}/payments/history?page=${page}&per_page=${perPage}`,
      {
        method: 'GET',
      }
    );

  const processPayment = (payload: ProcessPaymentRequest) =>
    apiFetch<ProcessPaymentResponse>(`${apiBase}/payments/process`, {
      method: 'POST',
      body: payload,
    });

  return {
    getPaymentHistory,
    processPayment,
  };
};
