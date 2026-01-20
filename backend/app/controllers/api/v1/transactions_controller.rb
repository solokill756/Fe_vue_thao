# frozen_string_literal: true

module Api
  module V1
    class TransactionsController < Api::V1::BaseController
      before_action :set_transaction

      # PATCH /api/v1/transactions/:id/approve
      def approve
      
        return render_error('Unauthorized', :unauthorized) unless @current_user.role == 'teacher'

     
        return render_error('Transaction is not pending', :unprocessable_entity) unless @transaction.pending?

        
        invoice = @transaction.tuition_invoice
        school_class = invoice.school_class
        return render_error('Unauthorized', :unauthorized) unless school_class.teacher_id == @current_user.id

        # Approve transaction
        @transaction.mark_as_completed

        # Mark invoice as paid
        invoice.mark_as_paid!

        # Update enrollment debt
        enrollment = Enrollment.find_by(class_id: school_class.id, student_id: invoice.student_id)
        if enrollment
          enrollment.update(tuition_debt: [enrollment.tuition_debt - @transaction.amount, 0].max)
        end

        render_success(
          {
            message: 'Transaction approved successfully',
            transaction: TransactionSerializer.serialize(@transaction)
          },
          :ok
        )
      rescue StandardError => e
        Rails.logger.error("Error approving transaction: #{e.message}\n#{e.backtrace.join("\n")}")
        render_error({ error: e.message }, :internal_server_error)
      end

      # PATCH /api/v1/transactions/:id/reject
      def reject
       
        return render_error('Unauthorized', :unauthorized) unless @current_user.role == 'teacher'

   
        return render_error('Transaction is not pending', :unprocessable_entity) unless @transaction.pending?

      
        invoice = @transaction.tuition_invoice
        school_class = invoice.school_class
        return render_error('Unauthorized', :unauthorized) unless school_class.teacher_id == @current_user.id

        
        @transaction.mark_as_failed

        render_success(
          {
            message: 'Transaction rejected',
            transaction: TransactionSerializer.serialize(@transaction)
          },
          :ok
        )
      rescue StandardError => e
        Rails.logger.error("Error rejecting transaction: #{e.message}\n#{e.backtrace.join("\n")}")
        render_error({ error: e.message }, :internal_server_error)
      end

      private

      def set_transaction
        @transaction = Transaction.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_error('Transaction not found', :not_found)
      end
    end
  end
end
