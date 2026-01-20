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
      monthly_tuition_fee: params[:monthly_tuition_fee],
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

  # Delegate methods to specialized services
  def enrollment_service
    @enrollment_service ||= TeacherClassEnrollmentService.new(@teacher)
  end

  def schedule_service
    @schedule_service ||= TeacherClassScheduleService.new(@teacher)
  end

  def finance_service
    @finance_service ||= TeacherClassFinanceService.new(@teacher)
  end

  # Delegate enrollment methods
  def get_pending_requests(class_id)
    enrollment_service.get_pending_requests(class_id)
  end

  def approve_enrollment(class_id, enrollment_id)
    enrollment_service.approve_enrollment(class_id, enrollment_id)
  end

  def reject_enrollment(class_id, enrollment_id)
    enrollment_service.reject_enrollment(class_id, enrollment_id)
  end

  def approve_leave_request(class_id, leave_request_id, teacher_note = nil)
    enrollment_service.approve_leave_request(class_id, leave_request_id, teacher_note)
  end

  def reject_leave_request(class_id, leave_request_id, teacher_note = nil)
    enrollment_service.reject_leave_request(class_id, leave_request_id, teacher_note)
  end

  def add_student(class_id, student_id)
    enrollment_service.add_student(class_id, student_id)
  end

  def remove_student(class_id, student_id)
    enrollment_service.remove_student(class_id, student_id)
  end

  def search_students(query)
    enrollment_service.search_students(query)
  end

  # Delegate schedule methods
  def get_class_schedule(class_id)
    schedule_service.get_class_schedule(class_id)
  end

  def get_or_create_attendance_session(class_id, date, time = nil, teacher_note = nil)
    schedule_service.get_or_create_attendance_session(class_id, date, time, teacher_note)
  end

  def create_attendance_session(class_id, date, time = nil, teacher_note = nil)
    schedule_service.create_attendance_session(class_id, date, time, teacher_note)
  end

  def update_attendance_session(class_id, session_id, date, teacher_note = nil)
    schedule_service.update_attendance_session(class_id, session_id, date, teacher_note)
  end

  def delete_attendance_session(class_id, session_id)
    schedule_service.delete_attendance_session(class_id, session_id)
  end

  def update_class_schedule(class_id, schedule_data)
    schedule_service.update_class_schedule(class_id, schedule_data)
  end

  # Delegate finance methods
  def get_class_finance(class_id, search_query = nil)
    finance_service.get_class_finance(class_id, search_query)
  end

  def get_all_finance_stats
    finance_service.get_all_finance_stats
  end

  def record_payment(class_id, enrollment_id, payment_params)
    finance_service.record_payment(class_id, enrollment_id, payment_params)
  end

  def send_reminder(class_id, enrollment_id, message = nil)
    finance_service.send_reminder(class_id, enrollment_id, message)
  end

  def send_all_reminders(class_id)
    finance_service.send_all_reminders(class_id)
  end

  def create_invoice_for_student(class_id, enrollment_id, invoice_params)
    finance_service.create_invoice_for_student(class_id, enrollment_id, invoice_params)
  end

  def get_payment_history(class_id, enrollment_id, page = 1, per_page = 20)
    finance_service.get_payment_history(class_id, enrollment_id, page, per_page)
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
