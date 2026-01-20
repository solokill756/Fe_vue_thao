# frozen_string_literal: true

class UserSerializer
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def serialize
    {
      id: user.id,
      email: user.email,
      full_name: user.full_name,
      role: user.role,
      created_at: user.created_at,
      updated_at: user.updated_at,
      phone_number: user.phone_number,
      photo_url: user.photo_url,
      teacher_qr_code: user.teacher&.qr_code,
      is_active: user.is_active,
      otp_verified: user.otp_verified,
    }
  end

  def self.serialize(user)
    new(user).serialize
  end
end
