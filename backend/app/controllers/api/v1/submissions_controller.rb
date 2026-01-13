# frozen_string_literal: true

module Api
  module V1
    class SubmissionsController < Api::V1::BaseController
      skip_before_action :authenticate_request!, only: [:file_url_submission]
      # POST /api/v1/submissions
      def create
        student = @current_user.student_profile
        result = SubmissionService.new.create(submission_params, student.id)
        if result.success?
          render_success(SubmissionSerializer.serialize(result.data), :created)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # GET /api/v1/submissions/list-by-student
      def list_by_student
        student = @current_user.student_profile
        result = SubmissionService.new.list_by_student(student.id, query_params[:assignment_id])
        if result.success?
          submissions = result.data.recent
          ans = paginate(submissions, { per_page: query_params[:per_page] || 10, page: query_params[:page] || 1 })
          render_success(
            {
              submissions: SubmissionSerializer.serialize_collection(ans[:records]),
              pagination: ans[:pagination]
            },
            :ok
          )
        else
          render_error(result.errors, :bad_request)
        end
      end

      # GET /api/v1/submissions/:id/file-url
      def file_url_submission
        submission = Submission.find(params[:id])

        unless submission.file.attached?
          return render_error('No file associated with this submission', :not_found)
        end

        send_data submission.file.download,
                  filename: submission.file.filename.to_s,
                  disposition: 'attachment',
                  type: submission.file.content_type
      rescue ActiveRecord::RecordNotFound
        render_error('Submission not found', :not_found)
      rescue StandardError => e
        render_error(e.message, :internal_server_error)
      end

      private

      def submission_params
        params.require(:submission).permit(:assignment_id, :content,
                                           :file, :submitted_at)
      end

      def query_params
        params.permit(:page, :per_page, :assignment_id)
      end
    end
  end
end
