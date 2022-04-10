module Api
  module Dashboard
    class UsersQuery < ApplicationQuery

      def call
        query,range, order = options[:query], options[:range], options[:order]

        scope = User.all

        if options.dig(:range, :from)
           from = options.dig(:range, :from).to_date.beginning_of_day
           to = options.dig(:range, :to).blank? ? DateTime::Infinity.new : options.dig(:range, :to).to_date.end_of_day
           scope = scope.where(created_at: from..to)
        end

        if query.present?
          if query[:users].present?
            sql_query = []
            attr_query = []
            query[:users].each do |attr, value|
              sql_query.push("users.#{attr} ilike ?")
              attr_query.push("%#{value}%")
            end
            scope = scope.where(sql_query.join(' AND '), *attr_query)
          end
        end

        if order.present?
          keyword, direction = order[:keyword], order[:direction]
          scope = scope.order(Arel.sql("users.#{keyword} #{direction}")) if keyword.present? && direction.present?
        else
          scope = scope.order(Arel.sql('users.created_at desc'))
        end
        scope
      end
    end
  end
end
