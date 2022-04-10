module Api
  module Dashboard
    class ParkingSlotsController < ::Api::Dashboard::ApplicationController
      wrap_parameters :parking_slot
      before_action :find_parking_lot, only: [:index]
      before_action :find_parking_slot, only: [:show, :update, :sessions]

      api :GET, '/api/dashboard/parking_lots/:parking_lot_id/parking_slots', 'Parking slots list'
      header :Authorization, 'Auth token', required: true
      param :parking_lot_id, Integer, 'Parking lot ID', required: true
      param :per_page, Integer, 'Items per page count, default is 20. Check response headers for total count (key: X-Total)', required: false
      param :page, Integer, 'Items page number', required: false

      def index
        @parking_slot = @parking_lot.parking_slots
        return parking_slot_not_found! unless @parking_slot
        scope = @parking_lot.parking_slots.order('id DESC')
        respond_with scope, each_serializer: ::Api::Dashboard::Parking::SlotSerializer
      end

      api :GET, '/api/dashboard/parking_slots/:id', 'Display parking slots details'
      header :Authorization, 'Auth token', required: true
      param :id, Integer, 'Parking slot ID', required: true

      def show
        authorize! @parking_slot
        respond_with @parking_slot, serializer: ::Api::Dashboard::Parking::DetailedSlotSerializer
      end

      api :PUT, '/api/dashboard/parking_slots/:id', 'Update parking slot details'
      header :Authorization, 'Auth token', required: true
      param :parking_lot_id, Integer, 'Parking lot ID', required: true
      param :id, Integer, 'Parking slot ID', required: true
      param :parking_slot, Hash do
        param :name, String, 'Parking slot title', required: false
        param :archived, [true, false], 'Set to true means slot will be not allowed to used by vehicle'
      end

      def update
        authorize! @parking_slot
        payload = params.fetch(:parking_slot, {}).merge(parking_slot: @parking_slot, role: current_user.role)
        result = ::ParkingSlots::Update.run(payload)
        respond_with result, serializer: ::Api::Dashboard::Parking::DetailedSlotSerializer
      end

      api :GET, '/api/dashboard/parking_slots/:id/sessions', 'Parking slot sessions'
      param :id, Integer, 'Parking Slot ID', required: true
      param :per_page, Integer, 'Items per page count, default is 10. Check response headers for total count (key: X-Total)', required: false
      param :page, Integer, 'Items page number', required: false

      def sessions
        authorize! @parking_slot
        sessions = @parking_slot.parking_sessions
        respond_with paginate sessions, each_serializer: ::Api::Dashboard::Parking::SessionSerializer
      end

      private

      def per_page
        params[:per_page] || 20
      end

      def find_parking_lot
        @parking_lot = ParkingLot.find(params[:parking_lot_id])
      end

      def find_parking_slot
        @parking_slot = ParkingSlot.find(params[:id])
      end
    end
  end
end
