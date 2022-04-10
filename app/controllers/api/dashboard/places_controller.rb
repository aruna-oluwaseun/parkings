module Api
  module Dashboard
    class PlacesController < ApplicationController
      api :GET, '/api/dashboard/parking_lots/:parking_lot_id/places', 'Get list of nearest parking lot places'
      header :Authorization, 'Auth token', required: true
      param :parking_lot_id, String, 'Parking lot ID', required: true

      def index
        parking_lot = ::ParkingLot.find(params[:parking_lot_id])
        scope = ::Dashboard::Redis::RetrieveParkingLotPlaces.call(parking_lot.id)
        respond_with places: scope
      end
    end
  end
end
