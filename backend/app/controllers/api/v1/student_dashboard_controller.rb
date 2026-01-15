# frozen_string_literal: true

module Api
  module V1
    class StudentDashboardController < Api::V1::BaseController
      before_action :set_student

      # GET /api/v1/student-dashboard
      def show
        service = StudentDashboardService.new(@student)
        dashboard_data = service.build_dashboard_data
        render_success(dashboard_data, :ok)
      end

      private

      def set_student
        @student = @current_user.student_profile
        return render_error('Student profile not found', :not_found) unless @student
      end
    end
  end
end
