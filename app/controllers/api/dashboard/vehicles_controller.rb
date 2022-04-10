module Api
  module Dashboard
    class VehiclesController < ::Api::Dashboard::ApplicationController
      before_action :authenticate_admin!, except: %i[verify]
      before_action :find_vehicle, only: [:active, :inactive, :rejected]

      api :GET, '/api/dashboard/vehicles', 'Search vehicle by plate number'
      param :vehicle, Hash do
        param :per_page, Integer, 'Items per page, default is 10. Check response headers for total count (key: X-Total)'
        param :page, Integer, 'Items page', required: false
        param :plate_number, String, 'Plate Number', required: true
      end
      header :Authorization, 'Auth token', required: true

      def index
        result = paginate ::Api::Dashboard::VehiclesQuery.call(params.merge(user: current_user))
        respond_with result, each_serializer: ::Api::Dashboard::VehicleSerializer
      end

      api :PUT, '/api/dashboard/vehicles/:id/active', 'Set Vehicle status to Active'
      header :Authorization, 'Auth token from users#sign_in', required: true
      param :id, Integer, 'Vehicle id', required: true

      def active
        set_vehicle_status(:active)
      end

      api :PUT, '/api/dashboard/vehicles/:id/inactive', 'Set Vehicle status to Inactive'
      header :Authorization, 'Auth token from users#sign_in', required: true
      param :id, Integer, 'Vehicle id', required: true

      def inactive
        set_vehicle_status(:inactive)
      end

      api :PUT, '/api/dashboard/vehicles/:id/rejected', 'Set Vehicle status to Rejected'
      header :Authorization, 'Auth token from users#sign_in', required: true
      param :id, Integer, 'Vehicle id', required: true

      def rejected
        set_vehicle_status(:rejected)
      end

      def show
        @result = ParkingSession.where(vehicle_id: params[:id])
        authorize! @result
        filtering_params(params).each do |key, value|
        @result = @result.public_send("filter_by_#{key}", value) if value.present?
        end
        respond_with @result, each_serializer: ::Api::Dashboard::ParkingSessionSerializer
      end

      def update
        @session = ParkingSession.find(params[:id])
        @session.update(status: :finished)
        respond_with @session, serializer: ::Api::Dashboard::ParkingSessionSerializer
      end

      private

      def find_vehicle
        @vehicle = Vehicle.find(params[:id])
      end

      def set_vehicle_status(status)
        @vehicle.update(status: status)
        VehicleMailer.try(status, @vehicle.id).deliver_later
        respond_with @vehicle, serializer: ::Api::Dashboard::VehicleSerializer
      end
      
      def filtering_params(params)
        params.slice(:created_at, :check_in, :check_out, :parking_lot_id)
      end
      
    end
  end
end
