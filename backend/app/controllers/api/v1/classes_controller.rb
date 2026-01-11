# frozen_string_literal: true

module Api
  module V1
    class ClassesController < Api::V1::BaseController
      # GET /api/v1/classes
      def index
        classes = SchoolClass.all
        classes = classes.search_by_name(query_params[:search]) if query_params[:search].present?
        classes = classes.by_subject(query_params[:subject]) if query_params[:subject].present?
        result = paginate(classes, { per_page: query_params[:per_page] || 10, page: query_params[:page] || 1 })
        render_success(
          {
            classes: ClassSerializer.serialize_collection(result[:records]),
            pagination: result[:pagination]
          },
          :ok
        )
      end

      # GET /api/v1/classes/subjects
      def subjects
        subjects = SchoolClass.distinct.pluck(:subject)
        render_success({ subjects: subjects }, :ok)
      end

      private

      def query_params
        params.permit(:page, :per_page, :search, :subject)
      end
    end
  end
end
