module Api
  module Dashboard
    class CommentsQuery < ApplicationQuery
      def call
        subject_type, subject_id, officer_id = options[:subject_type], options[:subject_id], options[:officer_id]

        scope = Comment.where(subject_type: subject_type, subject_id: subject_id)

        sql_query, attr_query = [], []

        if options.dig(:range, :from)
          from = options.dig(:range, :from).to_date.beginning_of_day
          to = options.dig(:range, :to).blank? ? DateTime::Infinity.new : options.dig(:range, :to).to_date.end_of_day
          scope = scope.where(created_at: from..to)
        end

        if officer_id
          sql_query.push('comments.admin_id = ?')
          attr_query.push(officer_id)
        end

        scope.where(sql_query.join(' AND '), *attr_query).order('created_at DESC')
      end
    end
  end
end
