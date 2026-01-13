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
