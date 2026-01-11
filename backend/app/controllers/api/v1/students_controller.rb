# frozen_string_literal: true

module Api
  module V1
    class StudentsController < Api::V1::BaseController
      before_action :set_student, only: %i[show update destroy]
      before_action :set_profile, only: %i[change_profile user_profile]

      # GET /api/v1/students
      def index
        students = Student.all
        render_success(students.map { |s| StudentSerializer.serialize(s) })
      end

      # GET /api/v1/students/:id
      def show
        render_success(StudentSerializer.serialize(@student))
      end

      # GET /api/v1/students/profile
      def user_profile
        render_success(StudentSerializer.serialize(@user_profile), :ok)
      end

      # PATCH /api/v1/students/profile

      def change_profile
        result = StudentService.new.update(@user_profile, student_params)

        if result.success?
          render_success(StudentSerializer.serialize(result.data))
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # POST /api/v1/students
      def create
        result = StudentService.new.create(student_params)

        if result.success?
          render_success(StudentSerializer.serialize(result.data), :created)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # PATCH/PUT /api/v1/students/:id
      def update
        result = StudentService.new.update(@student, student_params)
        if result.success?
          render_success(StudentSerializer.serialize(result.data))
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # DELETE /api/v1/students/:id
      def destroy
        result = StudentService.new.delete(@student)

        if result.success?
          render_success(result.data)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      private

      def set_student
        @student = Student.find(params[:id])
      end

      def student_params
        params.require(:student).permit(:dob, :address, :school, :note)
      end

      def set_profile
        @user_profile = @current_user.student_profile
      end
    end
  end
end
