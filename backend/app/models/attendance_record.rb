# frozen_string_literal: true

class AttendanceRecord < ApplicationRecord
  self.table_name = 'attendance_records'

  # Associations
  belongs_to :attendance_session
  belongs_to :student

  # Validations
  validates :status,
            inclusion: { in: %w[present absent_w_reason absent_no_reason late] }
  validates :score_in_class,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  # Enums
  enum status: { present: 'present', absent_w_reason: 'absent_w_reason',
                 absent_no_reason: 'absent_no_reason', late: 'late' }

  # Scopes
  scope :present, -> { where(status: 'present') }
  scope :absent, -> { where(status: %w[absent_w_reason absent_no_reason]) }
  scope :late, -> { where(status: 'late') }
  scope :by_student, ->(student_id) { where(student_id:) }

  # Callbacks
  after_save :check_and_create_monthly_invoice, if: -> { saved_change_to_status? && present? }

  # Methods
  def present?
    status == 'present'
  end

  def absent?
    status.in?(%w[absent_w_reason absent_no_reason])
  end

  private

  def check_and_create_monthly_invoice
    return unless present? 

    school_class = attendance_session.school_class
    enrollment = Enrollment.find_by(class_id: school_class.id, student_id: student.id)
    return unless enrollment
    return unless school_class.monthly_tuition_fee # Skip if no monthly tuition fee

    # Create invoice for this single session
    # Check if invoice already exists for this attendance_session
    session_date = attendance_session.date.to_date
    
    # Check if there's already an invoice for this specific session
    existing_invoice = student.tuition_invoices
                             .where(class_id: school_class.id)
                             .where('created_at >= ?', session_date.beginning_of_day)
                             .where('created_at <= ?', session_date.end_of_day)
                             .where("description LIKE ?", "%#{session_date.strftime('%d/%m/%Y')}%")
                             .first

    # Only create if no invoice exists for this session
    unless existing_invoice
      create_session_invoice(school_class, enrollment, session_date)
    end
  end

  def create_session_invoice(school_class, enrollment, session_date)
    return unless school_class.monthly_tuition_fee

    # Calculate total sessions per month
    current_month_start = Date.current.beginning_of_month
    current_month_end = Date.current.end_of_month
    
    # Get the most recent invoice for this student in this class to determine reset point
    last_invoice = student.tuition_invoices
                         .where(class_id: school_class.id)
                         .order(created_at: :desc)
                         .first
    
    # Calculate actual sessions attended - only count sessions AFTER last invoice was created
    # This resets the count when an invoice is created
    attendance_query = AttendanceRecord
      .joins(:attendance_session)
      .where(
        student_id: student.id,
        status: ['present', 'late'],
        attendance_sessions: { class_id: school_class.id }
      )
    
    # If there's a last invoice, only count sessions after it was created
    # Use created_at date to ensure we don't count sessions that were included in the invoice
    # This effectively resets the count when an invoice is created
    if last_invoice
      # Count sessions AFTER the invoice was created (reset point)
      attendance_query = attendance_query.where('attendance_sessions.date > ?', last_invoice.created_at.to_date)
    else
      # No invoice yet, count from beginning of current month
      attendance_query = attendance_query.where('attendance_sessions.date >= ?', current_month_start)
    end
    
    actual_sessions_attended = attendance_query.count
    
    scheduled_sessions = school_class.attendance_sessions
                                     .where(date: current_month_start..current_month_end)
                                     .count
    
    if scheduled_sessions == 0 && school_class.schedule.present?
      schedule_data = school_class.schedule.is_a?(String) ? JSON.parse(school_class.schedule) : school_class.schedule
      if schedule_data.is_a?(Hash) && schedule_data.keys.any?
        sessions_per_week = schedule_data.keys.length
        scheduled_sessions = sessions_per_week * 4
      else
        scheduled_sessions = 12
      end
    end
    
    total_sessions = [scheduled_sessions, 12].max
    
    # Calculate total_debt: min of (monthly_fee / total_sessions * actual_sessions) and monthly_fee
    total_debt = [
      school_class.monthly_tuition_fee.to_f / total_sessions.to_f * actual_sessions_attended.to_f,
      school_class.monthly_tuition_fee.to_f
    ].min.ceil.to_i

    # Only create invoice when student has reached total_sessions (full month)
    # This ensures reset happens when student completes full month of sessions
    return unless actual_sessions_attended >= total_sessions

    due_date = session_date + 7.days # Due 7 days after session

    invoice = student.tuition_invoices.create!(
      class_id: school_class.id,
      title: "Học phí #{school_class.name} - Tháng #{session_date.strftime('%m/%Y')}",
      description: "Học phí cho #{actual_sessions_attended} buổi học trong tháng #{session_date.strftime('%m/%Y')} (#{total_sessions} buổi/tháng)",
      amount: total_debt,
      due_date: due_date,
      status: 'pending'
    )

    # Update enrollment debt
    enrollment.update(tuition_debt: enrollment.tuition_debt + total_debt)

    Rails.logger.info("Created session invoice #{invoice.invoice_code} for student #{student.id} in class #{school_class.id} for session #{session_date} - Amount: #{total_debt} (total_debt)")
  rescue StandardError => e
    Rails.logger.error("Error creating session invoice: #{e.message}\n#{e.backtrace.join("\n")}")
  end

  def calculate_sessions_per_month(school_class)
    # Calculate from schedule: number of days per week * 4 weeks per month
    if school_class.schedule.present?
      schedule_data = school_class.schedule.is_a?(String) ? JSON.parse(school_class.schedule) : school_class.schedule
      if schedule_data.is_a?(Hash) && schedule_data.keys.any?
        sessions_per_week = schedule_data.keys.length
        sessions_per_month = sessions_per_week * 4 # 4 weeks per month
        return sessions_per_month if sessions_per_month > 0
      end
    end
    
    # Fallback: count actual scheduled sessions in current month
    current_month_start = Date.current.beginning_of_month
    current_month_end = Date.current.end_of_month
    scheduled_sessions = school_class.attendance_sessions
                                   .where(date: current_month_start..current_month_end)
                                   .count
    
    # If we have scheduled sessions, use it (but ensure minimum reasonable value)
    if scheduled_sessions > 0
      return scheduled_sessions if scheduled_sessions >= 4 # Only use if we have enough sessions
    end
    
    # Default fallback: 12 sessions per month (3 sessions/week * 4 weeks)
    12
  end

  def format_currency(amount)
    "#{amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse} VND"
  rescue
    "#{amount} VND"
  end
end
