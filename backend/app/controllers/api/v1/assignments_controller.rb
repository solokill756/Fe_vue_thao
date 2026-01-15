# frozen_string_literal: true

module Api
  module V1
    class AssignmentsController < Api::V1::BaseController
      # POST /api/v1/assignments
      def create
        result = AssignmentService.new.create(assignment_params)

        if result.success?
          render_success(AssignmentSerializer.serialize(result.data, @current_user.student), :created)
        else
          render_error(result.errors, :unprocessable_entity)
        end
      end

      # GET /api/v1/assignments/list-by-student
      def list_by_student
        student = @current_user.student_profile
        result = AssignmentService.new.list_by_student(student)
        if result.success?
          assignments = result.data.includes({school_class: :teacher}, :submissions, :assignment_attachments)
          subject =query_params[:subject]
          assignments = assignments.by_class_subject(subject) if subject.present?
          assignments = assignments.search_by_title(query_params[:title]) if query_params[:title].present?
          if query_params[:submission_status].present?
            assignments = assignments.no_submission_for_student(student.id) if query_params[:submission_status] == 'no_submission'
            assignments = assignments.by_submission_status_for_student(
              query_params[:submission_status], student.id
            ) if %w[submitted graded].include?(query_params[:submission_status])
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
          subject =query_params[:subject]
          assignments = assignments.by_class_subject(subject) if subject.present?
          assignments = assignments.search_by_title(query_params[:title]) if query_params[:title].present?
          if query_params[:submission_status].present?
            assignments = assignments.no_submission_for_student(student.id) if query_params[:submission_status] == 'no_submission'
            assignments = assignments.by_submission_status_for_student(
              query_params[:submission_status], student.id
            ) if %w[submitted graded].include?(query_params[:submission_status])
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
      # GET /api/v1/assignments/:id
      def show
        result = AssignmentService.new.by_id(params[:id])
        if result.success?
          render_success(AssignmentSerializer.serialize(result.data, @current_user.student_profile), :ok)
        else
          render_error(result.errors, :bad_request)
        end
      end

      private

      def assignment_params
        params.require(:assignment).permit(:title, :description, :due_date, :class_id) # Replace with actual attributes
      end

      def query_params
        params.permit(:page, :page_size,  :subject, :title, :submission_status)
      end
    end
  end
end
