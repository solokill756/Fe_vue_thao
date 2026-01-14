# frozen_string_literal: true

class ClassService
  def create(params)
    class_obj = Class.new(params)

    if class_obj.save
      Result.success(class_obj)
    else
      Result.failure(class_obj.errors.messages)
    end
  rescue StandardError => e
    Result.failure({ error: e.message })
  end

  def update(class_obj, params)
    if class_obj.update(params)
      Result.success(class_obj)
    else
      Result.failure(class_obj.errors.messages)
    end
  rescue StandardError => e
    Result.failure({ error: e.message })
  end

  def delete(class_obj)
    if class_obj.destroy
      Result.success({ message: 'Class deleted successfully' })
    else
      Result.failure(class_obj.errors.messages)
    end
  rescue StandardError => e
    Result.failure({ error: e.message })
  end

  def teacher_classes(teacher_id)
    classes = SchoolClass.where(teacher_id:)
    Result.success(classes)
  rescue StandardError => e
    Result.failure({ error: e.message })
  end
  
  def student_of_class(class_id)
    students = Student.joins(:enrollments).where(enrollments: { class_id: })
    Result.success(students)
  rescue StandardError => e
    Result.failure({ error: e.message })
  end

  def class_subjects(class_id)
    subjects = SchoolClass.where(id: class_id).pluck(:subject)
    Result.success(subjects)
  rescue StandardError => e
    Result.failure({ error: e.message })
  end
end
