# frozen_string_literal: true

class AssignmentSerializer
  attr_reader :assignment

  def initialize(assignment, student)
    @assignment = assignment
    @student = student
  end

  def serialize
    {
      id: assignment.id,
      title: assignment.title,
      content: assignment.content,
      due_date: assignment.due_date,
      created_at: assignment.created_at,
      school_class: serialize_school_class(assignment&.school_class),
      teacher_name: assignment&.school_class&.teacher&.user&.full_name,
      submission_status: @student ? assignment.submission_status_for_student(@student) : nil,
      assignment_attachments: serialize_assignment_attachments(assignment.assignment_attachments),
      submissions: assignment.latest_submissions_per_student.any? ? SubmissionSerializer.serialize_collection(assignment.latest_submissions_per_student) : [],
      submissions_count: assignment.submissions_count,
      graded_submissions_count: assignment.graded_submissions_count,
    }
  end

  private

  def serialize_school_class(school_class)
    return nil unless school_class

    {
      id: school_class.id,
      name: school_class.name,
      subject: school_class.subject,
      grade_level: school_class.grade_level,
      code: "CLASS#{school_class.id.to_s.rjust(4, '0')}", 
      students_count: school_class.student_count,
      status: school_class.status,
      created_at: school_class.created_at,
      updated_at: school_class.updated_at
    }
  end

  def serialize_assignment_attachments(attachments)
    return [] unless attachments.any?
    
    attachments.map do |attachment|
      # Use download endpoint URL instead of direct Active Storage URL
      # Similar to how submissions work
      file_url = if attachment.file.attached?
                   Rails.application.routes.url_helpers.file_url_api_v1_assignment_attachment_path(attachment, only_path: true)
                 else
                   nil
                 end
      
      {
        id: attachment.id,
        file_url: file_url,
        file_name: attachment.file_name || (attachment.file.attached? ? attachment.file.filename.to_s : nil)
      }
    end
  end

  def self.serialize_collection(assignments, student = nil)
    assignments.map { |assignment| new(assignment, student).serialize }
  end

  def self.serialize(assignment, student = nil)
    new(assignment, student).serialize
  end
end
