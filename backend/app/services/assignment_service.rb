# frozen_string_literal: true

class AssignmentService
  def create(params)
    assignment = Assignment.new(params)
    if assignment.save
      Result.success(assignment)
    else
      Result.failure(assignment.errors.messages)
    end
  rescue StandardError => e
    Result.failure({ error: e.message })
  end

  def update(assignment, params)
    if assignment.update(params)
      Result.success(assignment)
    else
      Result.failure(assignment.errors.messages)
    end
  rescue StandardError => e
    Result.failure({ error: e.message })
  end

  def delete(assignment)
    if assignment.destroy
      Result.success({ message: 'Assignment deleted successfully' })
    else
      Result.failure(assignment.errors.messages)
    end
  rescue StandardError => e
    Result.failure({ error: e.message })
  end

  def by_id(id)
    assignment = Assignment.find_by(id: id)
    if assignment
      Result.success(assignment)
    else
      Result.failure({ error: 'Assignment not found' })
    end
  rescue StandardError => e
    Result.failure({ error: e.message })
  end

  def list_by_class(class_id)
    assignments = Assignment.by_class(class_id)
    Result.success(assignments)
  rescue StandardError => e
    Result.failure({ error: e.message })
  end

  def list_by_student(student)
    class_ids = student.school_classes.pluck(:id)
    assignments = Assignment.where(class_id: class_ids).order(created_at: :desc)
    Result.success(assignments)
  rescue StandardError => e
    Result.failure({ error: e.message })
  end
end
