module Api
  module Dashboard
    class VehicleParkingSessionSerializer < ::ApplicationSerializer
      attributes :id,
                 :check_in,
                 :check_out,
                 :parking_session_count,
                 :status,
                 :vehicle_id,
                 :plate_number,
                 :parking_lot_id,
                 :parking_slot_id,
                 :action_logs_count

      def plate_number
        object.vehicle.plate_number
      end

      def vehicle_id
        object.vehicle.id
      end

      def parking_session_count
        object.vehicle.parking_sessions.size
      end

      def parking_lot_id
        object.parking_lot_id
      end

      def parking_slot_id
        object.parking_slot_id
      end

      def action_logs_count
        object.logs.size
      end
    end
  end
end
