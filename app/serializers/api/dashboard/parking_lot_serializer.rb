module Api
  module Dashboard
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
      has_many :violations, serializer:  Api::Dashboard::Parking::ViolationSerializer
      has_many :parking_slots, serializer: ThinParkingSlotSerializer
      def nearby_places
        object.places.order(distance: :asc).map { |v| Api::V1::PlaceSerializer.new(v) }
      end
    end
  end
end
