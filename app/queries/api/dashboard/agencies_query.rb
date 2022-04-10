module Api
  module Dashboard
    class AgenciesQuery < ApplicationQuery

      def call
        query, status, order, managers, id = options[:query], options[:status], options[:order], options[:managers], options[:id]

        scope = Agency.with_role_condition(options[:user])
        scope = scope.where(id: id) if id.present?

        scope = scope.where(id: id) if id.present?

        if query.present?
          sql_query = []
          attr_query = []

          %w(agencies locations admins).each do |model_name|
            if query[model_name.to_sym].present?
              query[model_name.to_sym].each do |attr, value|
                sql_query.push("#{model_name}.#{attr} ILIKE ?")
                attr_query.push("%#{value}%")
              end
            end
          end

          scope = scope.joins(:location).where(sql_query.join(' AND '), *attr_query).group('agencies.id')
          scope = scope.joins(:admins).where(sql_query.join(' AND '), *attr_query)
        end
        scope = scope.joins(:admins).where(admins: { id: managers }) if managers.present?

        scope = scope.joins(:admins).where(admins: { id: managers }) if managers.present?

        if order.present?
          keyword, direction = options[:order][:keyword], options[:order][:direction]
          scope = scope.order(Arel.sql("#{keyword} #{direction}")) unless keyword == 'admins.name' or keyword == 'agencies.types'
        end

        scope = scope.where(status: status) if status.present?

        scope.eager_load(:location)
        order_result scope, order
      end

      def order_result(scope, order)
        return scope unless order.present?
        keyword, direction = options[:order][:keyword], options[:order][:direction]
        if keyword == 'admins.name' && direction == 'asc'
          scope = scope.sort_by { |t| [t.manager&.name? ? 1 : 0, t.manager&.name] }
        elsif keyword == 'admins.name' && direction == 'desc'
          scope = scope.sort_by { |t| [t.manager&.name? ? 1 : 0, t.manager&.name] }.reverse
        elsif keyword == 'agencies.types' && direction == 'asc'
          scope = scope.sort_by { |t| [t&.agency_type&.name? ? 1 : 0, t&.agency_type&.name] }
        elsif keyword == 'agencies.types' && direction == 'desc'
          scope = scope.sort_by { |t| [t&.agency_type&.name? ? 1 : 0, t&.agency_type&.name] }.reverse
        end
        scope
      end
    end
  end
end

