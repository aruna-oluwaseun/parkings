module Api
  module Dashboard
    class VehicleSerializer < ::ApplicationSerializer
      attributes :id, :plate_number, :vehicle_type, :color, :model, :user_id, :status
      belongs_to :manufacturer, serializer: ::ManufacturerSerializer
      belongs_to :user, serializer:ThinUserSerializer

      def plate_number
        object.plate_number&.upcase
      end
    end
  end
end
