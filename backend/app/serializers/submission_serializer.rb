# frozen_string_literal: true

class SubmissionSerializer
  attr_reader :submission

  def initialize(submission)
    @submission = submission
  end

  def serialize
    file_url = if submission.file.attached?
                 Rails.application.routes.url_helpers.rails_blob_path(submission.file, only_path: true)
               end

    {
      id: submission.id,
      assignment_id: submission.assignment_id,
      student_id: submission.student_id,
      content: submission.content,
      file_url: file_url,
      file_name: submission.file.attached? ? submission.file.filename.to_s : nil,
      submitted_at: submission.submitted_at,
      status: submission.status,
      score: submission.score,
      teacher_feedback: submission.teacher_feedback
    }
  end

  def self.serialize_collection(submissions)
    submissions.map { |submission| new(submission).serialize }
  end

  def self.serialize(submission)
    new(submission).serialize
  end
end