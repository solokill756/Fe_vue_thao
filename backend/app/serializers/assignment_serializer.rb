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
      school_class: assignment&.school_class,
      teacher_name: assignment&.school_class&.teacher&.user&.full_name,
      submission_status: assignment.submission_status_for_student(@student),
      assignment_attachments: assignment.assignment_attachments,
      submissions: assignment.submissions.last ? SubmissionSerializer.serialize(assignment.submissions.last) : nil  
    }
  end

  def self.serialize_collection(assignments, student)
    assignments.map { |assignment| new(assignment, student).serialize }
  end

  def self.serialize(assignment, student)
    new(assignment, student).serialize
  end
end
