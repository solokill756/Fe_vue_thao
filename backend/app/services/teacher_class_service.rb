# frozen_string_literal: true

class TeacherClassService
  def initialize(teacher)
    @teacher = teacher
  end

  def create_class(params)
    # Build schedule JSON from params
    schedule = build_schedule_from_params(params)
    
    class_params = {
      name: params[:name],
      subject: params[:subject],
      grade_level: params[:grade_level],
      description: params[:description],
      fee_per_session: params[:fee_per_session],
      status: params[:status] || 'active',
      schedule: schedule,
      teacher_id: @teacher.user_id
    }
    
    class_obj = SchoolClass.new(class_params)
    
    if class_obj.save
      Result.success(class_obj)
    else
      Result.failure(class_obj.errors.messages)
    end
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassService#create_class: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def list_classes(params = {})
    classes = SchoolClass.where(teacher_id: @teacher.user_id)
                         .includes(:enrollments, :teacher)
                         .order(created_at: :desc)
    
    classes = classes.where(status: params[:status]) if params[:status].present?
    
    classes = classes.search_by_name(params[:search]) if params[:search].present?
    
    
    Result.success(classes)
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassService#list_classes: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def get_class_detail(class_id)
    class_obj = SchoolClass.where(teacher_id: @teacher.user_id).find_by(id: class_id)
    return Result.failure({ error: 'Class not found' }) unless class_obj

    Result.success(class_obj)
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassService#get_class_detail: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def get_pending_requests(class_id)
    class_obj = SchoolClass.where(teacher_id: @teacher.user_id).find_by(id: class_id)
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
    Rails.logger.error("Error in TeacherClassService#get_pending_requests: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def approve_enrollment(class_id, enrollment_id)
    class_obj = SchoolClass.where(teacher_id: @teacher.user_id).find_by(id: class_id)
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
    Rails.logger.error("Error in TeacherClassService#approve_enrollment: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def reject_enrollment(class_id, enrollment_id)
    class_obj = SchoolClass.where(teacher_id: @teacher.user_id).find_by(id: class_id)
    return Result.failure({ error: 'Class not found' }) unless class_obj

    enrollment = Enrollment.find_by(id: enrollment_id, class_id: class_obj.id)
    return Result.failure({ error: 'Enrollment not found' }) unless enrollment

    if enrollment.destroy
      Result.success({ message: 'Enrollment rejected successfully' })
    else
      Result.failure(enrollment.errors.messages)
    end
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassService#reject_enrollment: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def approve_leave_request(class_id, leave_request_id, teacher_note = nil)
    class_obj = SchoolClass.where(teacher_id: @teacher.user_id).find_by(id: class_id)
    return Result.failure({ error: 'Class not found' }) unless class_obj

    leave_request = LeaveRequest.find_by(id: leave_request_id, class_id: class_obj.id)
    return Result.failure({ error: 'Leave request not found' }) unless leave_request

    if leave_request.update(status: 'approved', teacher_note: teacher_note)
      if leave_request.permanent?
        enrollment = Enrollment.find_by(class_id: class_obj.id, student_id: leave_request.student_id)
        enrollment&.update(status: 'dropped')
      end
      Result.success({ 
        message: 'Leave request approved successfully', 
        leave_request: { id: leave_request.id, status: leave_request.status } 
      })
    else
      Result.failure(leave_request.errors.messages)
    end
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassService#approve_leave_request: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def reject_leave_request(class_id, leave_request_id, teacher_note = nil)
    class_obj = SchoolClass.where(teacher_id: @teacher.user_id).find_by(id: class_id)
    return Result.failure({ error: 'Class not found' }) unless class_obj

    leave_request = LeaveRequest.find_by(id: leave_request_id, class_id: class_obj.id)
    return Result.failure({ error: 'Leave request not found' }) unless leave_request

    if leave_request.update(status: 'rejected', teacher_note: teacher_note)
      Result.success({ 
        message: 'Leave request rejected successfully', 
        leave_request: { id: leave_request.id, status: leave_request.status } 
      })
    else
      Result.failure(leave_request.errors.messages)
    end
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassService#reject_leave_request: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def add_student(class_id, student_id)
    class_obj = SchoolClass.where(teacher_id: @teacher.user_id).find_by(id: class_id)
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
    Rails.logger.error("Error in TeacherClassService#add_student: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def remove_student(class_id, student_id)
    class_obj = SchoolClass.where(teacher_id: @teacher.user_id).find_by(id: class_id)
    return Result.failure({ error: 'Class not found' }) unless class_obj

    enrollment = Enrollment.find_by(class_id: class_obj.id, student_id: student_id)
    return Result.failure({ error: 'Student is not enrolled in this class' }) unless enrollment

    if enrollment.update(status: 'dropped')
      Result.success({ message: 'Student removed successfully' })
    else
      Result.failure(enrollment.errors.messages)
    end
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassService#remove_student: #{e.message}\n#{e.backtrace.join("\n")}")
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
    Rails.logger.error("Error in TeacherClassService#search_students: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def get_class_schedule(class_id)
    class_obj = SchoolClass.where(teacher_id: @teacher.user_id).find_by(id: class_id)
    return Result.failure({ error: 'Class not found' }) unless class_obj

    # Get fixed schedule from class
    schedule = class_obj.schedule || {}
    
    # Get upcoming attendance sessions
    upcoming_sessions = AttendanceSession.where(class_id: class_obj.id)
                                        .where('date > ?', Time.current)
                                        .order(date: :asc)
                                        .limit(10)

    sessions_data = upcoming_sessions.map do |session|
      {
        id: session.id,
        date: session.date.strftime('%Y-%m-%d %H:%M:%S'),
        date_display: session.date.strftime('%d/%m/%Y'),
        time_display: session.date.strftime('%H:%M'),
        day_of_week: session.date.strftime('%A'),
        teacher_note: session.teacher_note || '',
        status: session.date > Time.current ? 'upcoming' : 'past'
      }
    end

    Result.success({
      fixed_schedule: schedule,
      upcoming_sessions: sessions_data
    })
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassService#get_class_schedule: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def create_attendance_session(class_id, date, teacher_note = nil)
    class_obj = SchoolClass.where(teacher_id: @teacher.user_id).find_by(id: class_id)
    return Result.failure({ error: 'Class not found' }) unless class_obj

    session = AttendanceSession.new(
      class_id: class_obj.id,
      date: date,
      teacher_note: teacher_note
    )

    if session.save
      Result.success({ 
        message: 'Attendance session created successfully', 
        session: { 
          id: session.id, 
          date: session.date.strftime('%Y-%m-%d %H:%M:%S'),
          date_display: session.date.strftime('%d/%m/%Y'),
          time_display: session.date.strftime('%H:%M')
        } 
      })
    else
      Result.failure(session.errors.messages)
    end
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassService#create_attendance_session: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def update_attendance_session(class_id, session_id, date, teacher_note = nil)
    class_obj = SchoolClass.where(teacher_id: @teacher.user_id).find_by(id: class_id)
    return Result.failure({ error: 'Class not found' }) unless class_obj

    session = AttendanceSession.find_by(id: session_id, class_id: class_obj.id)
    return Result.failure({ error: 'Attendance session not found' }) unless session

    if session.update(date: date, teacher_note: teacher_note)
      Result.success({ 
        message: 'Attendance session updated successfully', 
        session: { 
          id: session.id, 
          date: session.date.strftime('%Y-%m-%d %H:%M:%S'),
          date_display: session.date.strftime('%d/%m/%Y'),
          time_display: session.date.strftime('%H:%M')
        } 
      })
    else
      Result.failure(session.errors.messages)
    end
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassService#update_attendance_session: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def delete_attendance_session(class_id, session_id)
    class_obj = SchoolClass.where(teacher_id: @teacher.user_id).find_by(id: class_id)
    return Result.failure({ error: 'Class not found' }) unless class_obj

    session = AttendanceSession.find_by(id: session_id, class_id: class_obj.id)
    return Result.failure({ error: 'Attendance session not found' }) unless session

    if session.destroy
      Result.success({ message: 'Attendance session deleted successfully' })
    else
      Result.failure(session.errors.messages)
    end
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassService#delete_attendance_session: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def update_class_schedule(class_id, schedule_data)
    class_obj = SchoolClass.where(teacher_id: @teacher.user_id).find_by(id: class_id)
    return Result.failure({ error: 'Class not found' }) unless class_obj

    if class_obj.update(schedule: schedule_data)
      Result.success({ 
        message: 'Schedule updated successfully', 
        schedule: class_obj.schedule 
      })
    else
      Result.failure(class_obj.errors.messages)
    end
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassService#update_class_schedule: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def update_class(class_id, params)
    class_obj = SchoolClass.where(teacher_id: @teacher.user_id).find_by(id: class_id)
    return Result.failure({ error: 'Class not found' }) unless class_obj

    # Handle image upload if present
    if params[:cover_image_file].present?
      upload_result = upload_cover_image(params[:cover_image_file])
      return upload_result unless upload_result.success?
      
      params[:cover_image] = upload_result.data[:url]
      params.delete(:cover_image_file)
    end

    if class_obj.update(params.except(:cover_image_file))
      Result.success(class_obj)
    else
      Result.failure(class_obj.errors.messages)
    end
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassService#update_class: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def upload_cover_image(file)
    return Result.failure({ error: 'No file uploaded' }) if file.blank?

    # Validate file type
    allowed_types = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
    unless allowed_types.include?(file.content_type)
      return Result.failure({ error: 'Invalid file type. Only JPEG, PNG, and WebP are allowed.' })
    end

    # Validate file size (max 5MB)
    max_size = 5.megabytes
    if file.size > max_size
      return Result.failure({ error: "File too large. Maximum size is #{max_size / 1.megabyte}MB" })
    end

    uploaded_file = Cloudinary::Uploader.upload(
      file,
      folder: 'class_covers',
      resource_type: 'image',
      transformation: [
        { width: 1200, height: 600, crop: 'limit', quality: 'auto' }
      ]
    )

    Result.success({ url: uploaded_file['secure_url'], public_id: uploaded_file['public_id'] })
  rescue StandardError => e
    Rails.logger.error("Error uploading cover image: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def delete_class(class_id)
    class_obj = SchoolClass.where(teacher_id: @teacher.user_id).find_by(id: class_id)
    return Result.failure({ error: 'Class not found' }) unless class_obj

    if class_obj.destroy
      Result.success({ message: 'Class deleted successfully' })
    else
      Result.failure(class_obj.errors.messages)
    end
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassService#delete_class: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  private

  def build_schedule_from_params(params)
    return {} unless params[:schedule_data].present?

    day_map = {
      'Thứ 2' => 0,
      'Thứ 3' => 1,
      'Thứ 4' => 2,
      'Thứ 5' => 3,
      'Thứ 6' => 4,
      'Thứ 7' => 5,
      'Chủ nhật' => 6
    }

    schedule = {}
    
    params[:schedule_data].each do |entry|
      day = entry[:day] || entry['day']
      start_time = entry[:start_time] || entry['start_time']
      end_time = entry[:end_time] || entry['end_time']
      
      next unless day && start_time && end_time
      
      day_index = day_map[day]
      next unless day_index
      
      time_range = "#{start_time}-#{end_time}"
      schedule[day_index.to_s] = time_range
    end

    schedule
  end

  attr_reader :teacher
end
