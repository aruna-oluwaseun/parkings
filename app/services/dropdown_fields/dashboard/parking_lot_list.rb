module DropdownFields
  module Dashboard
    class ParkingLotList < ::DropdownFields::Base
      attr_accessor :current_user

      def execute
        @current_user = params[:current_user]

        current_user.available_parking_lots.map do |lot|
          {
            id: lot.id,
            name: lot.name
          }
        end
      end

      def value_attr
        :id
      end

      def label_attr
        :name
      end
    end
  end
end
