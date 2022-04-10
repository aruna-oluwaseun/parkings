module DropdownFields
  module Dashboard
    class ParkingLotsWithoutAgencyList < ::DropdownFields::Base
      def execute
        current_user = params[:current_user]
        current_user.available_parking_lots.where(agency: nil)
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
