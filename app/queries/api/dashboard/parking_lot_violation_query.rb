module Api
  module Dashboard
    class ParkingLotViolationQuery < ::ApplicationQuery
      def call
        parking_lot, user, vehicle_id, violation_type = options[:parking_lot], options[:user], options[:vehicle_id], options[:violation_type]

        scope = ::Parking::Violation
                  .joins(session: { parking_lot: :admins }, vehicle_rule: :vehicle, rule: :lot, ticket: :agency)
                  .where(parking_tickets: { status: ::Parking::Ticket.statuses[:opened] })
                  .where(vehicles: { id: vehicle_id })
                  .where(parking_sessions: { parking_lot_id: parking_lot.id })

        unless user.admin?
          scope = scope.where(admins: { id: user.id })
        end

        if options.dig(:range, :from)
          from = options.dig(:range, :from).to_date.beginning_of_day
          to = options.dig(:range, :to).blank? ? DateTime::Infinity.new : options.dig(:range, :to).to_date.end_of_day
          scope = scope.where(created_at: from..to)
        end

        if violation_type
          scope = scope.where(parking_rules: { name: ::Parking::Rule.names[violation_type] })
        end

        scope.uniq
      end
    end
  end
end
