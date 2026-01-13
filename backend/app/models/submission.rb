# frozen_string_literal: true

class Submission < ApplicationRecord
  # Associations
  belongs_to :assignment
  belongs_to :student
  has_one_attached :file, dependent: :destroy

  # Validations
  validates :assignment_id, :student_id, presence: true
  validates :status, inclusion: { in: %w[submitted late graded resubmit_requested] }
  validates :score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :content, presence: true, if: -> { file.blank? }
  validate :must_have_content_or_file

  private

  def must_have_content_or_file
    return if content.present? || file.attached?
    errors.add(:base, 'Either content or file must be present')
  end

  # Enums
  enum status: { submitted: 'submitted', late: 'late', graded: 'graded', resubmit_requested: 'resubmit_requested' }

  # Scopes
  scope :submitted, -> { where(status: %w[submitted late]) }
  scope :graded, -> { where(status: 'graded') }
  scope :pending_grade, -> { where(status: %w[submitted late resubmit_requested]) }
  scope :by_student, ->(student_id) { where(student_id: student_id) }
  scope :by_assignment, ->(assignment_id) { where(assignment_id: assignment_id) }
  scope :recent, -> { order(submitted_at: :desc) }

  # Methods
  def graded?
    status == 'graded' && score.present?
  end

  def late?
    assignment.due_date.present? && submitted_at > assignment.due_date
  end

  def can_resubmit?
    status != 'graded'
  end

  def mark_as_graded(score, feedback = nil)
    update(status: 'graded', score: score, teacher_feedback: feedback)
  end
end
