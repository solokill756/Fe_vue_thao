import type {
  PaymentRequest,
  PaymentResponse,
  TuitionInvoiceResponse,
  TuitionInvoice,
  TuitionData,
} from '@/types/tuition';
import type { ApiResponseSuccess } from '@/types/common';

export const useTuitionApi = () => {
  const config = useRuntimeConfig();
  const apiBase = config.public.apiBase;

  const getTuitionDashboard = () =>
    $fetch<ApiResponseSuccess<TuitionData>>(`${apiBase}/tuition-dashboard`, {
      method: 'GET',
      headers: getAuthHeader(),
    });

  const getTuitionInvoices = (params?: { page?: number; per_page?: number }) => {
    const queryParams = new URLSearchParams();
    if (params?.page) queryParams.append('page', params.page.toString());
    if (params?.per_page) queryParams.append('per_page', params.per_page.toString());
    const queryString = queryParams.toString();
    return $fetch<ApiResponseSuccess<TuitionInvoiceResponse>>(
      `${apiBase}/tuition_invoices${queryString ? `?${queryString}` : ''}`,
      {
        method: 'GET',
        headers: getAuthHeader(),
      }
    );
  };

  const getTuitionInvoice = (invoiceId: string) =>
    $fetch<ApiResponseSuccess<TuitionInvoice>>(
      `${apiBase}/tuition_invoices/${invoiceId}`,
      {
        method: 'GET',
        headers: getAuthHeader(),
      }
    );

  const createTuitionInvoice = (payload: any) =>
    $fetch<ApiResponseSuccess<any>>(`${apiBase}/tuition_invoices`, {
      method: 'POST',
      headers: getAuthHeader(),
      body: { tuition_invoice: payload },
    });

  const updateTuitionInvoice = (invoiceId: string, payload: any) =>
    $fetch<ApiResponseSuccess<any>>(
      `${apiBase}/tuition_invoices/${invoiceId}`,
      {
        method: 'PATCH',
        headers: getAuthHeader(),
        body: { tuition_invoice: payload },
      }
    );

  return {
    getTuitionDashboard,
    getTuitionInvoices,
    getTuitionInvoice,
    createTuitionInvoice,
    updateTuitionInvoice,
  };
};
