# frozen_string_literal: true

module Api
  module V1
    class PaymentsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_student
      before_action :set_invoice, only: [:process_payment]

      # POST /api/v1/payments/process
      def process_payment
        payment_result = process_tuition_payment(@invoice, payment_params)
        
        if payment_result[:success]
          render json: {
            success: true,
            transaction_id: payment_result[:transaction_id],
            status: 'completed',
            message: 'Thanh toán thành công!'
          }, status: :ok
        else
          render json: {
            success: false,
            message: payment_result[:error]
          }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/payments/history
      def history
        transactions = @student.transactions.recent.paginate(page: params[:page], per_page: 20)
        render json: {
          data: serialize_transactions(transactions),
          pagination: {
            current_page: transactions.current_page,
            total_pages: transactions.total_pages,
            total_count: transactions.total_count
          }
        }
      end

      private

      def set_student
        @student = current_user.student
        render json: { error: 'Student profile not found' }, status: :not_found unless @student
      end

      def set_invoice
        @invoice = TuitionInvoice.find_by(invoice_code: params[:invoice_id])
        render json: { error: 'Invoice not found' }, status: :not_found unless @invoice
      end

      def process_tuition_payment(invoice, params)
        return { success: false, error: 'Invoice already paid' } if invoice.paid?
        return { success: false, error: 'Invalid payment method' } unless valid_payment_method?(params[:method])

        # Create transaction record
        transaction = create_payment_transaction(invoice, params)

        if transaction.save
          invoice.mark_as_paid!
          @student.add_to_wallet(-invoice.amount) if should_deduct_from_wallet?(params[:method])
          
          { success: true, transaction_id: transaction.id }
        else
          { success: false, error: 'Payment processing failed' }
        end
      end

      def create_payment_transaction(invoice, params)
        Transaction.new(
          user_id: @student.user_id,
          amount: invoice.amount,
          payment_date: Date.current,
          type: 'tuition_fee',
          method: params[:method],
          status: 'completed',
          description: invoice.title
        )
      end

      def valid_payment_method?(method)
        %w[cash transfer online_gateway].include?(method)
      end

      def should_deduct_from_wallet?(method)
        method == 'wallet'
      end

      def payment_params
        params.require(:payment).permit(:method, :notes)
      end

      def serialize_transactions(transactions)
        transactions.map do |txn|
          {
            id: "TXN-#{txn.id}",
            title: txn.description || 'Thanh toán học phí',
            date: txn.payment_date.strftime('%d/%m/%Y'),
            amount: txn.amount.to_i,
            status: 'success'
          }
        end
      end
    end
  end
end
