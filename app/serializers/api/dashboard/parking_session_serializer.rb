module Api
  module Dashboard
    class ParkingSessionSerializer < ::ParkingSessionSerializer
      attributes :id,
        :check_in,
        :check_out,
        :created_at,
        :slot,
        :uuid,
        :paid,
        :total_price

      belongs_to :parking_lot, key: :lot, serializer: Api::V1::Parking::ThinLotSerializer
      belongs_to :vehicle, serializer: ThinVehicleSerializer
      has_many :images, serializer: ImageSerializer

      def slot
        { id: parking_slot.name } if parking_slot
      end

      def total_price
        payment_info.pay
      end
    end
  end
end
