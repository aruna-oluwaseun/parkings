module Api
  module Dashboard
    class NotificationsQuery < ::ApplicationQuery
      def call
        types, vehicle_id, user, statuses, ids = options[:types], options[:vehicle_id], options[:user], options[:status], options[:ids]
        scope = ::User::Notification.with_role_condition(options[:user])

        if ids.present?
          scope = scope.where(id: ids)
        end

        if statuses.respond_to?(:reject)
          scope = scope.where(status: statuses.reject { |status| !::User::Notification.statuses.keys.include?(status.to_s) })
        end

        if types.respond_to?(:reject)
          scope = scope.where(template: types.reject { |type| !::User::Notification.templates.keys.include?(type.to_s) })
        end

        if types.present?
          scope = scope.where(template: types)
        end

        if vehicle_id
          scope = scope.joins(user: :vehicles).where(vehicles: { id: vehicle_id })
        end

        scope.where.not(parking_session_id: nil).includes(parking_session: [:vehicle]).order("user_notifications.created_at desc")
      end
    end
  end
end
