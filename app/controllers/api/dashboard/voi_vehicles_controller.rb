module Api
  module Dashboard
    class VoiVehiclesController < ApplicationController
      api :GET, '/api/dashboard/voi_vehicles', 'VOI vehicles list'
      param :parking_lot_id, Integer, required: true
      header :Authorization, 'Auth token', required: true
      param :per_page, Integer, 'Items per page count, default is 10. Check response headers for total count (key: X-Total)', required: false
      param :page, Integer, 'Items page number', required: false
      param :plate_number, String, required: false

      def index
        parking_lot = ::ParkingLot.find(params[:parking_lot_id])
        authorize! parking_lot
        scope = paginate ::Api::Dashboard::VoiVehiclesQuery.call(params.merge(user: current_user, parking_lot: parking_lot))
        respond_with scope, each_serializer: ::Api::Dashboard::VehicleSerializer
      end

      private

      def per_page
        params[:per_page] || 20
      end
    end
  end
end
