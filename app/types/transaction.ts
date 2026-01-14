import type { PaginationInfo } from './common';

export type TransactionStatus = 'pending' | 'completed' | 'failed';
export type TransactionMethod = 'cash' | 'transfer' | 'online_gateway';
export type TransactionType = 'tuition_fee' | 'package_subscription';

export interface Transaction {
  id: number;
  tuition_invoice_id: number | null;
  amount: number;
  payment_date: string;
  method: TransactionMethod;
  status: TransactionStatus | string;
  description: string | null;
  created_at: string;
  updated_at: string;
}

export interface TransactionHistoryResponse {
  transactions: Transaction[];
  pagination: PaginationInfo;
}

export interface ProcessPaymentRequest {
  invoice_code: string;
  amount: number;
  method: TransactionMethod;
}

export interface ProcessPaymentResponse {
  success: boolean;
  data?: {
    transaction_id: number;
  };
}
