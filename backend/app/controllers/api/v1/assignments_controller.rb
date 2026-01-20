# frozen_string_literal: true

module Api
  module V1
    class AssignmentsController < Api::V1::BaseController
      # POST /api/v1/assignments
      def create
        # Handle file upload separately
        params_hash = assignment_params.to_h
        params_hash[:file] = params[:file] if params[:file].present?
        
        result = AssignmentService.new.create(params_hash)

        if result.success?
          student = @current_user.role == 'student' ? @current_user.student_profile : nil
          render_success(AssignmentSerializer.serialize(result.data, student), :created)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # GET /api/v1/assignments/list-by-student
      def list_by_student
        student = @current_user.student_profile
        class_id = query_params[:class_id]&.to_i
        result = AssignmentService.new.list_by_student(student, class_id)
        if result.success?
          assignments = result.data.includes({school_class: :teacher}, :submissions, :assignment_attachments)
          subject =query_params[:subject]
          assignments = assignments.by_class_subject(subject) if subject.present?
          assignments = assignments.search_by_title(query_params[:title]) if query_params[:title].present?
          if query_params[:submission_status].present?
            assignments = assignments.no_submission_for_student(student.id) if query_params[:submission_status] == 'no_submission'
            assignments = assignments.by_submission_status_for_student(
              query_params[:submission_status], student.id
            ) if %w[submitted graded late].include?(query_params[:submission_status])
          end
          ans = paginate(assignments, { per_page: query_params[:page_size] || query_params[:per_page] || 10, page: query_params[:page] || 1 })
          render_success(
            {
              assignments: AssignmentSerializer.serialize_collection(ans[:records], student),
              pagination: ans[:pagination]
            },
            :ok
          )
        else
          render_error(result.errors, :bad_request)
        end
      end
      
      # GET /api/v1/assignments/list-by-class
      def list_by_class
        class_id = params[:class_id]
        result = AssignmentService.new.list_by_class(class_id)
        
        if result.success?
          assignments = result.data.includes({school_class: :teacher}, :submissions, :assignment_attachments)
          subject = query_params[:subject]
          assignments = assignments.by_class_subject(subject) if subject.present?
          assignments = assignments.search_by_title(query_params[:title]) if query_params[:title].present?
          
          # For teacher, serialize without student context
          student = @current_user.role == 'student' ? @current_user.student_profile : nil
          
          ans = paginate(assignments, { per_page: query_params[:page_size] || query_params[:per_page] || 10, page: query_params[:page] || 1 })
          render_success(
            {
              assignments: AssignmentSerializer.serialize_collection(ans[:records], student),
              pagination: ans[:pagination]
            },
            :ok
          )
        else
          render_error(result.errors, :bad_request)
        end
      end
      # GET /api/v1/assignments/:id
      def show
        result = AssignmentService.new.by_id(params[:id])
        if result.success?
          # Reload assignment with necessary associations
          assignment = Assignment.includes({school_class: :teacher}, :submissions, :assignment_attachments).find(params[:id])
          
          # For teacher, serialize without student context
          student = @current_user.role == 'student' ? @current_user.student_profile : nil
          
          render_success(AssignmentSerializer.serialize(assignment, student), :ok)
        else
          render_error(result.errors, :bad_request)
        end
      end

      # PATCH /api/v1/assignments/:id
      def update
        assignment = Assignment.find(params[:id])
        debugger
        # Check if teacher owns the class
        if @current_user.role == 'teacher'
          unless assignment.school_class.teacher.user_id == @current_user.id
            return render_error('Unauthorized', :unauthorized)
          end
        end
        
        # Handle file upload separately
        params_hash = assignment_params.to_h
        params_hash[:file] = params[:file] if params[:file].present?
        
        result = AssignmentService.new.update(assignment, params_hash)
        
        if result.success?
          student = @current_user.role == 'student' ? @current_user.student_profile : nil
          render_success(AssignmentSerializer.serialize(result.data, student), :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # DELETE /api/v1/assignments/:id
      def destroy
        assignment = Assignment.find_by_id(params[:id])
        # Check if teacher owns the class
        if @current_user.role == 'teacher'
          unless assignment.school_class.teacher_id == @current_user.id.to_i
            return render_error('Unauthorized', :unauthorized)
          end
        end
        
        result = AssignmentService.new.delete(assignment)
        
        if result.success?
          render_success({ message: 'Assignment deleted successfully' }, :ok)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # GET /api/v1/assignments/:id/submissions
      def submissions
        begin
          assignment_id = params[:id]
          # teacher_id in SchoolClass is user_id, so we use @current_user.id directly
          teacher_id = @current_user.role == 'teacher' ? @current_user.id : nil
          
          result = SubmissionService.new.list_by_assignment(assignment_id, teacher_id)
          
          if result.success?
            # Serialize submissions with student info
            submissions_data = result.data.map do |submission|
              # Handle both Submission objects and OpenStruct objects
              if submission.is_a?(Submission)
                student = submission.student
                student_user = student.user
                
                file_url = if submission.file.attached?
                            Rails.application.routes.url_helpers.rails_blob_path(submission.file, only_path: true)
                          end
                
                {
                  id: submission.id,
                  student_id: student.id,
                  student_name: student_user.full_name,
                  student_code: student.student_code,
                  avatar: student_user.photo_url,
                  assignment_id: submission.assignment_id,
                  content: submission.content,
                  file_url: file_url,
                  file_name: submission.file.attached? ? submission.file.filename.to_s : nil,
                  submitted_at: submission.submitted_at&.iso8601,
                  status: submission.status,
                  score: submission.score,
                  teacher_feedback: submission.teacher_feedback,
                }
              else
                # Handle placeholder submissions (missing submissions) - OpenStruct
                student = submission.student
                student_user = student.user
                
                {
                  id: nil,
                  student_id: student.id,
                  student_name: student_user.full_name,
                  student_code: student.student_code,
                  avatar: student_user.photo_url,
                  assignment_id: assignment_id.to_i,
                  content: nil,
                  file_url: nil,
                  file_name: nil,
                  submitted_at: nil,
                  status: 'missing',
                  score: nil,
                  teacher_feedback: nil,
                }
              end
            end
            
            render_success({ submissions: submissions_data }, :ok)
          else
            render_error(result.errors, :bad_request)
          end
        rescue StandardError => e
          Rails.logger.error("Error in submissions action: #{e.message}")
          Rails.logger.error(e.backtrace.join("\n"))
          render_error({ error: e.message }, :internal_server_error)
        end
      end

      private

      def assignment_params
        params.require(:assignment).permit(:title, :content, :due_date, :class_id)
      end

      def query_params
        params.permit(:page, :page_size, :subject, :title, :submission_status, :class_id)
      end
    end
  end
end
