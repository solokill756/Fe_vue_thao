# frozen_string_literal: true

module Api
  module V1
    class AttendanceSessionsController < Api::V1::BaseController
      # GET /api/v1/classes/:class_id/attendance_sessions
      def index
        class_id = params[:class_id]
        
        if @current_user.role == 'teacher'
          class_obj = SchoolClass.find_by(id: class_id)
          return render_error('Class not found', :not_found) unless class_obj
          
          sessions = AttendanceSession.where(class_id: class_id)
                                     .order(date: :desc)
          paginated = paginate(sessions, { per_page: query_params[:per_page] || 10, page: query_params[:page] || 1 })
          
          render_success(
            {
              sessions: paginated[:records].map do |session|
                {
                  id: session.id,
                  date: session.date.iso8601,
                  date_display: session.date.strftime('%d/%m/%Y'),
                  time_display: session.date.strftime('%H:%M'),
                  teacher_note: session.teacher_note,
                  class_id: session.class_id
                }
              end,
              pagination: paginated[:pagination]
            },
            :ok
          )
        else
          student = @current_user.student_profile
          return render_error('Student profile not found', :forbidden) unless student

          result = AttendanceService.new.list_sessions_for_student(class_id, student.id)
          return render_error(result.errors, :forbidden) unless result.success?

          sessions = result.data
          paginated = paginate(sessions, { per_page: query_params[:per_page] || 10, page: query_params[:page] || 1 })

          render_success(
            {
              sessions: StudentAttendanceSessionSerializer.serialize_collection(paginated[:records], student.id),
              pagination: paginated[:pagination]
            },
            :ok
          )
        end
      end

      # GET /api/v1/attendance_sessions/:id
      def show
        session = AttendanceSession.includes(:attendance_records).find(params[:id])
        render_success(session, :ok)
      end

      private
      
      def query_params
        params.permit(:page, :per_page)
      end
    end
  end
end

