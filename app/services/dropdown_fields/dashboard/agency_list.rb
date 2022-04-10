module DropdownFields
  module Dashboard
    class AgencyList < ::DropdownFields::Base
      attr_accessor :current_user

      def execute
        @current_user = params[:current_user]
        current_user.available_agencies.pluck(:name, :id).map do |name_id_array|
          { name: name_id_array.first, id: name_id_array.second }
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
