# frozen_string_literal: true

class User < ApplicationRecord
  self.inheritance_column = :_type_sti_disabled

  has_secure_password

  # Associations
  has_one :teacher, dependent: :destroy
  has_one :student_profile, class_name: 'Student',
                            dependent: :destroy
  has_many :parent_student_links, foreign_key: 'parent_id', dependent: :destroy, inverse_of: :parent
  has_many :linked_students, through: :parent_student_links, source: :student
  has_many :ai_conversations, foreign_key: 'teacher_id', dependent: :destroy, inverse_of: :teacher

  # Validations
  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :display_name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :password_digest, presence: true
  validates :role, inclusion: { in: %w[teacher admin student parent] }

  # Scopes
  scope :teachers, -> { where(role: 'teacher') }
  scope :students, -> { where(role: 'student') }
  scope :parents, -> { where(role: 'parent') }
  scope :admins, -> { where(role: 'admin') }
  scope :active, -> { where(is_active: true) }

  # Callbacks
  before_save :mark_active_if_fully_approved, unless: :marked_for_destruction?

  private

  def mark_active_if_fully_approved
    # Skip if user is being destroyed
    return if marked_for_destruction? || destroyed?
    
    # Only auto-activate when otp_verified changes from false to true
    # Don't override is_active if it's being explicitly set (e.g., by admin)
    return unless otp_verified?
    
    # If is_active is being changed in this save, don't override it (admin is setting it)
    return if will_save_change_to_is_active?
    
    # Only auto-activate if otp_verified was just changed to true
    if new_record? || saved_change_to_otp_verified?
      self.is_active = true
    end
  end
end
