module DropdownFields
  module Dashboard
    class AgencyType < ::DropdownFields::Base
      attr_accessor :current_user

      def execute
        current_user = params[:current_user]

        if current_user.super_admin? || current_user.town_manager?
          ::AgencyType.all.pluck(:name, :id).map do |agency_type|
            { name: agency_type.first, id: agency_type.second }
          end
        else
          {}
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
