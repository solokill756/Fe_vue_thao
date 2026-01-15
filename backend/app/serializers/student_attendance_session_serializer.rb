# frozen_string_literal: true

class StudentAttendanceSessionSerializer
  def initialize(session, student_id)
    @session = session
    @student_id = student_id
  end

  def serialize
    record = @session.attendance_records.find { |r| r.student_id == @student_id }

    {
      id: @session.id,
      class_id: @session.class_id,
      date: @session.date,
      teacher_note: @session.teacher_note,
      student_record: record ? serialize_record(record) : nil
    }
  end

  def self.serialize_collection(sessions, student_id)
    sessions.map { |s| new(s, student_id).serialize }
  end

  private

  def serialize_record(record)
    {
      id: record.id,
      status: record.status,
      note: record.note,
      score_in_class: record.score_in_class
    }
  end
end

