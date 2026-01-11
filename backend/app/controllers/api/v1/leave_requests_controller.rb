# frozen_string_literal: true

module Api
  module V1
    class LeaveRequestsController < Api::V1::BaseController
      before_action :set_leave_request, only: %i[show update destroy approve reject]
      # GET /api/v1/classes/:class_id/leave_requests
      def index
        leave_requests = LeaveRequest.for_class(params[:class_id]).order(date: :desc)
        leave_requests = leave_requests.where(status: query_params[:status]) if query_params[:status].present?
        result = paginate(leave_requests, { per_page: query_params[:per_page] || 10, page: query_params[:page] || 1 })
        render_success(
          {
            leave_requests: LeaveRequestSerializer.serialize_collection(result[:records]),
            pagination: result[:pagination]
          },
          :ok
        )
      end

      # GET /api/v1/leave_requests/:id
      def show
        render_success(LeaveRequestSerializer.serialize(@leave_request))
      end

      # POST /api/v1/classes/:class_id/leave_requests
      def create
        service = LeaveRequestService.new(@current_user.student_profile.id, params[:class_id])
        result = service.create(leave_request_params)

        if result.success?
          render_success(LeaveRequestSerializer.serialize(result.data), :created)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      rescue StandardError => e
        render_error(e.message, :unprocessable_entity)
      end

      # PATCH/PUT /api/v1/leave_requests/:id
      def update
        if @leave_request.update(leave_request_params)
          render_success(LeaveRequestSerializer.serialize(@leave_request))
        else
          render_error(@leave_request.errors.full_messages, :unprocessable_entity)
        end
      end

      # DELETE /api/v1/leave_requests/:id
      def destroy
        @leave_request.destroy
        render_success({ message: 'Leave request deleted successfully' }, :no_content)
      end

      # PATCH /api/v1/leave_requests/:id/approve
      def approve
        if @leave_request.approve(current_user.id)
          render_success(LeaveRequestSerializer.serialize(@leave_request))
        else
          render_error(@leave_request.errors.full_messages, :unprocessable_entity)
        end
      end

      # PATCH /api/v1/leave_requests/:id/reject
      def reject
        if @leave_request.reject
          render_success(LeaveRequestSerializer.serialize(@leave_request))
        else
          render_error(@leave_request.errors.full_messages, :unprocessable_entity)
        end
      end

      private

      def set_leave_request
        @leave_request = LeaveRequest.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_error('Leave request not found', :not_found)
      end

      def leave_request_params
        params.require(:leave_request).permit(:date, :reason, :status, :teacher_note, :leave_type)
      end

      def query_params
        params.permit(:page, :per_page, :status)
      end
    end
  end
end
