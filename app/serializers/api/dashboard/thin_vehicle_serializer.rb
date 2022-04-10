module Api
  module Dashboard
    class ThinVehicleSerializer < ::ApplicationSerializer
      attributes :id, :plate_number, :registration_country, :manufacturer, :status

      def registration_country
        ''
      end

      def manufacturer
        object.manufacturer&.name
      end
    end
  end
end
