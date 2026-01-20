# frozen_string_literal: true

module Api
  module V1
    class AdminsController < Api::V1::BaseController
      before_action :check_admin_role
      before_action :set_user, only: [:show, :update, :destroy, :toggle_status]

      # GET /api/v1/admin/users
      def users
        users_query = User.where.not(role: 'admin')
        
        # Filter by role
        users_query = users_query.where(role: query_params[:role]) if query_params[:role].present?
        
        # Filter by status
        if query_params[:status].present?
          if query_params[:status] == 'active'
            users_query = users_query.active
          elsif query_params[:status] == 'inactive'
            users_query = users_query.where(is_active: false)
          end
        end
        
        # Search by email or full_name
        if query_params[:search].present?
          search_term = "%#{query_params[:search]}%"
          users_query = users_query.where("email LIKE ? OR full_name LIKE ?", search_term, search_term)
        end
        
        result = paginate(users_query.order(created_at: :desc), { 
          per_page: query_params[:per_page] || 20, 
          page: query_params[:page] || 1 
        })
        
        render_success({
          users: result[:records].map { |u| UserSerializer.serialize(u) },
          pagination: result[:pagination]
        }, :ok)
      end

      # GET /api/v1/admin/users/:id
      def show
        render_success(UserSerializer.serialize(@user), :ok)
      end

      # POST /api/v1/admin/users
      def create
        result = AdminUserService.new.create(user_params, skip_otp: true)
        
        if result.success?
          render_success(UserSerializer.serialize(result.data), :created)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # PATCH/PUT /api/v1/admin/users/:id
      def update
        result = AdminUserService.new.update(@user, user_params)
        
        if result.success?
          render_success(UserSerializer.serialize(result.data), :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # DELETE /api/v1/admin/users/:id
      def destroy
        result = AdminUserService.new.delete(@user)
        
        if result.success?
          render_success(result.data, :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # PATCH /api/v1/admin/users/:id/toggle-status
      def toggle_status
        new_status = !@user.is_active
        result = AdminUserService.new.update(@user, { is_active: new_status })
        
        if result.success?
          render_success(UserSerializer.serialize(result.data), :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # GET /api/v1/admin/pending-users (existing endpoint)
      def pending_users
        pending_users = User.where(is_active: false, role: ['teacher', 'student'])
        render_success(pending_users.map { |u| UserSerializer.serialize(u) }, :ok)
      end

      # POST /api/v1/admin/approve-user (existing endpoint)
      def approve_user
        user = User.find_by(id: params[:user_id])
        return render_error({ error: 'User not found' }, :not_found) unless user
        
        user.update(is_active: true, otp_verified: true)
        render_success(UserSerializer.serialize(user), :ok)
      end

      # POST /api/v1/admin/reject-user (existing endpoint)
      def reject_user
        user = User.find_by(id: params[:user_id])
        return render_error({ error: 'User not found' }, :not_found) unless user
        
        # Optionally delete the user or just mark as rejected
        user.destroy
        render_success({ message: 'User rejected and deleted' }, :ok)
      end

      private

      def check_admin_role
        return if @current_user.role == 'admin'
        render_error 'Unauthorized access. Admin only.', :unauthorized
      end

      def set_user
        @user = User.find_by(id: params[:id])
        render_error({ error: 'User not found' }, :not_found) unless @user
        render_error({ error: 'Cannot modify admin user' }, :forbidden) if @user&.role == 'admin'
      end

      def user_params
        params.require(:user).permit(:email, :full_name, :password, :role, :is_active, :phone_number)
      end

      def query_params
        params.permit(:page, :per_page, :role, :status, :search)
      end
    end
  end
end
