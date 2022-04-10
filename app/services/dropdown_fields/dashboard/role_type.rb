module DropdownFields
  module Dashboard
    class RoleType < ::DropdownFields::Base

      AGENCY_ROLES = [
        { value: 'agency_manager', label: 'Law Enforcement Agency Manager' },
        { value: 'agency_officer', label: 'Law Enforcement Officer' }
      ].freeze

      PARKING_LOT_ROLES = { value: 'parking_lot_manager', label: 'Parking Operator' }.freeze
      ADMIN_ROLE = { value: 'super_admin', label: 'Super User' }.freeze
      TOWN_MANAGER_ROLE = { value: 'town_manager', label: 'Town Manager' }.freeze

      def execute
        current_user = params[:current_user]

        if current_user.super_admin? ||
          current_user.system_admin?
          [
            ADMIN_ROLE,
            TOWN_MANAGER_ROLE,
            PARKING_LOT_ROLES,
            *AGENCY_ROLES
          ]
        elsif current_user.town_manager?
          [
            TOWN_MANAGER_ROLE,
            PARKING_LOT_ROLES,
            *AGENCY_ROLES
          ]
        elsif current_user.agency_manager?
          AGENCY_ROLES
        else
          []
        end
      end

      def value_attr
        :value
      end

      def label_attr
        :label
      end
    end
  end
end
