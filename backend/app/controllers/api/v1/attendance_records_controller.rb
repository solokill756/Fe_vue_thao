# frozen_string_literal: true

module Api
  module V1
    class AttendanceRecordsController < Api::V1::BaseController
      before_action :load_session
      before_action :initialize_service

      # GET /api/v1/classes/:class_id/attendance_sessions/:attendance_session_id/attendance_records
      def index
        result = @service.list_records
        if result.success?
          render_success(result.data, :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # POST /api/v1/classes/:class_id/attendance_sessions/:attendance_session_id/attendance_records
      def create
        result = @service.create_or_update_record(record_params)
        if result.success?
          render_success(result.data, :created)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # PATCH/PUT /api/v1/classes/:class_id/attendance_sessions/:attendance_session_id/attendance_records/:id
      def update
        result = @service.update_record(params[:id], record_params)
        if result.success?
          render_success(result.data, :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      private

      def load_session
        @session = AttendanceSession.find(params[:attendance_session_id])
      end

      def initialize_service
        @service = AttendanceRecordService.new(@session)
      end

      def record_params
        params.require(:attendance_record).permit(:student_id, :status, :note, :score_in_class)
      end
    end
  end
end

