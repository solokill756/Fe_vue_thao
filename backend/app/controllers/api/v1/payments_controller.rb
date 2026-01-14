# frozen_string_literal: true

module Api
  module V1
    class PaymentsController < Api::V1::BaseController
      # POST /api/v1/payments/process
      def process_payment
        invoice = TuitionInvoice.find_by(invoice_code: payment_params[:invoice_code])
        return render_error({ error: 'Invoice not found' }, :not_found) unless invoice

        payment_result = process_tuition_payment(invoice, payment_params)

        if payment_result[:success]
          render_success(
            { transaction_id: payment_result[:transaction_id] },
            :ok
          )
        else
          render_error({ error: payment_result[:error] }, :unprocessable_entity)
        end
      end

      # GET /api/v1/payments/history
      def history
        student = @current_user.student_profile
        return render_error({ error: 'Student profile not found' }, :not_found) unless student

        transactions = TransactionService.new.get_student_transactions(student.id)
        if transactions.success?
          transactions = transactions.data
          result = paginate(transactions, { per_page: query_params[:per_page] || 20, page: query_params[:page] || 1 })
          render_success(
            {
              transactions: TransactionSerializer.serialize_collection(result[:records]),
              pagination: result[:pagination]
            },
            :ok
          )
        else
          render_error(transactions.errors, :bad_request)
        end
      end

      private

      def process_tuition_payment(invoice, params)
        return { success: false, error: 'Invoice already paid' } if invoice.paid?
        return { success: false, error: 'Invalid payment method' } unless valid_payment_method?(params[:method])

        # Convert amount to BigDecimal to ensure proper type
        amount = params[:amount].present? ? BigDecimal(params[:amount].to_s) : invoice.amount

        transaction_params = {
          amount: amount,
          method: params[:method],
          type: 'tuition_fee',
          status: 'pending',
          payment_date: Date.current,
          description: invoice.title
        }

        result = TransactionService.new.record(invoice.id, transaction_params)

        if result.success?
          invoice.mark_as_paid!
          { success: true, transaction_id: result.data.id }
        else
          { success: false, error: result.errors }
        end
      end

     

      def valid_payment_method?(method)
        %w[cash transfer online_gateway].include?(method)
      end

      def serialize_transactions(transactions)
        transactions.map do |txn|
          {
            id: "TXN-#{txn.id}",
            title: txn.description || 'Thanh toán học phí',
            date: txn.payment_date.strftime('%d/%m/%Y'),
            amount: txn.amount.to_i,
            status: txn.status
          }
        end
      end

      def payment_params
        params.require(:payment).permit(:method,  :invoice_code , :amount) 
      end

      def query_params
        params.permit(:page, :per_page)
      end
    end
  end
end
