module Dashboard
  module Redis
    class SaveParkingLotPlaces
      # @overload call
      # This method saves list of parking lot places to Redis storage
      # @param [ParkingLot] parking_lot
      # @return [String]
      def self.call(parking_lot)
        @parking_lot = parking_lot
        parking_lot_places = build_places

        return if parking_lot_places.blank?

        $redis_manager.parking_lot_places.set(
          "parking_lot_#{@parking_lot.id}_places",
          {
            parking_lot_places: parking_lot_places
          }.to_json
        )
      rescue => exc
        Raven.capture_exception(exc)
      end

      # @overload build_places
      # This method maps list of parking lot places to needful format
      # @example
      # {
      #   name: 'Minsk Hotel',
      #   lat: 53.896622,
      #   lng: 27.55041,
      #   types: ['casino']
      # }
      # @return [Hash]
      def self.build_places
        parking_lot_places_data = ::Dashboard::GooglePlacesFinder.call(@parking_lot)

        parking_lot_places_data.first(10).map do |parking_lot_place|
          {
            name: parking_lot_place.name,
            lat: parking_lot_place.lat,
            lng: parking_lot_place.lng,
            types: parking_lot_place.types
          }
        end
      end
    end
  end
end

# {
#   name: 'Minsk Hotel',
#   lat: 53.896622,
#   lng: 27.55041,
#   types: ['casino']
# }
