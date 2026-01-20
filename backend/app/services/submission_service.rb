# frozen_string_literal: true

class SubmissionService
  def create(params, student_id)
    check_student_exits_in_class(student_id, Assignment.find(params[:assignment_id]).class_id)

    assignment = Assignment.find(params[:assignment_id])
    status = determine_submission_status(assignment)

    submission = Submission.new(
      assignment_id: params[:assignment_id],
      student_id: student_id,
      content: params[:content],
      submitted_at: params[:submitted_at] || Time.current,
      status: status,
    )

    if params[:file].present?
      upload_result = FileUploadService.upload_submission_file(params[:file])
      return Result.failure(upload_result[:error]) unless upload_result[:success]
      
      submission.file.attach(
        io: params[:file],
        filename: upload_result[:file_name],
        content_type: params[:file].content_type
      )
    end

    if submission.save
      Result.success(submission)
    else
      Result.failure(submission.errors.messages)
    end
  rescue StandardError => e
    Result.failure({ error: e.message })
  end
 
  def update(submission, params)
    if submission.update(params)
      Result.success(submission)
    else
      Result.failure(submission.errors.messages)
    end
  rescue StandardError => e
    Result.failure({ error: e.message })
  end

  def delete(submission)
    if submission.destroy
      Result.success({ message: 'Submission deleted successfully' })
    else
      Result.failure(submission.errors.messages)
    end
  rescue StandardError => e
    Result.failure({ error: e.message })
  end

  def list_by_student(student_id, assignment_id = nil)
    submissions = Submission.by_student(student_id)
    submissions = submissions.where(assignment_id: assignment_id) if assignment_id.present?
    Result.success(submissions)
  rescue StandardError => e
    Result.failure({ error: e.message })
  end

  def list_by_assignment(assignment_id, teacher_id = nil)
    assignment = Assignment.find(assignment_id)
    
    # Check if teacher has access to this assignment's class
    if teacher_id.present?
      # teacher_id is user_id, so we need to compare with school_class.teacher_id (which is also user_id)
      class_teacher_id = assignment.school_class.teacher_id
      unless class_teacher_id == teacher_id
        return Result.failure({ error: 'You do not have permission to view submissions for this assignment' })
      end
    end

    # Get all students in the class (only active enrollments)
    class_students = assignment.school_class.students
                                .joins(:enrollments)
                                .where(enrollments: { class_id: assignment.class_id, status: 'active' })
                                .includes(:user)
                                .distinct
    
    # Get all submissions for this assignment
    submissions = Submission.by_assignment(assignment_id).includes(:student, :assignment)
    
    # Create a map of student_id => latest submission
    submission_map = {}
    submissions.each do |submission|
      student_id = submission.student_id
      if !submission_map[student_id] || 
         (submission.submitted_at && submission_map[student_id].submitted_at && 
          submission.submitted_at > submission_map[student_id].submitted_at) ||
         (!submission_map[student_id].submitted_at && submission.submitted_at)
        submission_map[student_id] = submission
      end
    end
    
    # Build response with all students, including those without submissions
    result_submissions = class_students.map do |student|
      submission = submission_map[student.id]
      if submission
        submission
      else
        # Create a placeholder submission for students who haven't submitted
        OpenStruct.new(
          id: nil,
          student_id: student.id,
          assignment_id: assignment_id,
          content: nil,
          file_url: nil,
          file_name: nil,
          submitted_at: nil,
          status: 'missing',
          score: nil,
          teacher_feedback: nil,
          student: student
        )
      end
    end
    
    Result.success(result_submissions)
  rescue ActiveRecord::RecordNotFound => e
    Result.failure({ error: 'Assignment not found' })
  rescue StandardError => e
    Rails.logger.error("Error in list_by_assignment: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    Result.failure({ error: e.message })
  end

  def grade_submission(submission_id, teacher_id, params)
    debugger
    submission = Submission.find_by(id: submission_id)
    assignment = submission.assignment
    
    # Check if teacher has access to this submission's assignment class
    if teacher_id.present?
      unless assignment.school_class.teacher_id == teacher_id.to_i
        return Result.failure({ error: 'You do not have permission to grade this submission' })
      end
    end

    if submission.update(params)
      Result.success(submission)
    else
      Result.failure(submission.errors.messages)
    end
  rescue ActiveRecord::RecordNotFound => e
    Result.failure({ error: 'Submission not found' })
  rescue StandardError => e
    Result.failure({ error: e.message })
  end

  private

  def check_student_exits_in_class(student_id, class_id)
    exists = Enrollment.exists?(student_id: student_id, class_id: class_id)
    return if exists

    raise StandardError, 'Student is not enrolled in the class'
  end

  def determine_submission_status(assignment)
    return 'late' if assignment.due_date.present? && Time.current > assignment.due_date
    'submitted'
  end
end
