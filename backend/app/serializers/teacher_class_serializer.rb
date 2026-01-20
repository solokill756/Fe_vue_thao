# frozen_string_literal: true

class TeacherClassSerializer
  def initialize(class_obj)
    @class = class_obj
  end

  def serialize
    active_enrollments = @class.enrollments.where(status: 'active')
    student_count = active_enrollments.count
    
    {
      id: @class.id,
      code: "CLASS#{@class.id.to_s.rjust(4, '0')}",
      name: @class.name,
      grade: extract_grade_from_name(@class.name),
      schedule: format_schedule(@class.schedule),
      room: 'N/A',
      students: student_count,
      maxStudents: 50,
      status: @class.status,
      subject: @class.subject,
      cover_image: @class.cover_image
    }
  end

  def serialize_detail
    active_enrollments = @class.enrollments.where(status: 'active').includes(student: :user)
    
    {
      id: @class.id,
      code: "CLASS#{@class.id.to_s.rjust(4, '0')}",
      name: @class.name,
      grade: @class.grade_level || extract_grade_from_name(@class.name),
      schedule: format_schedule(@class.schedule),
      room: 'N/A',
      students: active_enrollments.count,
      maxStudents: 50,
      status: @class.status,
      subject: @class.subject,
      description: @class.description,
      grade_level: @class.grade_level,
      monthly_tuition_fee: @class.monthly_tuition_fee&.to_f || 0,
      cover_image: @class.cover_image,
      raw_schedule: @class.schedule,
      students_list: active_enrollments.map do |enrollment|
        student = enrollment.student
        user = student.user
        {
          id: student.id,
          name: user.full_name,
          dob: student.dob&.strftime('%Y-%m-%d') || 'N/A',
          phone: user.phone_number || 'N/A',
          parent: student.parent_name || 'N/A',
          student_code: student.student_code,
          total_sessions: calculate_total_sessions(enrollment),
          sessions_attended: enrollment.sessions_attended_count,
          avatar: user.photo_url
        }
      end
    }
  end

  def self.serialize(class_obj)
    new(class_obj).serialize
  end

  def self.serialize_detail(class_obj)
    new(class_obj).serialize_detail
  end

  def self.serialize_collection(classes)
    classes.map { |class_obj| new(class_obj).serialize }
  end

  private

  def format_schedule(schedule)
    return 'Chưa có lịch' unless schedule.is_a?(Hash) && schedule.any?
    
    
    day_map = {
      '0' => 'T2',  
      '1' => 'T3',  
      '2' => 'T4',  
      '3' => 'T5',  
      '4' => 'T6',  
      '5' => 'T7',  
      '6' => 'CN'   
    }
    
    old_day_map = {
      'monday' => 'T2',
      'tuesday' => 'T3',
      'wednesday' => 'T4',
      'thursday' => 'T5',
      'friday' => 'T6',
      'saturday' => 'T7',
      'sunday' => 'CN'
    }
     
    time_groups = {}
    schedule.each do |day, time|
      day_key = day.to_s
      day_short = day_map[day_key] || old_day_map[day_key.downcase] || day_key
      time_groups[time] ||= []
      time_groups[time] << day_short
    end
    
    time_groups.map do |time, days|
      "#{days.join(', ')}: #{time}"
    end.join(' | ')
  end

  def extract_grade_from_name(name)
    match = name.match(/\b(\d{1,2})\b/)
    match ? match[1] : 'N/A'
  end

  def calculate_total_sessions enrollment
    school_class = @class
    return 0 unless school_class

    # Get fixed schedule from class
    schedule_data = school_class.schedule
    schedule_data = schedule_data.is_a?(String) ? JSON.parse(schedule_data) : schedule_data if schedule_data.present?
    schedule_data ||= {}

    # Count fixed schedule sessions per week (number of days with schedule)
    fixed_sessions_per_week = schedule_data.keys.length

    # Fixed sessions = sessions per week * 4 (fixed 4 weeks per month)
    fixed_sessions_total = fixed_sessions_per_week * 4

    # Calculate start date from enrollment date
    start_date = enrollment.created_at.to_date

    # Get all attendance sessions from enrollment date onwards
    all_sessions = school_class.attendance_sessions
                               .where('date >= ?', start_date)

    # Count sessions that don't match fixed schedule (make-up classes)
    make_up_sessions_count = 0
    all_sessions.each do |session|
      session_wday = session.date.utc.wday
      schedule_day = (session_wday == 0) ? 6 : (session_wday - 1) # Convert to Monday=0, Sunday=6

      schedule_time = schedule_data[schedule_day.to_s]

      # If no schedule for this day, it's a make-up class
      if schedule_time.blank?
        make_up_sessions_count += 1
      elsif schedule_time.present?
        # Check if time matches fixed schedule
        schedule_start_time = schedule_time.split('-').first&.strip
        session_time = session.date.utc.strftime('%H:%M')

        # Normalize times for comparison - ensure both are in HH:MM format
        schedule_start_time_normalized = schedule_start_time&.split(':')&.map { |t| t.rjust(2, '0') }&.join(':')
        session_time_normalized = session_time.split(':').map { |t| t.rjust(2, '0') }.join(':')

        # If time doesn't match, it's a make-up class
        unless schedule_start_time_normalized == session_time_normalized
          make_up_sessions_count += 1
        end
      end
    end

  

    # Total sessions = fixed sessions (4 weeks) + make-up sessions
   return fixed_sessions_total + make_up_sessions_count
  end
end
