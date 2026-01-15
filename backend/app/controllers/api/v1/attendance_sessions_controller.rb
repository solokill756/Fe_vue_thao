# frozen_string_literal: true

module Api
  module V1
    class AttendanceSessionsController < Api::V1::BaseController
      # GET /api/v1/classes/:class_id/attendance_sessions
      def index
        student = @current_user.student_profile
        class_id = params[:class_id]

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

