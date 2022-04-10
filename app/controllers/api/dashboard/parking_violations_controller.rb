module Api
  module Dashboard
    class ParkingViolationsController < ::Api::Dashboard::ApplicationController
      api :GET, '/api/dashboard/parking_lots/:parking_lot_id/parking_violations', 'Parking lot violations list'
      header :Authorization, 'Auth token', required: true
      param :parking_lot_id, String, 'Parking lot ID', required: true
      param :vehicle_id, String, 'Vehicle ID', required: true
      param :range, Hash, 'When the parking violation was created', required: false do
        param :from, String, 'Date formatted %Y-%m-%d', required: false
        param :to, String, 'Date formatted %Y-%m-%d', required: false
      end
      param :violation_type, ::Parking::Rule.names.keys, required: true

      def index
        parking_lot = ParkingLot.find(params[:parking_lot_id])
        vehicle = Vehicle.find(params[:vehicle_id])
        scope = paginate ParkingLotViolationQuery.call(params.merge(user: current_user, parking_lot: parking_lot))
        respond_with scope, each_serializer: ::Api::Dashboard::Parking::ThinViolationSerializer
      end
    end
  end
end


