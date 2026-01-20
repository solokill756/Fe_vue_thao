# frozen_string_literal: true

class AssignmentService
  def create(params)
   
    file = params.delete(:file)
    
    assignment = Assignment.new(params)
    if assignment.save
      # Create assignment attachment if file is provided
      if file.present?
        upload_result = FileUploadService.upload_submission_file(file)
        unless upload_result[:success]
          assignment.destroy
          return Result.failure({ error: upload_result[:error] })
        end
        
        # Upload file using Active Storage (local)
        begin
          attachment = assignment.assignment_attachments.build(
            file_name: upload_result[:file_name]
          )
          
          # Attach file using Active Storage
          attachment.file.attach(
            io: file,
            filename: upload_result[:file_name],
            content_type: file.content_type
          )
          
          # Get file URL after attachment and save to database column
          # (Schema requires file_url to be not null)
          if attachment.file.attached?
            file_url = Rails.application.routes.url_helpers.rails_blob_path(
              attachment.file,
              only_path: true
            )
            attachment.file_url = file_url
          else
            assignment.destroy
            return Result.failure({ error: 'Failed to attach file' })
          end
          
          unless attachment.save
            assignment.destroy
            return Result.failure({ error: 'Failed to create attachment' })
          end
        rescue StandardError => e
          Rails.logger.error("Error uploading assignment file: #{e.message}\n#{e.backtrace.join("\n")}")
          assignment.destroy
          return Result.failure({ error: "Failed to upload file: #{e.message}" })
        end
      end
      
      Result.success(assignment)
    else
      Result.failure(assignment.errors.messages)
    end
  rescue StandardError => e
    debugger
    Result.failure({ error: e.message })
  end

  def update(assignment, params)
    file = params.delete(:file)
    
    # Update assignment attributes
    if assignment.update(params)
      # Handle file update if provided
      if file.present?
        # Delete existing attachment if any
        assignment.assignment_attachments.destroy_all
        
        upload_result = FileUploadService.upload_submission_file(file)
        unless upload_result[:success]
          return Result.failure({ error: upload_result[:error] })
        end
        
        # Upload file using Active Storage (local)
        begin
          attachment = assignment.assignment_attachments.build(
            file_name: upload_result[:file_name]
          )
          
          # Attach file using Active Storage
          attachment.file.attach(
            io: file,
            filename: upload_result[:file_name],
            content_type: file.content_type
          )
          
          # Get file URL after attachment and save to database column
          if attachment.file.attached?
            file_url = Rails.application.routes.url_helpers.rails_blob_path(
              attachment.file,
              only_path: true
            )
            attachment.file_url = file_url
          else
            return Result.failure({ error: 'Failed to attach file' })
          end
          
          unless attachment.save
            return Result.failure({ error: 'Failed to create attachment' })
          end
        rescue StandardError => e
          Rails.logger.error("Error uploading assignment file: #{e.message}\n#{e.backtrace.join("\n")}")
          return Result.failure({ error: "Failed to upload file: #{e.message}" })
        end
      end
      
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
    Rails.logger.error("Error fetching assignment by id: #{e.message}")
    Result.failure({ error: e.message })
  end

  def list_by_class(class_id)
    assignments = Assignment.by_class(class_id)
    Result.success(assignments)
  rescue StandardError => e
    Result.failure({ error: e.message })
  end

  def list_by_student(student, class_id = nil)
    class_ids = student.school_classes.pluck(:id)
    assignments = Assignment.where(class_id: class_ids).order(created_at: :desc)
    
    # Filter by class_id if provided
    if class_id.present?
      assignments = assignments.where(class_id: class_id)
    end
    
    Result.success(assignments)
  rescue StandardError => e
    Result.failure({ error: e.message })
  end
end
