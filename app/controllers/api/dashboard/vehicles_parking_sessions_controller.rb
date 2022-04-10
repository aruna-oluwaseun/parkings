module Api
  module Dashboard
    class VehiclesParkingSessionsController < ApplicationController
      api :GET, '/api/dashboard/vehicles/:id/parking_sessions', 'Fetch vehicle parking history details'
      param :vehicle_id, Integer, required: true
      header :Authorization, 'Auth token', required: true

      def index
        vehicle = Vehicle.find(params[:id])
        authorize! vehicle
        scope = paginate VehicleParkingHistoryQuery.call(params.merge(user: current_user, vehicle: vehicle))
        respond_with scope, each_serializer: ::Api::Dashboard::VehicleParkingSessionSerializer
      end

      private

      def per_page
        params[:per_page] || 20
      end
    end
  end
end
