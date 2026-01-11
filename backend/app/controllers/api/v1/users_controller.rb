# frozen_string_literal: true

module Api
  module V1
    class UsersController < BaseController
      before_action :set_user, only: %i[show update destroy]

      # GET /api/v1/users
      def index
        users = User.all
        render_success(users.map { |u| UserSerializer.serialize(u) })
      end

      # GET /api/v1/users/:id
      def show
        render_success(UserSerializer.serialize(@user))
      end

      # POST /api/v1/users
      def create
        result = UserService.new.create(user_params)

        if result.success?
          render_success(UserSerializer.serialize(result.data), :created)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # PATCH/PUT /api/v1/users/:id
      def update
        result = UserService.new.update(@user, user_params)

        if result.success?
          render_success(UserSerializer.serialize(result.data))
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # DELETE /api/v1/users/:id
      def destroy
        result = UserService.new.delete(@user)

        if result.success?
          render_success(result.data)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.require(:user).permit(:email, :name, :password)
      end
    end
  end
end
