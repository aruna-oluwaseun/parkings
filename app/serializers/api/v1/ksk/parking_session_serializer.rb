module Api
  module V1
    module Ksk
      class ParkingSessionSerializer < ::ParkingSessionSerializer
        attributes :id,
          :check_in,
          :check_out,
          :created_at,
          :slot,
          :paid,
          :total_price,
          :vehicle

        belongs_to :parking_lot, key: :lot, serializer: Api::V1::Ksk::Parking::ThinLotSerializer

        def vehicle
          {
            plate_number: object.ksk_plate_number =~ /[*:]/ ? '' : object.ksk_plate_number&.upcase
          }
        end

        def slot
          { id: parking_slot.name } if parking_slot
        end

        def total_price
          payment_info.pay
        end
      end
    end
  end
end
