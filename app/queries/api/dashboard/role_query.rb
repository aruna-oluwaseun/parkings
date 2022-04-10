module Api
  module Dashboard
    class RoleQuery < ::ApplicationQuery
      def call
        user, order = options[:user], options[:order]
        return [] unless user.super_admin?

        scope = Role.all

        if order.present?
          keyword, direction = options[:order][:keyword], options[:order][:direction]
          scope = scope.order(Arel.sql("#{keyword} #{direction}"))
        else
          scope = scope.order(Arel.sql('created_at desc'))
        end

        scope
      end
    end
  end
end
