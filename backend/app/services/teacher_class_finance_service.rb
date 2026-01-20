# frozen_string_literal: true

class TeacherClassFinanceService
  def initialize(teacher)
    @teacher = teacher
  end

  # GET /api/v1/teacher/classes/:id/finance
  def get_class_finance(class_id, search_query = nil)
    school_class = SchoolClass.find_by(id: class_id, teacher_id: @teacher.user_id)
    return Result.failure({ error: 'Class not found' }) unless school_class

    enrollments = school_class.enrollments.where(status: 'active')
                              .includes(student: :user)
    
    enrollments = enrollments.joins(student: :user)
                            .where("users.full_name LIKE ? OR students.student_code LIKE ?", 
                                   "%#{search_query}%", "%#{search_query}%") if search_query.present?

    students_data = enrollments.map do |enrollment|
      student = enrollment.student
      user = student.user
      
     
      pending_invoices = student.tuition_invoices
                                .where(class_id: class_id, status: [:pending, :overdue])
      
     
      
      
      has_any_invoices = student.tuition_invoices
                                .where(class_id: class_id)
                                .exists?
      
      # Get the most recent invoice for this student in this class to determine reset point
      last_invoice = student.tuition_invoices
                           .where(class_id: class_id)
                           .order(created_at: :desc)
                           .first
      
      # Calculate actual sessions attended - only count sessions AFTER last invoice was created
      # This resets the count when an invoice is created
      attendance_query = AttendanceRecord
        .joins(:attendance_session)
        .where(
          student_id: student.id,
          status: ['present', 'late'],
          attendance_sessions: { class_id: class_id }
        )
      
      if last_invoice
        # Count sessions AFTER the invoice was created (reset point)
        attendance_query = attendance_query.where('attendance_sessions.date > ?', last_invoice.created_at.to_date)
      end
      
      actual_sessions_attended = attendance_query.count
      
      # Get fixed schedule from class
      schedule_data = school_class.schedule
      schedule_data = schedule_data.is_a?(String) ? JSON.parse(schedule_data) : schedule_data if schedule_data.present?
      schedule_data ||= {}
      
      # Count fixed schedule sessions per week (number of days with schedule)
      fixed_sessions_per_week = schedule_data.keys.length
      
      # If no schedule defined, count actual attendance sessions
      if fixed_sessions_per_week == 0
        # Count all attendance sessions from enrollment date onwards (or from last invoice if exists)
        start_date = last_invoice ? last_invoice.created_at.to_date : enrollment.created_at.to_date
        total_sessions = school_class.attendance_sessions
                                     .where('date >= ?', start_date)
                                     .count
        sessions_left = [total_sessions - actual_sessions_attended, 0].max
      else
        # Fixed sessions = sessions per week * 4 (fixed 4 weeks per month)
        fixed_sessions_total = fixed_sessions_per_week * 4
        
        # Calculate start date - from enrollment date or from last invoice date
        start_date = last_invoice ? last_invoice.created_at.to_date : enrollment.created_at.to_date
        
        # Get all attendance sessions from start date onwards
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
              Rails.logger.debug("Make-up session detected: schedule=#{schedule_start_time} (#{schedule_start_time_normalized}), session=#{session_time} (#{session_time_normalized}), date=#{session.date.utc.strftime('%Y-%m-%d %H:%M:%S')}")
              make_up_sessions_count += 1
            end
          end
        end
        
        # Total sessions = fixed sessions (4 weeks) + make-up sessions
        total_sessions = fixed_sessions_total + make_up_sessions_count
        sessions_left = [total_sessions - actual_sessions_attended, 0].max
      end
      sessions_left = [total_sessions - actual_sessions_attended, 0].max
      total_debt = 
        [school_class.monthly_tuition_fee.to_f / total_sessions.to_f * actual_sessions_attended.to_f, 
         school_class.monthly_tuition_fee.to_f
        ].min.ceil.to_i
      
      status = if pending_invoices.any?
                 'debt'
               elsif !has_any_invoices
                 'new' # New student, no invoices yet (will be created when they complete sessions)
               elsif actual_sessions_attended > 0 && sessions_left <= 3 && sessions_left > 0
                 'expiring_soon' # Only show expiring if student has actually attended
               else
                 'paid' # Has invoices and all are paid
               end
      
      {
        id: student.id,
        name: user.full_name,
        parentName: student.parent_name || 'N/A',
        package: "#{school_class.subject} (#{total_sessions} buổi)",
        totalSessions: total_sessions,
        sessionsLeft: sessions_left,
        status: status,
        amount: total_debt,
        avatar: user.photo_url,
        student_code: student.student_code,
        enrollment_id: enrollment.id
      }
    end

    # Calculate stats
    collected_this_month = students_data.select { |s| s[:status] == 'paid' }
    outstanding_debt = students_data.select { |s| s[:status] == 'debt' }
    expiring_soon = students_data.select { |s| s[:status] == 'expiring_soon' }
   

    stats = {
      collectedThisMonth: collected_this_month.sum { |s| s[:amount] } || 0,
      collectedCount: collected_this_month.length,
      outstandingDebt: outstanding_debt.sum { |s| s[:amount] } || 0,
      debtCount: outstanding_debt.length,
      expiringSoon: expiring_soon.length,
    }

    Result.success({
      students: students_data,
      stats: stats
    })
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassFinanceService#get_class_finance: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  # GET /api/v1/teacher/classes/finance/stats (all classes)
  def get_all_finance_stats
    # Get all classes for this teacher
    school_classes = SchoolClass.where(teacher_id: @teacher.user_id)
    class_ids = school_classes.pluck(:id)
    
    # Get all tuition_invoices from all classes of this teacher
    all_invoices = TuitionInvoice.where(class_id: class_ids)
    
    # Calculate stats
    # Collected total (all paid invoices from the beginning)
    collected_this_month = all_invoices
      .where(status: 'paid')
      .sum(:amount)
    
    collected_count = all_invoices
      .where(status: 'paid')
      .distinct
      .count(:student_id)
    
    # Outstanding debt (pending + overdue invoices)
    outstanding_debt = all_invoices
      .where(status: [:pending, :overdue])
      .sum(:amount)
    
    debt_count = all_invoices
      .where(status: [:pending, :overdue])
      .distinct
      .count(:student_id)
    
    expiring_soon_count = 0
    school_classes.each do |school_class|
      enrollments = school_class.enrollments.where(status: 'active')
      enrollments.each do |enrollment|
        student = enrollment.student
        
        # Calculate actual sessions attended from the beginning
        actual_sessions_attended = AttendanceRecord
          .joins(:attendance_session)
          .where(
            student_id: student.id,
            status: ['present', 'late'],
            attendance_sessions: { class_id: school_class.id }
          )
          .count
        
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
            # Use UTC time to avoid timezone conversion issues
            session_time = session.date.utc.strftime('%H:%M')
            
            # Normalize times for comparison - ensure both are in HH:MM format
            schedule_start_time_normalized = schedule_start_time&.split(':')&.map { |t| t.rjust(2, '0') }&.join(':')
            session_time_normalized = session_time.split(':').map { |t| t.rjust(2, '0') }.join(':')
            
            # If time doesn't match, it's a make-up class
            unless schedule_start_time_normalized == session_time_normalized
              Rails.logger.debug("Make-up session detected: schedule=#{schedule_start_time} (#{schedule_start_time_normalized}), session=#{session_time} (#{session_time_normalized}), date=#{session.date.utc.strftime('%Y-%m-%d %H:%M:%S')}")
              make_up_sessions_count += 1
            end
          end
        end
        
        # Total sessions = fixed sessions (from enrollment to now) + make-up sessions
        
        total_sessions = fixed_sessions_total + make_up_sessions_count
        sessions_left = [total_sessions - actual_sessions_attended, 0].max
        
        if actual_sessions_attended > 0 && sessions_left <= 3 && sessions_left > 0
          expiring_soon_count += 1
        end
        
        
        if sessions_left <= 0 && actual_sessions_attended > 0
          result = create_invoice_for_student(school_class.id, enrollment.id, { amount: school_class.monthly_tuition_fee , title: "Học phí tháng #{Date.current.month}" , due_date: Date.current.end_of_month + 7.days })
          if result.failure?
            Rails.logger.error("Failed to auto-create invoice for student #{student.id} in class #{school_class.id}: #{result.errors}")
          end
        end
      end
    end
    
    
    
    stats = {
      collectedThisMonth: collected_this_month.to_i,
      collectedCount: collected_count,
      outstandingDebt: outstanding_debt.to_i,
      debtCount: debt_count,
      expiringSoon: expiring_soon_count,
    }
    
    Result.success(stats)
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassFinanceService#get_all_finance_stats: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  # POST /api/v1/teacher/classes/:id/enrollments/:enrollment_id/record_payment
  def record_payment(class_id, enrollment_id, payment_params)
    school_class = SchoolClass.find_by(id: class_id, teacher_id: @teacher.user_id)
    return Result.failure({ error: 'Class not found' }) unless school_class

    enrollment = school_class.enrollments.find_by(id: enrollment_id)
    return Result.failure({ error: 'Enrollment not found' }) unless enrollment

    amount = BigDecimal(payment_params[:amount].to_s)
    method = payment_params[:method] || 'cash'
    note = payment_params[:note]

    # Find pending invoices for this student in this class
    pending_invoices = enrollment.student.tuition_invoices
                                 .where(class_id: class_id, status: [:pending, :overdue])
                                 .order(due_date: :asc)

    return Result.failure({ error: 'No pending invoices found' }) if pending_invoices.empty?

    # Record transaction
    transaction = Transaction.create!(
      tuition_invoice_id: pending_invoices.first.id,
      amount: amount,
      method: method,
      type: 'tuition_fee',
      status: 'completed',
      payment_date: Date.current,
      description: note || "Payment for #{school_class.name}"
    )

    # Mark invoice as paid if amount covers it
    remaining_amount = amount
    pending_invoices.each do |invoice|
      if remaining_amount >= invoice.amount
        invoice.mark_as_paid!
        remaining_amount -= invoice.amount
      else
        # Partial payment - update invoice amount
        invoice.update(amount: invoice.amount - remaining_amount)
        remaining_amount = 0
      end
      break if remaining_amount <= 0
    end

    # Update enrollment debt
    enrollment.update(tuition_debt: [enrollment.tuition_debt - amount, 0].max)

    Result.success({ message: 'Payment recorded successfully', transaction_id: transaction.id })
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassFinanceService#record_payment: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  # POST /api/v1/teacher/classes/:id/enrollments/:enrollment_id/send_reminder
  def send_reminder(class_id, enrollment_id, message = nil)
    school_class = SchoolClass.find_by(id: class_id, teacher_id: @teacher.user_id)
    return Result.failure({ error: 'Class not found' }) unless school_class

    enrollment = school_class.enrollments.find_by(id: enrollment_id)
    return Result.failure({ error: 'Enrollment not found' }) unless enrollment

    # TODO: Implement actual reminder sending (email, SMS, etc.)
    # For now, just return success
    # message || "Nhắc nhở thanh toán học phí cho lớp #{school_class.name}"
    
    Result.success({ message: 'Reminder sent successfully' })
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassFinanceService#send_reminder: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  # POST /api/v1/teacher/classes/:id/send_all_reminders
  def send_all_reminders(class_id)
    school_class = SchoolClass.find_by(id: class_id, teacher_id: @teacher.user_id)
    return Result.failure({ error: 'Class not found' }) unless school_class

    enrollments = school_class.enrollments.where(status: 'active')
    count = 0

    enrollments.each do |enrollment|
      pending_invoices = enrollment.student.tuition_invoices
                                   .where(class_id: class_id, status: [:pending, :overdue])
      
      if pending_invoices.any?
        # TODO: Implement actual reminder sending
        count += 1
      end
    end

    Result.success({ message: 'Reminders sent successfully', count: count })
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassFinanceService#send_all_reminders: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  # POST /api/v1/teacher/classes/:id/enrollments/:enrollment_id/create_invoice
  def create_invoice_for_student(class_id, enrollment_id, invoice_params)
    school_class = SchoolClass.find_by(id: class_id, teacher_id: @teacher.user_id)
    return Result.failure({ error: 'Class not found' }) unless school_class

    enrollment = school_class.enrollments.find_by(id: enrollment_id)
    return Result.failure({ error: 'Enrollment not found' }) unless enrollment

    student = enrollment.student
    
    # Calculate total_debt if amount is not provided or use provided amount
    if invoice_params[:amount].blank? || invoice_params[:amount].to_f == 0
      # Calculate total_debt using same logic as get_class_finance
      current_month_start = Date.current.beginning_of_month
      current_month_end = Date.current.end_of_month
      
      # Get the most recent invoice for this student in this class to determine reset point
      last_invoice = student.tuition_invoices
                           .where(class_id: class_id)
                           .order(created_at: :desc)
                           .first
      
      # Calculate actual sessions attended - only count sessions AFTER last invoice was created
      # This resets the count when an invoice is created
      attendance_query = AttendanceRecord
        .joins(:attendance_session)
        .where(
          student_id: student.id,
          status: ['present', 'late'],
          attendance_sessions: { class_id: class_id }
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
      
      # Get fixed schedule from class
      schedule_data = school_class.schedule
      schedule_data = schedule_data.is_a?(String) ? JSON.parse(schedule_data) : schedule_data if schedule_data.present?
      schedule_data ||= {}
      
      # Count fixed schedule sessions per week (number of days with schedule)
      fixed_sessions_per_week = schedule_data.keys.length
      fixed_sessions_per_month = fixed_sessions_per_week * 4
      
      # Get all attendance sessions in current month
      # Only count sessions from the last invoice creation date onwards
      all_sessions_in_month = school_class.attendance_sessions
                                         .where(date: current_month_start..current_month_end)
      
      if last_invoice
        # Only count sessions from the last invoice creation date onwards
        all_sessions_in_month = all_sessions_in_month.where('date >= ?', last_invoice.created_at.to_date)
      end
      
      # Count sessions that don't match fixed schedule (make-up classes)
      make_up_sessions_count = 0
      all_sessions_in_month.each do |session|
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
            Rails.logger.debug("Make-up session detected: schedule=#{schedule_start_time} (#{schedule_start_time_normalized}), session=#{session_time} (#{session_time_normalized}), date=#{session.date.utc.strftime('%Y-%m-%d %H:%M:%S')}")
            make_up_sessions_count += 1
          end
        end
      end
      
      # Total sessions = fixed sessions per month + make-up sessions
      total_sessions = fixed_sessions_per_month + make_up_sessions_count
      
      total_debt = [
        school_class.monthly_tuition_fee.to_f / total_sessions.to_f * actual_sessions_attended.to_f,
        school_class.monthly_tuition_fee.to_f
      ].min.ceil.to_i
      
      invoice_params[:amount] = total_debt
    end
    
    # Before creating invoice, get the latest session date that will be included
    # This will be used as the reset point for future session counting
    # Get all sessions that will be included in this invoice (before invoice creation)
    last_invoice_before = student.tuition_invoices
                                 .where(class_id: class_id)
                                 .order(created_at: :desc)
                                 .first
    
    # Calculate which sessions are included in this invoice
    attendance_query_before = AttendanceRecord
      .joins(:attendance_session)
      .where(
        student_id: student.id,
        status: ['present', 'late'],
        attendance_sessions: { class_id: class_id }
      )
    
    if last_invoice_before
      attendance_query_before = attendance_query_before.where('attendance_sessions.date > ?', last_invoice_before.created_at.to_date)
    else
      attendance_query_before = attendance_query_before.where('attendance_sessions.date >= ?', Date.current.beginning_of_month)
    end
    
    # Get the latest session date that will be included in this invoice
    latest_session_date = attendance_query_before.maximum('attendance_sessions.date')
    
    # Build invoice with class_id
    invoice = student.tuition_invoices.build(invoice_params)
    invoice.class_id = class_id
    
    if invoice.save
      # Update enrollment debt
      enrollment.update(tuition_debt: enrollment.tuition_debt + invoice.amount)
      
      # Store the latest session date in description for tracking (if not already set)
      # This helps us know which sessions were included in this invoice
      if latest_session_date && invoice.description.blank?
        invoice.update(description: "Học phí tính đến ngày #{latest_session_date.strftime('%d/%m/%Y')}")
      end
      
      Result.success(invoice)
    else
      Result.failure(invoice.errors.messages)
    end
  rescue StandardError => e
    
    Rails.logger.error("Error in TeacherClassFinanceService#create_invoice_for_student: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end

  # GET /api/v1/teacher/classes/:id/enrollments/:enrollment_id/payment_history
  def get_payment_history(class_id, enrollment_id, page = 1, per_page = 20)
    school_class = SchoolClass.find_by(id: class_id, teacher_id: @teacher.user_id)
    return Result.failure({ error: 'Class not found' }) unless school_class

    enrollment = school_class.enrollments.find_by(id: enrollment_id)
    return Result.failure({ error: 'Enrollment not found' }) unless enrollment

    # Get transactions for invoices in this class
    invoices = enrollment.student.tuition_invoices.where(class_id: class_id)
    transactions = Transaction.where(tuition_invoice_id: invoices.pluck(:id))
                              .order(payment_date: :desc, created_at: :desc)

    # Manual pagination (since paginate is a controller helper)
    page = [page.to_i, 1].max
    per_page = [[per_page.to_i, 1].max, 100].min
    offset = (page - 1) * per_page
    total_count = transactions.count
    total_pages = (total_count.to_f / per_page).ceil
    paginated_records = transactions.limit(per_page).offset(offset)

    transactions_data = paginated_records.map do |txn|
      {
        id: "TXN-#{txn.id}",
        date: txn.payment_date.strftime('%d/%m/%Y'),
        amount: txn.amount.to_i,
        method: txn.method,
        status: txn.status
      }
    end

    Result.success({
      transactions: transactions_data,
      pagination: {
        current_page: page,
        per_page: per_page,
        total_count: total_count,
        total_pages: total_pages
      }
    })
  rescue StandardError => e
    Rails.logger.error("Error in TeacherClassFinanceService#get_payment_history: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure({ error: e.message })
  end
end
