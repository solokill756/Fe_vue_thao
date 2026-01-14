/**
 * Tuition-related types and interfaces
 */

import type { PaginationInfo } from './common';

export type TuitionStatus = 'pending' | 'paid' | 'overdue';
export type TransactionMethod = 'cash' | 'transfer' | 'online_gateway';

export interface TuitionInvoice {
  id: number;
  student_id: number;
  title: string;
  description?: string;
  amount: number;
  status: TuitionStatus;
  due_date: string; // ISO date string (YYYY-MM-DD)
  paid_date?: string | null;
  invoice_code: string;
  days_until_due: number;
  is_overdue: boolean;
  created_at: string;
  updated_at: string;
}

export interface TuitionHistory {
  id: string;
  title: string;
  date: string;
  amount: number;
  status: 'success' | 'failed';
  method: TransactionMethod;
}

export interface PaymentRequest {
  invoice_id: string;
  amount: number;
  method: TransactionMethod;
  notes?: string;
}

export interface PaymentResponse {
  success: boolean;
  transaction_id: string;
  status: string;
  message: string;
}

export interface TuitionInvoiceResponse {
  invoices: TuitionInvoice[];
  pagination: PaginationInfo;
}

export interface TuitionData {
  total_debt: number;
  next_due_date: string;
  debt: string;
  wallet_balance: number;
}
