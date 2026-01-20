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
    apiFetch<ApiResponseSuccess<TuitionData>>(`${apiBase}/tuition-dashboard`, {
      method: 'GET',
    });

  const getTuitionInvoices = (params?: { page?: number; per_page?: number }) => {
    const queryParams = new URLSearchParams();
    if (params?.page) queryParams.append('page', params.page.toString());
    if (params?.per_page) queryParams.append('per_page', params.per_page.toString());
    const queryString = queryParams.toString();
    return apiFetch<ApiResponseSuccess<TuitionInvoiceResponse>>(
      `${apiBase}/tuition_invoices${queryString ? `?${queryString}` : ''}`,
      {
        method: 'GET',
      }
    );
  };

  const getTuitionInvoice = (invoiceId: string) =>
    apiFetch<ApiResponseSuccess<TuitionInvoice>>(
      `${apiBase}/tuition_invoices/${invoiceId}`,
      {
        method: 'GET',
      }
    );

  const createTuitionInvoice = (payload: any) =>
    apiFetch<ApiResponseSuccess<any>>(`${apiBase}/tuition_invoices`, {
      method: 'POST',
      body: { tuition_invoice: payload },
    });

  const updateTuitionInvoice = (invoiceId: string, payload: any) =>
    apiFetch<ApiResponseSuccess<any>>(
      `${apiBase}/tuition_invoices/${invoiceId}`,
      {
        method: 'PATCH',
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
