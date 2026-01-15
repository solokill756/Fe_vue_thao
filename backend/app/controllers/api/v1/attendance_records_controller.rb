# frozen_string_literal: true

module Api
  module V1
    class AttendanceRecordsController < Api::V1::BaseController
      before_action :load_session

      # GET /api/v1/classes/:class_id/attendance_sessions/:attendance_session_id/attendance_records
      def index
        render_success(@session.attendance_records.includes(:student), :ok)
      end

      # POST /api/v1/classes/:class_id/attendance_sessions/:attendance_session_id/attendance_records
      def create
        record = @session.attendance_records.find_or_initialize_by(student_id: record_params[:student_id])
        if record.update(record_params.except(:student_id))
          render_success(record, :created)
        else
          render_error(record.errors.messages, :unprocessable_entity)
        end
      end

      # PATCH/PUT /api/v1/classes/:class_id/attendance_sessions/:attendance_session_id/attendance_records/:id
      def update
        record = @session.attendance_records.find(params[:id])
        if record.update(record_params.except(:student_id))
          render_success(record, :ok)
        else
          render_error(record.errors.messages, :unprocessable_entity)
        end
      end

      private

      def load_session
        @session = AttendanceSession.find(params[:attendance_session_id])
      end

      def record_params
        params.require(:attendance_record).permit(:student_id, :status, :note, :score_in_class)
      end
    end
  end
end

