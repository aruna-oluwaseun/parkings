module Api
  module V1
    class VehicleSerializer < ::ApplicationSerializer
      attributes :id, :plate_number, :vehicle_type, :color, :model, :user_id, :status
      belongs_to :manufacturer, serializer: ::ManufacturerSerializer
      belongs_to :user, serializer:ThinUserSerializer

      def plate_number
        object.plate_number&.upcase
      end

      def registration_card
        url_for(object.registration_card) if object.registration_card.attached?
      end

      def removable
        object.can_deleted?
      end
    end
  end
end
