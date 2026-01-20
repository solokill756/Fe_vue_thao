# frozen_string_literal: true

class AssignmentAttachment < ApplicationRecord
  # Associations
  belongs_to :assignment
  has_one_attached :file, dependent: :destroy

  # Validations
  validates :file_name, length: { maximum: 255 }, allow_blank: true

  # Scopes
  scope :by_assignment, lambda { |assignment_id|
                          where(assignment_id:)
                        }
  
  # Get file URL from Active Storage
  # If file_url column has value, use it; otherwise generate from Active Storage
  def file_url
    # If database column has value, use it (for backward compatibility)
    return read_attribute(:file_url) if read_attribute(:file_url).present?
    
    # Otherwise, generate from Active Storage
    return nil unless file.attached?
    Rails.application.routes.url_helpers.rails_blob_path(file, only_path: true)
  end
end
