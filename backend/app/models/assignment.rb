# frozen_string_literal: true

class Assignment < ApplicationRecord
  # Associations
  belongs_to :school_class, class_name: 'SchoolClass', foreign_key: 'class_id', inverse_of: :assignments
  has_many :assignment_attachments, dependent: :destroy
  has_many :submissions, dependent: :destroy

  # Validations
  validates :title, presence: true
  validates :title, length: { minimum: 3, maximum: 200 }
  validates :type, inclusion: { in: %w[homework test project] }, allow_nil: true

  # Enums
  enum assignment_type: { homework: 'homework', test: 'test', project: 'project' }, _suffix: true

  # Scopes
  scope :by_class, ->(class_id) { where(class_id: class_id) }
  scope :upcoming, -> { where('due_date > ?', Time.current).order(due_date: :asc) }
  scope :overdue, -> { where('due_date < ?', Time.current) }
  scope :recent, -> { order(created_at: :desc) }
  scope :search_by_title, ->(keyword) { where('title LIKE ?', "%#{keyword}%") }
  scope :by_submission_status, lambda { |status|
    joins(:submissions).where(submissions: { status: status })
  }
  scope :by_submission_status_for_student, lambda { |status, student_id|
    joins(:submissions)
      .where(submissions: { status: status, student_id: student_id })
  }

 scope :no_submission_for_student, lambda { |student_id|
    left_joins(:submissions)
      .where(submissions: { id: nil })
  }

  scope :by_class_subject, lambda { |subject|
    joins(:school_class).where(
      classes: { subject: subject }
    )
  }

  # Methods
  def overdue?
    due_date.present? && due_date < Time.current
  end

  delegate :count, to: :submissions, prefix: true

  def graded_submissions_count
    submissions.where(status: 'graded').count
  end

  def submitted_submissions_count
    submissions.where(status: %w[submitted late]).count
  end

  def submission_status_for_student(student)
    latest_submission = submissions
      .select { |s| s.student_id == student.id }
      .max_by(&:submitted_at)
    return 'no_submission' unless latest_submission

    latest_submission.status
  end
end
