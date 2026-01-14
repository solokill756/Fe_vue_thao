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
    $fetch<ApiResponseSuccess<TransactionHistoryResponse>>(
      `${apiBase}/payments/history?page=${page}&per_page=${perPage}`,
      {
        method: 'GET',
        headers: getAuthHeader(),
      }
    );

  const processPayment = (payload: ProcessPaymentRequest) =>
    $fetch<ProcessPaymentResponse>(`${apiBase}/payments/process`, {
      method: 'POST',
      headers: getAuthHeader(),
      body: payload,
    });

  return {
    getPaymentHistory,
    processPayment,
  };
};
