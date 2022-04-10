module Api
  module Dashboard
    class ParkingSessionLogQuery < ApplicationQuery
      def call
        user, parking_session = options[:user], options[:parking_session]
        return [] unless user.admin?

        scope = parking_session.logs

        if options.dig(:range, :from)
          from = options.dig(:range, :from).to_date.beginning_of_day
          to = options.dig(:range, :to).blank? ? DateTime::Infinity.new : options.dig(:range, :to).to_date.end_of_day
          scope = scope.where(created_at: from..to)
        end

        scope
      end
    end
  end
end
