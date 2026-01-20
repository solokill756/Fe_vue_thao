# frozen_string_literal: true

class TeacherClassScheduleService
  def initialize(teacher)
    @teacher = teacher
  end

  def get_class_schedule(class_id)
    class_obj = find_class(class_id)
    return Result.failure({ error: 'Class not found' }) unless class_obj

    # Get fixed schedule from class
    schedule = class_obj.schedule || {}
    
    # Get upcoming attendance sessions
    upcoming_sessions = AttendanceSession.where(class_id: class_obj.id)
                                        .where('date > ?', Time.current)
                                        .order(date: :asc)
                                        .limit(50) 

   
    sessions_data = upcoming_sessions.filter_map do |session|
      session_Wday = session.date.wday
      schedule_day = (session_Wday == 0) ? 6 : (session_Wday - 1)
      
      schedule_time = schedule[schedule_day.to_s]
      
      next {
        id: session.id,
        date: session.date.strftime('%Y-%m-%d %H:%M:%S'),
        date_display: session.date.strftime('%d/%m/%Y'),
        time_display: session.date.strftime('%H:%M'),
        day_of_week: session.date.strftime('%A'),
        teacher_note: session.teacher_note || '',
        status: session.date > Time.current ? 'upcoming' : 'past'
      } if schedule_time.blank?
      
    
      if schedule_time.present?
        schedule_start_time = schedule_time.split('-').first&.strip
        session_time = session.date.strftime('%H:%M')
        
        if schedule_start_time != session_time
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
      end
    end.first(10) 

    Result.success({
      fixed_schedule: schedule,
      upcoming_sessions: sessions_data
    })
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassScheduleService#get_class_schedule: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def get_or_create_attendance_session(class_id, date, time = nil, teacher_note = nil)
    class_obj = find_class(class_id)
    return Result.failure({ error: 'Class not found' }) unless class_obj

    # If time is not provided or is '00:00', try to get it from the class schedule
    if time.blank? || time == '00:00' || time.strip == '00:00'
      schedule = class_obj.schedule || {}
      date_obj = Date.parse(date) rescue nil
      if date_obj
        wday = date_obj.wday
        schedule_day = (wday == 0) ? 6 : (wday - 1) # Convert to Monday=0, Sunday=6
        schedule_time = schedule[schedule_day.to_s]
        if schedule_time.present?
          # Extract start time from schedule (format: "HH:MM - HH:MM" or "HH:MM")
          time = schedule_time.split('-').first&.strip
          Rails.logger.debug("Auto-fetched time from schedule: #{time} for date #{date}, schedule_day #{schedule_day}")
        end
      end
    end

    parsed_date = parse_date_with_time(date, time)

    start_time = parsed_date - 1.second
    end_time = parsed_date + 1.second
    session = AttendanceSession.where(class_id: class_obj.id)
                               .where(date: start_time..end_time)
                               .first
    
    if session
      if teacher_note.present?
        session.update(teacher_note: teacher_note)
      end
      
      Result.success({ 
        session: { 
          id: session.id, 
          date: session.date.strftime('%Y-%m-%d %H:%M:%S'),
          date_display: session.date.strftime('%d/%m/%Y'),
          time_display: session.date.strftime('%H:%M')
        } 
      })
    else
      session = AttendanceSession.new(
        class_id: class_obj.id,
        date: parsed_date,
        teacher_note: teacher_note
      )

      begin
        if session.save
          Result.success({ 
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
      rescue ActiveRecord::RecordNotUnique, Mysql2::Error => e
        # If duplicate entry error, try to find the existing session again
        if e.message.include?('Duplicate entry')
          existing_session = AttendanceSession.where(class_id: class_obj.id)
                                             .where(date: start_time..end_time)
                                             .first
          
          if existing_session
            # Update teacher note if provided
            if teacher_note.present?
              existing_session.update(teacher_note: teacher_note)
            end
            
            Result.success({ 
              session: { 
                id: existing_session.id, 
                date: existing_session.date.strftime('%Y-%m-%d %H:%M:%S'),
                date_display: existing_session.date.strftime('%d/%m/%Y'),
                time_display: existing_session.date.strftime('%H:%M')
              } 
            })
          else
            Result.failure({ error: 'Failed to create or find attendance session' })
          end
        else
          raise e
        end
      end
    end
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassScheduleService#get_or_create_attendance_session: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def create_attendance_session(class_id, date, time = nil, teacher_note = nil)
    get_or_create_attendance_session(class_id, date, time, teacher_note)
  end

  def update_attendance_session(class_id, session_id, date, time = nil, teacher_note = nil)
    class_obj = find_class(class_id)
    return Result.failure({ error: 'Class not found' }) unless class_obj

    session = AttendanceSession.find_by(id: session_id, class_id: class_obj.id)
    return Result.failure({ error: 'Attendance session not found' }) unless session

    parsed_date = parse_date_with_time(date, time)

    if session.update(date: parsed_date, teacher_note: teacher_note)
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
    Rails.logger.error("Error in TeacherClassScheduleService#update_attendance_session: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def delete_attendance_session(class_id, session_id)
    class_obj = find_class(class_id)
    return Result.failure({ error: 'Class not found' }) unless class_obj

    session = AttendanceSession.find_by(id: session_id, class_id: class_obj.id)
    return Result.failure({ error: 'Attendance session not found' }) unless session

    if session.destroy
      Result.success({ message: 'Attendance session deleted successfully' })
    else
      Result.failure(session.errors.messages)
    end
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassScheduleService#delete_attendance_session: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  def update_class_schedule(class_id, schedule_data)
    class_obj = find_class(class_id)
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
    Rails.logger.error("Error in TeacherClassScheduleService#update_class_schedule: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  private

  def find_class(class_id)
    SchoolClass.where(teacher_id: @teacher.user_id).find_by(id: class_id)
  end

  def parse_date_with_time(date_str, time_str = nil)
    date_parts = date_str.split('-').map(&:to_i)
    year, month, day = date_parts
    
    hours = 0
    minutes = 0
    
    if time_str.present?
      time_parts = time_str.split(':').map(&:to_i)
      hours = time_parts[0] || 0
      minutes = time_parts[1] || 0
    end
    
    # Parse as local time in app timezone, then convert to UTC for storage
    Time.zone.parse(format('%04d-%02d-%02d %02d:%02d:00', year, month, day, hours, minutes)).utc
  rescue StandardError => e
    Rails.logger.error("Error parsing date with time: #{e.message}")
    begin
      datetime_str = "#{date_str} #{time_str || '00:00'}:00"
      Time.zone.parse(datetime_str).utc
    rescue
      Time.current.utc
    end
  end
end
