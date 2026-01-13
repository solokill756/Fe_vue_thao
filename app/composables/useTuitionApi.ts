import type { TuitionData, PaymentRequest, PaymentResponse } from '@/types/tuition'
import type { ApiResponseSuccess } from '@/types/common'

export const useTuitionApi = () => {
  const config = useRuntimeConfig()
  const apiBase = config.public.apiBase

  const getTuitionDashboard = () =>
    $fetch<ApiResponseSuccess<TuitionData>>(`${apiBase}/tuition-dashboard`, {
      method: 'GET',
      headers: getAuthHeader(),
    })

  const getTuitionInvoices = () =>
    $fetch<ApiResponseSuccess<any>>(`${apiBase}/tuition_invoices`, {
      method: 'GET',
      headers: getAuthHeader(),
    })

  const getTuitionInvoice = (invoiceId: string) =>
    $fetch<ApiResponseSuccess<any>>(`${apiBase}/tuition_invoices/${invoiceId}`, {
      method: 'GET',
      headers: getAuthHeader(),
    })

  const createTuitionInvoice = (payload: any) =>
    $fetch<ApiResponseSuccess<any>>(`${apiBase}/tuition_invoices`, {
      method: 'POST',
      headers: getAuthHeader(),
      body: { tuition_invoice: payload },
    })

  const updateTuitionInvoice = (invoiceId: string, payload: any) =>
    $fetch<ApiResponseSuccess<any>>(`${apiBase}/tuition_invoices/${invoiceId}`, {
      method: 'PATCH',
      headers: getAuthHeader(),
      body: { tuition_invoice: payload },
    })

  const processPayment = (payload: PaymentRequest) =>
    $fetch<PaymentResponse>(`${apiBase}/payments/process`, {
      method: 'POST',
      headers: getAuthHeader(),
      body: { payment: payload },
    })

  const getPaymentHistory = (page: number = 1) =>
    $fetch<ApiResponseSuccess<any>>(`${apiBase}/payments/history?page=${page}`, {
      method: 'GET',
      headers: getAuthHeader(),
    })

  return {
    getTuitionDashboard,
    getTuitionInvoices,
    getTuitionInvoice,
    createTuitionInvoice,
    updateTuitionInvoice,
    processPayment,
    getPaymentHistory,
  }
}
