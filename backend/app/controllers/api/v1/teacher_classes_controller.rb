# frozen_string_literal: true

module Api
  module V1
    class TeacherClassesController < Api::V1::BaseController
      before_action :set_teacher

      # POST /api/v1/teacher/classes
      def create
        service = TeacherClassService.new(@teacher)
        result = service.create_class(class_params)

        if result.success?
          render_success(TeacherClassSerializer.serialize_detail(result.data), :created)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # GET /api/v1/teacher/classes
      def index
        service = TeacherClassService.new(@teacher)
        
       
        classes_result = service.list_classes(query_params)
        if classes_result.success?
          classes = classes_result.data
          result = paginate(classes, { per_page: query_params[:per_page] || 10, page: query_params[:page] || 1 })
          render_success(
            {
              classes: TeacherClassSerializer.serialize_collection(result[:records]),
              pagination: result[:pagination]
            },
            :ok
          )
        else
          render_error(classes_result.errors, :unprocessable_entity)
        end
      end

      # GET /api/v1/teacher/classes/:id
      def show
        service = TeacherClassService.new(@teacher)
        class_detail = service.get_class_detail(params[:id])
        
        if class_detail.success?
          render_success(TeacherClassSerializer.serialize_detail(class_detail.data), :ok)
        else
          render_error(class_detail.errors, :unprocessable_entity)
        end
      end

      # GET /api/v1/teacher/classes/:id/pending_requests
      def pending_requests
        service = TeacherClassService.new(@teacher)
        result = service.get_pending_requests(params[:id])
        
        if result.success?
          render_success(result.data, :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # POST /api/v1/teacher/classes/:id/enrollments/:enrollment_id/approve
      def approve_enrollment
        service = TeacherClassService.new(@teacher)
        result = service.approve_enrollment(params[:id], params[:enrollment_id])
        
        if result.success?
          render_success(result.data, :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # POST /api/v1/teacher/classes/:id/enrollments/:enrollment_id/reject
      def reject_enrollment
        service = TeacherClassService.new(@teacher)
        result = service.reject_enrollment(params[:id], params[:enrollment_id])
        
        if result.success?
          render_success(result.data, :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # POST /api/v1/teacher/classes/:id/leave_requests/:leave_request_id/approve
      def approve_leave_request
        service = TeacherClassService.new(@teacher)
        result = service.approve_leave_request(params[:id], params[:leave_request_id], params[:teacher_note])
        
        if result.success?
          render_success(result.data, :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # POST /api/v1/teacher/classes/:id/leave_requests/:leave_request_id/reject
      def reject_leave_request
        service = TeacherClassService.new(@teacher)
        result = service.reject_leave_request(params[:id], params[:leave_request_id], params[:teacher_note])
        
        if result.success?
          render_success(result.data, :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # POST /api/v1/teacher/classes/:id/students
      def add_student
        service = TeacherClassService.new(@teacher)
        result = service.add_student(params[:id], params[:student_id])
        
        if result.success?
          render_success(result.data, :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # DELETE /api/v1/teacher/classes/:id/students/:student_id
      def remove_student
        service = TeacherClassService.new(@teacher)
        result = service.remove_student(params[:id], params[:student_id])
        
        if result.success?
          render_success(result.data, :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # GET /api/v1/teacher/classes/:id/search_students
      def search_students
        service = TeacherClassService.new(@teacher)
        result = service.search_students(params[:query])
        
        if result.success?
          render_success(result.data, :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # GET /api/v1/teacher/classes/:id/schedule
      def schedule
        service = TeacherClassService.new(@teacher)
        result = service.get_class_schedule(params[:id])
        
        if result.success?
          render_success(result.data, :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # POST /api/v1/teacher/classes/:id/attendance_sessions
      def create_attendance_session
        service = TeacherClassService.new(@teacher)
        result = service.create_attendance_session(
          params[:id], 
          attendance_session_params[:date], 
          attendance_session_params[:time],
          attendance_session_params[:teacher_note]
        )
        
        if result.success?
          render_success(result.data, :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # PATCH /api/v1/teacher/classes/:id/attendance_sessions/:session_id
      def update_attendance_session
        service = TeacherClassService.new(@teacher)
        result = service.update_attendance_session(
          params[:id], 
          params[:session_id], 
          attendance_session_params[:date],
          attendance_session_params[:time],
          attendance_session_params[:teacher_note]
        )
        
        if result.success?
          render_success(result.data, :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # DELETE /api/v1/teacher/classes/:id/attendance_sessions/:session_id
      def delete_attendance_session
        service = TeacherClassService.new(@teacher)
        result = service.delete_attendance_session(params[:id], params[:session_id])
        
        if result.success?
          render_success(result.data, :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # PATCH /api/v1/teacher/classes/:id/schedule
      def update_schedule
        service = TeacherClassService.new(@teacher)
        result = service.update_class_schedule(params[:id], params[:schedule])
        
        if result.success?
          render_success(result.data, :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # PATCH /api/v1/teacher/classes/:id
      def update
        service = TeacherClassService.new(@teacher)
       
        update_params = class_params.to_h
        update_params[:cover_image_file] = params[:cover_image_file] if params[:cover_image_file].present?
        result = service.update_class(params[:id], update_params)
        
        if result.success?
          render_success(TeacherClassSerializer.serialize_detail(result.data), :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # DELETE /api/v1/teacher/classes/:id
      def destroy
        service = TeacherClassService.new(@teacher)
        result = service.delete_class(params[:id])
        
        if result.success?
          render_success(result.data, :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # GET /api/v1/teacher/classes/finance/stats (all classes)
      def finance_stats
        service = TeacherClassService.new(@teacher)
        result = service.get_all_finance_stats
        
        if result.success?
          render_success(result.data, :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # GET /api/v1/teacher/classes/:id/finance
      def finance
        service = TeacherClassService.new(@teacher)
        result = service.get_class_finance(params[:id], query_params[:search])
        
        if result.success?
          render_success(result.data, :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # POST /api/v1/teacher/classes/:id/enrollments/:enrollment_id/record_payment
      def record_payment
        service = TeacherClassService.new(@teacher)
        result = service.record_payment(
          params[:id],
          params[:enrollment_id],
          payment_params
        )
        
        if result.success?
          render_success(result.data, :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # POST /api/v1/teacher/classes/:id/enrollments/:enrollment_id/send_reminder
      def send_reminder
        service = TeacherClassService.new(@teacher)
        result = service.send_reminder(
          params[:id],
          params[:enrollment_id],
          params[:message]
        )
        
        if result.success?
          render_success(result.data, :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # POST /api/v1/teacher/classes/:id/send_all_reminders
      def send_all_reminders
        service = TeacherClassService.new(@teacher)
        result = service.send_all_reminders(params[:id])
        
        if result.success?
          render_success(result.data, :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # GET /api/v1/teacher/classes/:id/enrollments/:enrollment_id/payment_history
      def payment_history
        service = TeacherClassService.new(@teacher)
        result = service.get_payment_history(
          params[:id],
          params[:enrollment_id],
          query_params[:page],
          query_params[:per_page]
        )
        
        if result.success?
          render_success(result.data, :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # POST /api/v1/teacher/classes/:id/enrollments/:enrollment_id/create_invoice
      def create_invoice
        service = TeacherClassService.new(@teacher)
        result = service.create_invoice_for_student(
          params[:id],
          params[:enrollment_id],
          invoice_params
        )
        
        if result.success?
          render_success(TuitionInvoiceSerializer.serialize(result.data), :created)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # GET /api/v1/teacher/classes/:id/pending_transactions
      def pending_transactions
        school_class = SchoolClass.find_by(id: params[:id], teacher_id: @teacher.user_id)
        return render_error({ error: 'Class not found' }, :not_found) unless school_class

        invoices = school_class.tuition_invoices
        transactions = Transaction.where(tuition_invoice_id: invoices.pluck(:id))
                                  .where(status: 'pending')
                                  .includes(tuition_invoice: { student: :user })
                                  .order(created_at: :desc)

        result = paginate(transactions, { per_page: query_params[:per_page] || 20, page: query_params[:page] || 1 })

        render_success(
          {
            transactions: result[:records].map do |txn|
              invoice = txn.tuition_invoice
              student = invoice.student
              user = student.user
              
              {
                id: txn.id,
                student_id: student.id,
                student_name: user.full_name,
                invoice_code: invoice.invoice_code,
                amount: txn.amount.to_i,
                method: txn.method,
                status: txn.status,
                payment_date: txn.payment_date.strftime('%d/%m/%Y'),
                description: txn.description,
                created_at: txn.created_at.strftime('%d/%m/%Y %H:%M')
              }
            end,
            pagination: result[:pagination]
          },
          :ok
        )
      end

      private

      def set_teacher
        @teacher = @current_user.teacher
        return render_error('Teacher profile not found', :not_found) unless @teacher
      end

      def query_params
        params.permit(:page, :per_page, :status, :search, :id)
      end

      def attendance_session_params
        params.permit(:date, :time, :teacher_note)
      end

      def class_params
        params.permit(:name, :subject, :grade_level, :description, :monthly_tuition_fee, :status, :cover_image, schedule_data: [:day, :start_time, :end_time])
      end

      def payment_params
        params.permit(:amount, :method, :note)
      end

      def invoice_params
        params.require(:invoice).permit(:title, :description, :amount, :due_date, :status)
      end
    end
  end
end
