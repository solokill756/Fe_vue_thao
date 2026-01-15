# frozen_string_literal: true

class StudentDashboardService
  def initialize(student)
    @student = student
  end

  def build_dashboard_data
    {
      student_info: serialize_student_info,
      today_classes: get_today_classes,
      pending_assignments: get_pending_assignments,
      stats: calculate_stats,
      tuition: get_tuition_summary
    }
  end

  private

  attr_reader :student

  def serialize_student_info
    {
      name: student.user.full_name,
      avatar: student.user.photo_url || "https://ui-avatars.com/api/?name=#{student.user.full_name.gsub(' ', '+')}&background=2563EB&color=fff",
      class: "Học sinh"
    }
  end

  def get_today_classes
    today = Date.current
    day_names_vi = {
      'monday' => ['thứ 2', 'thứ hai', 't2', 't.2'],
      'tuesday' => ['thứ 3', 'thứ ba', 't3', 't.3'],
      'wednesday' => ['thứ 4', 'thứ tư', 't4', 't.4'],
      'thursday' => ['thứ 5', 'thứ năm', 't5', 't.5'],
      'friday' => ['thứ 6', 'thứ sáu', 't6', 't.6'],
      'saturday' => ['thứ 7', 'thứ bảy', 't7', 't.7'],
      'sunday' => ['chủ nhật', 'cn']
    }
    
    day_name = today.strftime('%A').downcase
    day_keywords = day_names_vi[day_name] || []
    
    enrollments = student.enrollments
                         .includes(school_class: { teacher: :user })
                         .where(status: 'active')
    
    classes_today = enrollments.select do |enrollment|
      schedule = enrollment.school_class.schedule || {}
      schedule.is_a?(Hash) && schedule.keys.any? do |key|
        key_str = key.to_s.downcase
        day_keywords.any? { |keyword| key_str.include?(keyword) }
      end
    end

    classes_today.map do |enrollment|
      class_obj = enrollment.school_class
      schedule = class_obj.schedule || {}
      
      # Find time for today
      schedule_key = schedule.keys.find do |k|
        key_str = k.to_s.downcase
        day_keywords.any? { |keyword| key_str.include?(keyword) }
      end
      
      time_range = schedule_key ? schedule[schedule_key] : nil
      time_start = if time_range.is_a?(String)
        time_range.split('-').first&.strip || 'N/A'
      else
        'N/A'
      end
      
      # Determine status
      status = determine_class_status(time_start)
      
      {
        timeStart: time_start,
        subject: "#{class_obj.name} (#{class_obj.subject})",
        teacher: class_obj.teacher&.user&.full_name || 'N/A',
        room: 'N/A',
        status: status
      }
    end
  end

  def determine_class_status(time_start)
    return 'upcoming' if time_start == 'N/A'
    
    begin
      time_parts = time_start.split(':')
      class_hour = time_parts[0].to_i
      class_minute = time_parts[1]&.to_i || 0
      now = Time.current
      class_time = Time.zone.local(now.year, now.month, now.day, class_hour, class_minute)
      
      if class_time <= now && class_time + 2.hours >= now
        'live'
      elsif class_time > now
        'upcoming'
      else
        'dropped'
      end
    rescue
      'upcoming'
    end
  end

  def get_pending_assignments
    assignments = Assignment.joins(:school_class)
                            .joins("INNER JOIN enrollments ON enrollments.class_id = classes.id")
                            .where(enrollments: { student_id: student.id, status: 'active' })
                            .where('assignments.due_date >= ?', Time.current)
                            .order(due_date: :asc)
                            .limit(5)
                            .includes(:school_class, :submissions)

    assignments.map do |assignment|
      submission = assignment.submissions.find { |s| s.student_id == student.id }
      due_date = assignment.due_date
      is_urgent = due_date && due_date <= 24.hours.from_now
      
      {
        title: assignment.title,
        class: assignment.school_class.name,
        dueDate: format_due_date(due_date),
        isUrgent: is_urgent,
        status: submission ? 'Đã nộp' : 'Chưa nộp'
      }
    end
  end

  def format_due_date(due_date)
    return 'N/A' unless due_date
    
    now = Time.current
    if due_date.to_date == now.to_date
      due_date.strftime('%H:%M') + ' Hôm nay'
    elsif due_date.to_date == now.to_date + 1.day
      due_date.strftime('%H:%M') + ' Ngày mai'
    else
      due_date.strftime('%d/%m/%Y')
    end
  end

  def calculate_stats
    # Attendance rate - get from enrollments
    enrollments = student.enrollments.where(status: 'active')
    total_sessions = 0
    attended_sessions = 0
    
    enrollments.each do |enrollment|
      class_sessions = AttendanceSession.where(class_id: enrollment.class_id)
      total_sessions += class_sessions.count
      attended = AttendanceRecord.joins(:attendance_session)
                                .where(attendance_sessions: { class_id: enrollment.class_id })
                                .where(student_id: student.id)
                                .where(status: ['present', 'late'])
                                .count
      attended_sessions += attended
    end
    
    attendance_rate = total_sessions > 0 ? ((attended_sessions.to_f / total_sessions) * 100).round(0) : 0
    
    # Average grade
    graded_submissions = student.submissions
                              .where(status: 'graded')
                              .where.not(score: nil)
    
    average_grade = if graded_submissions.any?
      (graded_submissions.sum(:score).to_f / graded_submissions.count).round(1)
    else
      0
    end
    
    # Completed assignments
    completed_assignments = student.submissions
                                  .where(status: ['submitted', 'graded', 'late'])
                                  .count
    
    [
      {
        icon: 'fa-user-check',
        color: 'text-blue-600 bg-blue-100',
        title: 'Điểm danh',
        value: "#{attendance_rate}%",
        subtitle: total_sessions > 0 ? "Đã tham gia #{attended_sessions}/#{total_sessions} buổi" : 'Chưa có dữ liệu'
      },
      {
        icon: 'fa-chart-line',
        color: 'text-emerald-600 bg-emerald-100',
        title: 'Điểm TB',
        value: average_grade > 0 ? average_grade.to_s : 'N/A',
        subtitle: graded_submissions.any? ? "#{graded_submissions.count} bài đã chấm" : 'Chưa có điểm'
      },
      {
        icon: 'fa-book',
        color: 'text-orange-600 bg-orange-100',
        title: 'Bài tập',
        value: completed_assignments.to_s,
        subtitle: 'Đã hoàn thành'
      }
    ]
  end

  def get_tuition_summary
    pending_invoices = student.tuition_invoices.where(status: [:pending, :overdue])
    total_debt = pending_invoices.sum(:amount)
    next_due = pending_invoices.where(status: 'pending').order(due_date: :asc).first
    
    {
      totalPendingDebt: total_debt,
      nextDueDate: next_due&.due_date&.strftime('%d/%m/%Y') || 'N/A',
      debt: format_currency(total_debt)
    }
  end

  def format_currency(amount)
    "#{amount.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse}đ"
  end
end
