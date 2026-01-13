# frozen_string_literal: true

module Api
  module V1
    class TuitionInvoicesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_student, only: [:index, :show, :create]
      before_action :set_tuition_invoice, only: [:show, :update, :destroy]

      # GET /api/v1/tuition_invoices
      def index
        @tuition_invoices = @student.tuition_invoices.recent
        render json: serialize_invoices(@tuition_invoices)
      end

      # GET /api/v1/tuition_invoices/:id
      def show
        render json: TuitionInvoiceSerializer.new(@tuition_invoice)
      end

      # POST /api/v1/tuition_invoices
      def create
        @tuition_invoice = @student.tuition_invoices.build(tuition_invoice_params)

        if @tuition_invoice.save
          render json: TuitionInvoiceSerializer.new(@tuition_invoice), status: :created
        else
          render json: error_response(@tuition_invoice.errors), status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/tuition_invoices/:id
      def update
        if @tuition_invoice.update(tuition_invoice_params)
          render json: TuitionInvoiceSerializer.new(@tuition_invoice)
        else
          render json: error_response(@tuition_invoice.errors), status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/tuition_invoices/:id
      def destroy
        @tuition_invoice.destroy
        render json: { message: 'Invoice deleted successfully' }, status: :ok
      end

      private

      def set_student
        @student = current_user.student
        render json: { error: 'Student profile not found' }, status: :not_found unless @student
      end

      def set_tuition_invoice
        @tuition_invoice = TuitionInvoice.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Invoice not found' }, status: :not_found
      end

      def tuition_invoice_params
        params.require(:tuition_invoice).permit(:title, :description, :amount, :due_date, :status)
      end

      def serialize_invoices(invoices)
        {
          data: invoices.map { |invoice| TuitionInvoiceSerializer.new(invoice).serializable_hash },
          meta: { total: invoices.count }
        }
      end

      def error_response(errors)
        { errors: errors.full_messages }
      end
    end
  end
end
