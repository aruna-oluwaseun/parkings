module Dashboard
  # This class gives a place to put business logic to call Google Places API
  class GooglePlacesFinder
    # @overload call
    # This method shows list of nearest places based on ltd and lng parameters
    # It returns a GooglePlaces::Spot or a collection of those.
    # @param [ParkingLot] parking_lot
    # @return [GooglePlaces::Spot]
    def self.call(parking_lot, radius=1000)
      $google_places_client.spots(
        parking_lot.location.ltd,
        parking_lot.location.lng,
        exclude: ['locality', 'political'],
        radius: radius
      )
    rescue GooglePlaces::InvalidRequestError, GooglePlaces::NotFoundError, GooglePlaces::RequestDeniedError
      []
    end
  end
end
