module Dashboard
  module Redis
    class RetrieveParkingLotPlaces
      # @overload call
      # This method retrieves list of parking lot places from Redis storage
      # @param [Integer] parking_lot_id
      # @return [Hash]
      def self.call(parking_lot_id)
        redis_data = $redis_manager.parking_lot_places.get("parking_lot_#{parking_lot_id}_places")

        return [] unless redis_data

        JSON.parse(redis_data).values
      end
    end
  end
end
