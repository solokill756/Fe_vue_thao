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
      fee_per_session: @class.fee_per_session&.to_f || 0,
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
          sessions_attended: enrollment.sessions_attended_count || 0,
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
      day_short = day_map[day.to_s.downcase] || day.to_s
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
end
