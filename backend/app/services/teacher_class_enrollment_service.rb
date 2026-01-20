# frozen_string_literal: true

class TeacherClassEnrollmentService
  def initialize(teacher)
    @teacher = teacher
  end

  def get_pending_requests(class_id)
    class_obj = find_class(class_id)
    return Result.failure({ error: 'Class not found' }) unless class_obj

    pending_enrollments = Enrollment.where(class_id: class_obj.id, status: 'pending')
                                   .includes(student: :user)
    
    pending_leave_requests = LeaveRequest.where(class_id: class_obj.id, status: 'pending')
                                         .includes(student: :user)

    enrollments_data = pending_enrollments.map do |enrollment|
      {
        id: enrollment.id,
        student_id: enrollment.student_id,
        student_name: enrollment.student.user.full_name,
        student_phone: enrollment.student.user.phone_number || 'N/A',
        created_at: enrollment.created_at
      }
    end

    leave_requests_data = pending_leave_requests.map do |request|
      {
        id: request.id,
        student_id: request.student_id,
        student_name: request.student.user.full_name,
        student_phone: request.student.user.phone_number || 'N/A',
        leave_type: request.leave_type,
        date: request.date&.strftime('%Y-%m-%d'),
        reason: request.reason,
        created_at: request.created_at
      }
    end

    Result.success({
      enrollments: enrollments_data,
      leave_requests: leave_requests_data
    })
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassEnrollmentService#get_pending_requests: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def approve_enrollment(class_id, enrollment_id)
    class_obj = find_class(class_id)
    return Result.failure({ error: 'Class not found' }) unless class_obj

    enrollment = Enrollment.find_by(id: enrollment_id, class_id: class_obj.id)
    return Result.failure({ error: 'Enrollment not found' }) unless enrollment
    if enrollment.update(status: 'active')
      Result.success({ 
        message: 'Enrollment approved successfully', 
        enrollment: { id: enrollment.id, status: enrollment.status } 
      })
    else
      Result.failure(enrollment.errors.messages)
    end
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassEnrollmentService#approve_enrollment: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def reject_enrollment(class_id, enrollment_id)
    class_obj = find_class(class_id)
    return Result.failure({ error: 'Class not found' }) unless class_obj

    enrollment = Enrollment.find_by(id: enrollment_id, class_id: class_obj.id)
    return Result.failure({ error: 'Enrollment not found' }) unless enrollment

    if enrollment.destroy
      Result.success({ message: 'Enrollment rejected successfully' })
    else
      Result.failure(enrollment.errors.messages)
    end
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassEnrollmentService#reject_enrollment: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def approve_leave_request(class_id, leave_request_id, teacher_note = nil)
    class_obj = find_class(class_id)
    return Result.failure({ error: 'Class not found' }) unless class_obj

    leave_request = LeaveRequest.find_by(id: leave_request_id, class_id: class_obj.id)
    return Result.failure({ error: 'Leave request not found' }) unless leave_request

    if leave_request.update(status: 'approved', teacher_note: teacher_note)
      if leave_request.permanent?
        enrollment = Enrollment.find_by(class_id: class_obj.id, student_id: leave_request.student_id)
        enrollment&.update(status: 'dropped')
      elsif leave_request.temporary?
        create_attendance_record_for_leave_request(leave_request, 'absent_w_reason')
      end
      Result.success({ 
        message: 'Leave request approved successfully', 
        leave_request: { id: leave_request.id, status: leave_request.status } 
      })
    else
      Result.failure(leave_request.errors.messages)
    end
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassEnrollmentService#approve_leave_request: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def reject_leave_request(class_id, leave_request_id, teacher_note = nil)
    class_obj = find_class(class_id)
    return Result.failure({ error: 'Class not found' }) unless class_obj

    leave_request = LeaveRequest.find_by(id: leave_request_id, class_id: class_obj.id)
    return Result.failure({ error: 'Leave request not found' }) unless leave_request

    if leave_request.update(status: 'rejected', teacher_note: teacher_note)
      if leave_request.temporary?
        # Tạo attendance_record cho temporary leave request khi bị reject
        create_attendance_record_for_leave_request(leave_request, 'absent_no_reason')
      end
      Result.success({ 
        message: 'Leave request rejected successfully', 
        leave_request: { id: leave_request.id, status: leave_request.status } 
      })
    else
      Result.failure(leave_request.errors.messages)
    end
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassEnrollmentService#reject_leave_request: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def add_student(class_id, student_id)
    class_obj = find_class(class_id)
    return Result.failure({ error: 'Class not found' }) unless class_obj

    student = Student.find_by(id: student_id)
    return Result.failure({ error: 'Student not found' }) unless student

    # Check if student is already enrolled
    existing_enrollment = Enrollment.find_by(class_id: class_obj.id, student_id: student_id)
    if existing_enrollment
      if existing_enrollment.status == 'active'
        return Result.failure({ error: 'Student is already enrolled in this class' })
      else
        # Reactivate enrollment if it was dropped or pending
        if existing_enrollment.update(status: 'active')
          return Result.success({ 
            message: 'Student added successfully', 
            enrollment: { id: existing_enrollment.id, status: existing_enrollment.status } 
          })
        else
          return Result.failure(existing_enrollment.errors.messages)
        end
      end
    end

    # Create new enrollment with active status
    enrollment = Enrollment.new(
      class_id: class_obj.id,
      student_id: student_id,
      status: 'active',
      tuition_debt: 0,
      sessions_attended: 0
    )

    if enrollment.save
      Result.success({ 
        message: 'Student added successfully', 
        enrollment: { id: enrollment.id, status: enrollment.status } 
      })
    else
      Result.failure(enrollment.errors.messages)
    end
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassEnrollmentService#add_student: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def remove_student(class_id, student_id)
    class_obj = find_class(class_id)
    return Result.failure({ error: 'Class not found' }) unless class_obj

    enrollment = Enrollment.find_by(class_id: class_obj.id, student_id: student_id)
    return Result.failure({ error: 'Student is not enrolled in this class' }) unless enrollment

    if enrollment.update(status: 'dropped')
      Result.success({ message: 'Student removed successfully' })
    else
      Result.failure(enrollment.errors.messages)
    end
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassEnrollmentService#remove_student: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def search_students(query)
    return Result.failure({ error: 'Search query is required' }) if query.blank?

    search_term = "%#{query}%"
    students = Student.joins(:user)
                     .where("LOWER(users.full_name) LIKE LOWER(?) OR LOWER(users.email) LIKE LOWER(?) OR LOWER(students.student_code) LIKE LOWER(?)", 
                            search_term, search_term, search_term)
                     .limit(20)
                     .includes(:user)

    students_data = students.map do |student|
      {
        id: student.id,
        name: student.user.full_name,
        email: student.user.email,
        student_code: student.student_code,
        phone: student.user.phone_number || 'N/A'
      }
    end

    Result.success({ students: students_data })
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassEnrollmentService#search_students: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  private

  def find_class(class_id)
    SchoolClass.where(teacher_id: @teacher.user_id).find_by(id: class_id)
  end

  # Tạo attendance_record cho temporary leave request
  # status: 'absent_w_reason' (có phép) hoặc 'absent_no_reason' (không phép)
  def create_attendance_record_for_leave_request(leave_request, attendance_status)
    return unless leave_request.temporary? && leave_request.date.present?

    class_obj = SchoolClass.where(teacher_id: @teacher.user_id).find_by(id: leave_request.class_id)
    return unless class_obj

    # Lấy hoặc tạo attendance_session cho ngày đó
    date_str = leave_request.date.strftime('%Y-%m-%d')
    
    # Tìm thời gian học từ schedule của class dựa trên ngày của leave_request
    time_str = nil
    if class_obj.schedule.present?
      begin
        schedule_data = class_obj.schedule.is_a?(String) ? JSON.parse(class_obj.schedule) : class_obj.schedule
        if schedule_data.is_a?(Hash) && schedule_data.keys.any?
          # Xác định thứ trong tuần (0 = Monday, 6 = Sunday)
          date_obj = leave_request.date
          day_of_week = date_obj.wday # 0 = Sunday, 1 = Monday, ..., 6 = Saturday
          monday_based_day = day_of_week == 0 ? 6 : day_of_week - 1 # Convert to Monday=0
          
          # Lấy thời gian từ schedule cho ngày đó
          day_key = monday_based_day.to_s
          time_range = schedule_data[day_key]
          
          Rails.logger.info("Leave request #{leave_request.id}: date=#{date_str}, day_of_week=#{day_of_week}, monday_based_day=#{monday_based_day}, day_key=#{day_key}, schedule_data=#{schedule_data.inspect}, time_range=#{time_range.inspect}")
          
          if time_range.present? && time_range.include?('-')
            time_str = time_range.split('-').first.strip
            Rails.logger.info("Leave request #{leave_request.id}: Extracted time_str=#{time_str} from schedule")
          else
            Rails.logger.warn("Leave request #{leave_request.id}: No time_range found for day_key=#{day_key}")
          end
        else
          Rails.logger.warn("Leave request #{leave_request.id}: schedule_data is not a Hash or empty: #{schedule_data.inspect}")
        end
      rescue JSON::ParserError => e
        Rails.logger.error("Leave request #{leave_request.id}: Failed to parse schedule JSON: #{e.message}")
      end
    else
      Rails.logger.warn("Leave request #{leave_request.id}: Class #{class_obj.id} has no schedule")
    end

    # Kiểm tra xem attendance_session cho ngày và giờ đó đã tồn tại chưa
    # Nếu chưa thì mới tạo, còn không thì lấy luôn
    Rails.logger.info("Leave request #{leave_request.id}: Calling get_or_create_attendance_session with date=#{date_str}, time=#{time_str || 'nil'}")
    schedule_service = TeacherClassScheduleService.new(@teacher)
    session_result = schedule_service.get_or_create_attendance_session(
      leave_request.class_id,
      date_str,
      time_str,
      "Tự động tạo từ yêu cầu nghỉ học"
    )

    unless session_result.success?
      Rails.logger.error("Leave request #{leave_request.id}: Failed to get/create attendance session: #{session_result.errors.inspect}")
      return
    end

    session_id = session_result.data[:session][:id]
    attendance_session = AttendanceSession.find_by(id: session_id)
    unless attendance_session
      Rails.logger.error("Leave request #{leave_request.id}: Attendance session #{session_id} not found after creation")
      return
    end

    Rails.logger.info("Leave request #{leave_request.id}: Using attendance_session #{session_id}, date=#{attendance_session.date.strftime('%Y-%m-%d %H:%M:%S')}")

    attendance_record = AttendanceRecord.find_or_initialize_by(
      attendance_session_id: attendance_session.id,
      student_id: leave_request.student_id
    )

    note = "Nghỉ học: #{leave_request.reason}"
    note += " (#{leave_request.teacher_note})" if leave_request.teacher_note.present?

    attendance_record.status = attendance_status
    attendance_record.note = note

    if attendance_record.save
      Rails.logger.info("Created attendance_record for leave_request #{leave_request.id}: status=#{attendance_status}, student_id=#{leave_request.student_id}, date=#{date_str}, time=#{time_str || '00:00'}, session_id=#{session_id}, session_date=#{attendance_session.date.strftime('%Y-%m-%d %H:%M:%S')}")
    else
      Rails.logger.error("Failed to create attendance_record for leave_request #{leave_request.id}: #{attendance_record.errors.full_messages.join(', ')}")
    end
  rescue StandardError => e
    Rails.logger.error("Error creating attendance_record for leave_request #{leave_request.id}: #{e.message}\n#{e.backtrace.join("\n")}")
  end
end
