# frozen_string_literal: true

class AttendanceRecordService
  def initialize(attendance_session)
    @attendance_session = attendance_session
  end

  # List all attendance records for a session
  def list_records
    records = @attendance_session.attendance_records.includes(:student)
    Result.success(records)
  rescue StandardError => e
    Rails.logger.error("Error listing attendance records: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
    Result.failure({ error: e.message })
  end

  # Create or update an attendance record
  def create_or_update_record(params)
    student_id = params[:student_id]
    record_params = params.except(:student_id)

    record = @attendance_session.attendance_records.find_or_initialize_by(student_id:)

    if record.update(record_params)
      Result.success(record)
    else
      Result.failure(record.errors.messages)
    end
  rescue StandardError => e
    Rails.logger.error("Error creating/updating attendance record: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
    Result.failure({ error: e.message })
  end

  # Update an existing attendance record
  def update_record(record_id, params)
    record = @attendance_session.attendance_records.find_by(id: record_id)
    
    unless record
      Rails.logger.error("Attendance record #{record_id} not found for session #{@attendance_session.id}")
      return Result.failure({ error: 'Attendance record not found for this session' })
    end
    
    update_params = params.except(:student_id)
    
    Rails.logger.info("Updating attendance record #{record_id} with params: #{update_params.inspect}")
    Rails.logger.info("Current record status: #{record.status}")

    if record.update(update_params)
      Rails.logger.info("Successfully updated attendance record #{record_id}. New status: #{record.status}")
      Result.success(record)
    else
      Rails.logger.error("Failed to update attendance record #{record_id}. Errors: #{record.errors.messages.inspect}")
      Result.failure(record.errors.messages)
    end
  rescue StandardError => e
    Rails.logger.error("Error updating attendance record: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
    Result.failure({ error: e.message })
  end

  # Find a specific attendance record
  def find_record(record_id)
    record = @attendance_session.attendance_records.find(record_id)
    Result.success(record)
  rescue ActiveRecord::RecordNotFound => e
    Result.failure({ error: 'Attendance record not found' })
  rescue StandardError => e
    Rails.logger.error("Error finding attendance record: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
    Result.failure({ error: e.message })
  end
end
