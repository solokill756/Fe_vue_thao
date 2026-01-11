# frozen_string_literal: true

class LeaveRequestService
  def initialize(student_id, class_id)
    @student_id = student_id
    @class_id = class_id
    @student = Student.find(student_id)
    @school_class = SchoolClass.find(class_id)
  end

  def create(params)
    result = validate_enrollment

    return result if result.failure?

    leave_request = LeaveRequest.new(params)
    leave_request.student_id = @student_id
    leave_request.class_id = @class_id

    if leave_request.save
      Result.success(leave_request)
    else
      Result.failure(leave_request.errors.full_messages)
    end
  end

  private

  def validate_enrollment
    enrollment = @student.enrollments.find_by(class_id: @class_id, status: 'active')

    return Result.failure(['Student is not enrolled in this class']) unless enrollment

    Result.success(enrollment)
  end
end
