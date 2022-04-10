module Api
  module V1
    class VehiclesController < ::Api::V1::ApplicationController
      before_action :authenticate_user!, except: %i[verify]
      before_action :find_vehicle, only: [:active, :inactive, :rejected]

      api :GET, '/api/v1/vehicles', 'Search vehicle by plate number'
      param :vehicle, Hash do
        param :user_associated, [0, 1], 'Indicates if the vehicle should have a user associated to it'
        param :per_page, Integer, 'Items per page, default is 10. Check response headers for total count (key: X-Total)'
        param :page, Integer, 'Items page', required: false
        param :plate_number, String, 'Plate Number', required: true
      end
      header :Authorization, 'Auth token from users#sign_in', required: true

      def index
        result = ::Api::V1::VehiclesQuery.call(params.fetch(:vehicle, {}).merge(user: current_user))
        respond_with paginate(result), each_serializer: ::Api::V1::VehicleSerializer
      end

      api :POST, '/api/v1/vehicles', 'Create new user vehicle'
      param :vehicle, Hash do
        param :plate_number, String, required: true
        param :vehicle_type, String, required: false
        param :color, String, required: false
        param :manufacturer_id, Integer, required: false
        param :model, String, required: true
        param :registration_card, String, 'File or base64', required: true
        param :registration_state, String, required: true
      end
      header :Authorization, 'Auth token from users#sign_in', required: true

      def create
        payload = params.fetch(:vehicle, {}).merge(user: current_user)
        result = ::Vehicles::Create.run(payload)
        respond_with result, serializer: ::Api::V1::VehicleSerializer
      end

      api :GET, '/api/v1/vehicles/verify', 'Verify if vehicle will be allowed to register'
      param :vehicle, Hash do
        param :plate_number, String, 'Vehicle id', required: true
      end

      def verify
        plate_number = (params.dig(:vehicle,:plate_number) || '').delete(' ')
        if plate_number.present?
          allowed = Vehicle.find_or_initialize_by(plate_number: plate_number).user_id == nil ? true : false
          message = I18n.t('active_interaction.errors.models.vehicles/create.attributes.base.already_taken_by_another_account', { plate_number: plate_number.upcase }) unless allowed
        else
          allowed = false
          message = I18n.t('activerecord.errors.models.vehicle.attributes.plate_number.invalid')
        end
        render json: {
          allowed: allowed,
          message: message
        }, status: 200
      end
    end
  end
end
