# frozen_string_literal: true

module Api
  module V1
    class TuitionDashboardController < Api::V1::BaseController
      before_action :set_student

      # GET /api/v1/tuition-dashboard
      def show
        render json: build_tuition_data
      end

      private

      def set_student
        @student = current_user.student
        render json: { error: 'Student profile not found' }, status: :not_found unless @student
      end

      def build_tuition_data
        pending_invoices = @student.tuition_invoices.where(status: [:pending, :overdue])
        paid_invoices = @student.tuition_invoices.where(status: :paid).recent.limit(10)
        
        transactions = @student.transactions.recent.limit(10)
        
        {
          data: {
            total_debt: calculate_total_debt(pending_invoices),
            next_due_date: next_due_date(pending_invoices),
            wallet_balance: @student.wallet_balance,
            pending_invoices: serialize_invoices(pending_invoices),
            history: serialize_transaction_history(transactions),
            statistics: calculate_statistics
          }
        }
      end

      def calculate_total_debt(pending_invoices)
        pending_invoices.sum(:amount)
      end

      def next_due_date(pending_invoices)
        invoice = pending_invoices.where(status: 'pending').order(due_date: :asc).first
        invoice&.due_date&.strftime('%d/%m/%Y') || 'N/A'
      end

      def serialize_invoices(invoices)
        invoices.map do |invoice|
          {
            id: invoice.invoice_code,
            title: invoice.title,
            description: invoice.description,
            amount: invoice.amount.to_i,
            status: invoice.status,
            dueDate: invoice.due_date.strftime('%d/%m/%Y'),
            paid_date: invoice.paid_date&.strftime('%d/%m/%Y')
          }
        end
      end

      def serialize_transaction_history(transactions)
        transactions.map do |txn|
          {
            id: "TXN-#{txn.id}",
            title: "Thanh toán học phí #{txn.created_at.strftime('%m/%Y')}",
            date: txn.payment_date.strftime('%d/%m/%Y'),
            amount: txn.amount.to_i,
            status: 'success'
          }
        end
      end

      def calculate_statistics
        {
          paid_invoices_count: @student.tuition_invoices.paid.count,
          total_paid: @student.tuition_invoices.paid.sum(:amount),
          average_payment: @student.transactions.completed.average(:amount) || 0
        }
      end
    end
  end
end
