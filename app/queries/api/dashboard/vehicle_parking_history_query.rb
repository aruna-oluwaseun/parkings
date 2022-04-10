module Api
  module Dashboard
    class VehicleParkingHistoryQuery < ApplicationQuery
      def call
        user, vehicle = options[:user], options[:vehicle]
        return [] unless user.town_manager? || user.admin?

        scope = vehicle.parking_sessions

        if user.town_manager?
          scope = scope.joins({ parking_lot: :admins }).where(admins: { id: user.id })
        end

        scope
      end
    end
  end
end
