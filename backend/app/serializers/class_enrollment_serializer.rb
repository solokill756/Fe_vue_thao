# frozen_string_literal: true

class ClassEnrollmentSerializer
  def initialize(enrollment)
    @enrollment = enrollment
  end

  def serialize
    {
      id: @enrollment.id,
      class_id: @enrollment.class_id,
      class_name: @enrollment.school_class&.name,
      teacher_name: @enrollment.school_class&.teacher&.user&.full_name,
      schedule: @enrollment.school_class&.schedule,
      student_id: @enrollment.student_id,
      student_name: @enrollment.student&.full_name,
      joined_at: @enrollment.joined_at,
      status: @enrollment.status,
      tuition_debt: @enrollment.tuition_debt,
      sessions_attended: @enrollment.sessions_attended,
      total_sessions: calculate_total_sessions,
      created_at: @enrollment.created_at,
      updated_at: @enrollment.updated_at
    }
  end

  def self.serialize(enrollment)
    new(enrollment).serialize
  end

  private

  def calculate_total_sessions
    school_class = @enrollment.school_class
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
    start_date = @enrollment.created_at.to_date

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
    fixed_sessions_total + make_up_sessions_count
  end
end
