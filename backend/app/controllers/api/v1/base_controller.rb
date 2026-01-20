# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      include ErrorHandler

      before_action :authenticate_request!

      protected

      # Pagination helper method
      def paginate(records, options = {})
        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || options[:per_page] || 10).to_i
        # Ensure reasonable values
        page = 1 if page < 1
        per_page = 1 if per_page < 1
        per_page = 100 if per_page > 100
        # Get total count and paginated records efficiently
        offset = (page - 1) * per_page
        total_count = records.count
        total_pages = (total_count.to_f / per_page).ceil
        paginated_records = records.limit(per_page).offset(offset)
        {
          records: paginated_records,
          pagination: {
            current_page: page,
            per_page: per_page,
            total_count: total_count,
            total_pages: total_pages
          }
        }
      end

      def check_teacher_role
        return if @current_user.role == 'teacher'
        render_error 'Unauthorized access', :unauthorized
      end

      def check_admin_role
        return if @current_user.role == 'admin'
        render_error 'Unauthorized access. Admin only.', :unauthorized
      end

      private

      def authenticate_request!
        header = request.headers['Authorization']
        token = header.split.last if header

        unless token
          render_error 'Missing authentication token', :unauthorized
          return
        end

        begin
          decoded = JWT.decode(
            token,
            Rails.application.secrets.secret_key_base,
            true,
            { algorithm: 'HS256' }
          )[0]
          
          @current_user = User.find(decoded['user_id'])
          
          # Check if user account is active
          unless @current_user.is_active?
            render_error 'Account has been deactivated', :forbidden
            return
          end
        rescue JWT::ExpiredSignature
          render_error 'Token has expired', :unauthorized
        rescue JWT::DecodeError, ActiveRecord::RecordNotFound
          render_error 'Unauthorized access', :unauthorized
        end
      end
      
    end
  end
end
