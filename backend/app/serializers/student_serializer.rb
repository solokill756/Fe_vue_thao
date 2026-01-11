# frozen_string_literal: true

class StudentSerializer
  def initialize(student)
    @student = student
  end

  def serialize
    {
      id: @student.id,
      full_name: @student.user&.full_name,
      email: @student.user&.email,
      dob: @student.dob,
      parent_name: @student.parent_name,
      parent_phone: @student.parent_phone,
      school: @student.school,
      note: @student.note,
      student_code: @student.student_code,
      wallet_balance: @student.wallet_balance,
      class_count: @student.school_classes.count,
      created_at: @student.created_at,
      updated_at: @student.updated_at,
      phone_number: @student.user&.phone_number,
      address: @student.address,
      avatar: @student.user&.photo_url,
      parent_linked_at: @student.parent_student_links.order(created_at: :desc).first&.created_at
    }
  end

  def self.serialize(student)
    new(student).serialize
  end
end
