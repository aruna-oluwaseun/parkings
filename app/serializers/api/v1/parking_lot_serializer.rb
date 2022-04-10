module Api
  module V1
    class ParkingLotSerializer < ::ParkingLotSerializer
      attributes :id,
                 :name,
                 :available,
                 :capacity,
                 :rate,
                 :free,
                 :email,
                 :period,
                 :phone,
                 :nearby_places

      has_one :location, serializer: LocationSerializer

      def nearby_places
        ::Dashboard::Redis::RetrieveParkingLotPlaces.call(object.id)
      end
    end
  end
end
