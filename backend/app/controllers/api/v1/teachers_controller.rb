# frozen_string_literal: true

module Api
  module V1
    class TeachersController < Api::V1::BaseController
      before_action :set_teacher, only: [:show, :update, :destroy]

      # GET /api/v1/teachers
      def index
        teachers = Teacher.all.includes(:user)
        render_success(teachers.map { |t| TeacherSerializer.serialize(t) })
      end

      # GET /api/v1/teachers/:id
      def show
        render_success(TeacherSerializer.serialize(@teacher))
      end

      # POST /api/v1/teachers
      def create
        # Implementation if needed
        render_error({ error: 'Not implemented' }, :not_implemented)
      end

      # PATCH/PUT /api/v1/teachers/:id
      def update
        # Implementation if needed
        render_error({ error: 'Not implemented' }, :not_implemented)
      end

      # DELETE /api/v1/teachers/:id
      def destroy
        # Implementation if needed
        render_error({ error: 'Not implemented' }, :not_implemented)
      end

      # POST /api/v1/teachers/upload_qr_code
      def upload_qr_code
        teacher = @current_user.teacher
        return render_error({ error: 'Teacher profile not found' }, :not_found) unless teacher

        result = upload_qr_code_service(teacher, params[:qr_code])
        if result[:success]
          render_success(result[:data])
        else
          render_error(result[:errors], :unprocessable_entity)
        end
      end

      private

      def set_teacher
        @teacher = Teacher.find_by(user_id: params[:id])
        render_error({ error: 'Teacher not found' }, :not_found) unless @teacher
      end

      def upload_qr_code_service(teacher, file)
        return { success: false, errors: { qr_code: ['No file uploaded'] } } if file.blank?

        uploaded_file = Cloudinary::Uploader.upload(file)
        teacher.update(qr_code: uploaded_file['secure_url'])
        { success: true, data: { qr_code: uploaded_file['secure_url'] } }
      rescue StandardError => e
        { success: false, errors: { qr_code: [e.message] } }
      end
    end
  end
end
