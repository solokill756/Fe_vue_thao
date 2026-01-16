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
        # Merge file params separately as Rails handles file uploads differently
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

      private

      def set_teacher
        @teacher = @current_user.teacher
        return render_error('Teacher profile not found', :not_found) unless @teacher
      end

      def query_params
        params.permit(:page, :per_page, :status, :search)
      end

      def attendance_session_params
        params.permit(:date, :time, :teacher_note)
      end

      def class_params
        params.permit(:name, :subject, :grade_level, :description, :fee_per_session, :status, :cover_image, schedule_data: [:day, :start_time, :end_time])
      end
    end
  end
end
