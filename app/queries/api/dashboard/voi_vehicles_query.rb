module Api
  module Dashboard
    class VoiVehiclesQuery < ::ApplicationQuery
      def call
        user, parking_lot, plate_number = options[:user], options[:parking_lot], options[:plate_number]

        scope = ::Vehicle.joins(parking_sessions: [ { violations: :ticket }, { parking_lot: :admins } ])
                         .where(parking_lots: { id: parking_lot.id })
                         .where(parking_tickets: { status: ::Parking::Ticket.statuses[:opened] })

        unless user.admin?
          scope = scope.where(admins: { id: user.id })
        end

        if plate_number
          scope = scope.where(plate_number: plate_number)
        end

        scope.uniq
      end
    end
  end
end
