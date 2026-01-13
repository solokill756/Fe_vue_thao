/**
 * Tuition-related types and interfaces
 */

export type TuitionStatus = 'pending' | 'paid' | 'overdue';
export type TransactionMethod = 'cash' | 'transfer' | 'online_gateway';

export interface TuitionInvoice {
  id: string;
  student_id: number;
  title: string;
  description?: string;
  amount: number;
  status: TuitionStatus;
  due_date: string; // ISO date string
  paid_date?: string | null;
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

export interface TuitionData {
  total_debt: number;
  next_due_date: string;
  wallet_balance: number;
  pending_invoices: TuitionInvoice[];
  history: TuitionHistory[];
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
