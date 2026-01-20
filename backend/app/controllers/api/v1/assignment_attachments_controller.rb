# frozen_string_literal: true

module Api
  module V1
    class AssignmentAttachmentsController < Api::V1::BaseController
      skip_before_action :authenticate_request!, only: [:file_url]

      # GET /api/v1/assignment_attachments/:id/file-url
      def file_url
        attachment = AssignmentAttachment.find(params[:id])

        unless attachment.file.attached?
          return render_error('No file associated with this attachment', :not_found)
        end

        send_data attachment.file.download,
                  filename: attachment.file.filename.to_s,
                  disposition: 'attachment',
                  type: attachment.file.content_type
      rescue ActiveRecord::RecordNotFound
        render_error('Attachment not found', :not_found)
      rescue StandardError => e
        render_error(e.message, :internal_server_error)
      end
    end
  end
end
