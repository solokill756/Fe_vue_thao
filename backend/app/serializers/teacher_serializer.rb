# frozen_string_literal: true

class TeacherSerializer < ApplicationRecord::Serializer
  attributes :user_id, :bio, :qr_code, :package_id, :package_expiry, :rating_avg,
             :created_at, :updated_at

  belongs_to :user
  belongs_to :package, optional: true
  has_many :classes
end
