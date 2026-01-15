# frozen_string_literal: true

module Api
  module V1
    class TuitionInvoicesController < Api::V1::BaseController
      # GET /api/v1/tuition_invoices
      def index
        student = @current_user.student_profile
        result = TuitionInvoiceService.new.list_by_student(student)

        if result.success?
          invoices = result.data
          invoices = invoices.by_status(query_params[:status]) if query_params[:status].present?
          invoices = invoices.search_by_title(query_params[:title]) if query_params[:title].present?
          invoices = invoices.by_due_date
          ans = paginate(invoices, { per_page: query_params[:per_page] || 10, page: query_params[:page] || 1 })
          # Load records using find_by_sql to avoid ActiveRecord callbacks and associations
          record_ids = ans[:records].pluck(:id)
          records_array = TuitionInvoice.where(id: record_ids).order(due_date: :asc).to_a
          render_success(
            {
              invoices: TuitionInvoiceSerializer.serialize_collection(records_array),
              pagination: ans[:pagination]
            },
            :ok
          )
        else
          render_error(result.errors, :bad_request)
        end
      end

      # GET /api/v1/tuition_invoices/:id
      def show
        result = TuitionInvoiceService.new.find(params[:id], @current_user.student_profile)

        if result.success?
          render_success(TuitionInvoiceSerializer.serialize(result.data), :ok)
        else
          render_error(result.errors, :not_found)
        end
      end

      # POST /api/v1/tuition_invoices
      def create
        result = TuitionInvoiceService.new.create(tuition_invoice_params, @current_user.student_profile, params[:class_id])

        if result.success?
          render_success(TuitionInvoiceSerializer.serialize(result.data), :created)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # PATCH/PUT /api/v1/tuition_invoices/:id
      def update
        result = TuitionInvoiceService.new.update(params[:id], tuition_invoice_params, @current_user.student_profile)

        if result.success?
          render_success(TuitionInvoiceSerializer.serialize(result.data), :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # DELETE /api/v1/tuition_invoices/:id
      def destroy
        result = TuitionInvoiceService.new.destroy(params[:id], @current_user.student_profile)

        if result.success?
          render_success({ message: 'Invoice deleted successfully' }, :ok)
        else
          render_error(result.errors, :not_found)
        end
      end

      private

      def tuition_invoice_params
        params.require(:tuition_invoice).permit(:title, :description, :amount, :due_date, :status)
      end

      def query_params
        params.permit(:page, :per_page, :status, :title, :class_id)
      end
    end
  end
end
